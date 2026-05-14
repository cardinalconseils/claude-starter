/**
 * CKS Webhook Listener — inbound GitHub Project Kanban → CKS runner automation.
 *
 * Verifies GitHub webhook signatures (HMAC-SHA256, constant-time), maps
 * Project card column moves to CKS runner actions, and runs an idempotent
 * reconciliation loop that catches webhooks missed while the server was down.
 *
 * Config-gated: when `webhook_enabled` is false in plugin.json, every export
 * no-ops. Mirrors the null-config guard pattern in tools/github-project-sync.js.
 */
const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

const sync = require('./github-project-sync');
const { GitHubUnreachableError } = sync;

let configCache = null;

function loadConfig() {
  if (configCache) return configCache;
  const pluginJsonPath = path.join(path.dirname(__dirname), '.claude-plugin', 'plugin.json');
  try {
    configCache = JSON.parse(fs.readFileSync(pluginJsonPath, 'utf-8'));
  } catch (err) {}
  return configCache;
}

/**
 * True only when webhooks are explicitly enabled AND the GitHub Project is
 * configured. Either being absent makes every export a no-op.
 */
function isEnabled() {
  const config = loadConfig();
  if (!config || config.webhook_enabled !== true) return false;
  return sync.isConfigured();
}

/**
 * Constant-time HMAC-SHA256 verification of a GitHub webhook payload.
 * Compares the `X-Hub-Signature-256` header against a fresh HMAC of the raw
 * body. Uses crypto.timingSafeEqual — a non-constant-time compare here is a
 * security finding, not a style nit.
 *
 * @param {Buffer|string} rawBody  the exact bytes GitHub POSTed
 * @param {string} signatureHeader value of the X-Hub-Signature-256 header
 * @param {string} [secret]        webhook secret; defaults to GITHUB_WEBHOOK_SECRET
 * @returns {boolean} true only when the signature is present and valid
 */
function verifySignature(rawBody, signatureHeader, secret) {
  const webhookSecret = secret || process.env.GITHUB_WEBHOOK_SECRET;
  if (!webhookSecret) return false;
  if (!signatureHeader || typeof signatureHeader !== 'string') return false;
  if (!signatureHeader.startsWith('sha256=')) return false;

  const body = Buffer.isBuffer(rawBody) ? rawBody : Buffer.from(rawBody || '', 'utf-8');
  const expected = 'sha256=' + crypto
    .createHmac('sha256', webhookSecret)
    .update(body)
    .digest('hex');

  const a = Buffer.from(signatureHeader, 'utf-8');
  const b = Buffer.from(expected, 'utf-8');
  // timingSafeEqual throws on length mismatch — guard so a wrong-length
  // signature is a plain false, not an exception, but still constant-time
  // for equal-length inputs.
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}

/**
 * Column → CKS runner action map. When a human drags a Project card, the
 * webhook tells the runner what to do.
 */
const COLUMN_ACTIONS = {
  'Backlog':     'idle',          // parked — runner takes no action
  'Ready':       'idle',          // queued — wait for explicit start
  'In Progress': 'resume',        // start or resume the runner on this phase
  'In Review':   'await_gate',    // pause at the next human gate
  'Blocked':     'halt',          // stop the runner; needs human unblock
  'Done':        'finalize',      // mark complete; release path
};

/**
 * Translate a card column move into a runner action. Idempotent: returning the
 * same action object for the same column is safe to apply repeatedly.
 *
 * @param {string} column   target column name
 * @param {object} [context] optional { itemId, phaseNumber } for logging/sync
 * @returns {{action: string, column: string, context: object}|null}
 */
function dispatchColumnChange(column, context) {
  if (!isEnabled()) return null;
  const action = COLUMN_ACTIONS[column];
  if (!action) return null;
  return { action, column, context: context || {} };
}

/**
 * Parse a GitHub `projects_v2_item` webhook payload into a column-change
 * dispatch. Returns null for payloads that are not a card column move or when
 * webhooks are disabled.
 *
 * @param {object} payload parsed JSON webhook body
 */
function handleWebhookPayload(payload) {
  if (!isEnabled()) return null;
  if (!payload || payload.action !== 'edited') return null;

  const change = payload.changes && payload.changes.field_value;
  if (!change || change.field_type !== 'single_select') return null;

  const toColumn = change.to && change.to.name;
  if (!toColumn) return null;

  const item = payload.projects_v2_item || {};
  return dispatchColumnChange(toColumn, {
    itemId: item.node_id || item.id,
    contentType: item.content_type,
  });
}

/**
 * Idempotent reconciliation: re-reads the GitHub Project and returns the set of
 * column-change dispatches implied by the current board state. Applying the
 * result twice is a no-op — it reflects board state, it does not accumulate.
 *
 * @returns {Promise<Array>} dispatch objects for every phase item
 */
async function reconcile() {
  if (!isEnabled()) return [];
  try {
    const items = await sync.getPhaseItems();
    return items
      .map((item) => dispatchColumnChange(item.column, {
        itemId: item.id,
        phaseNumber: item.phaseNumber,
      }))
      .filter(Boolean);
  } catch (err) {
    if (err instanceof GitHubUnreachableError) return [];
    throw err;
  }
}

/**
 * Start the 60s reconciliation loop. Catches webhooks missed while the server
 * was down. No-ops entirely when webhooks are disabled. The returned handle has
 * a stop() to clear the interval.
 *
 * @param {(dispatches: Array) => void} [onReconcile] called with each cycle's dispatches
 * @param {number} [intervalMs] override the 60s default (used by tests)
 */
function startReconciliationLoop(onReconcile, intervalMs) {
  if (!isEnabled()) return { stop() {}, enabled: false };

  const period = intervalMs || 60000;
  const timer = setInterval(async () => {
    try {
      const dispatches = await reconcile();
      if (typeof onReconcile === 'function') onReconcile(dispatches);
    } catch (err) {
      // Reconciliation is a backstop — a single failed cycle must not crash
      // the loop. The next cycle retries.
      console.error('[webhook-listener] reconcile cycle failed:', err.message);
    }
  }, period);

  if (typeof timer.unref === 'function') timer.unref();
  return {
    stop() { clearInterval(timer); },
    enabled: true,
  };
}

module.exports = {
  isEnabled,
  verifySignature,
  COLUMN_ACTIONS,
  dispatchColumnChange,
  handleWebhookPayload,
  reconcile,
  startReconciliationLoop,
};
