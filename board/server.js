#!/usr/bin/env node
/**
 * CKS Board Server — multi-project Kanban hub with SQLite persistence.
 * Features: file watching for two-way sync, SSE for live browser updates.
 *
 * Usage: node board/server.js [--port PORT] [--project-root PATH]
 */
const http = require('http');
const fs = require('fs');
const path = require('path');
const { handleApi, findProjectRoot, syncProject } = require('./api');
const { initDb, DB_PATH, listProjects, getProject } = require('./db');
const sessionMgr = require('./session');

const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.webmanifest': 'application/manifest+json',
};

const args = process.argv.slice(2);
let port = 4200;
let projectRoot = null;
let host = 'localhost';
let tunnelEnabled = false;

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--port' && args[i + 1]) port = parseInt(args[i + 1], 10);
  if (args[i] === '--project-root' && args[i + 1]) projectRoot = args[i + 1];
  if (args[i] === '--host' && args[i + 1]) host = args[i + 1];
  if (args[i] === '--lan') host = '0.0.0.0';
  if (args[i] === '--tunnel') tunnelEnabled = true;
}

projectRoot = projectRoot || findProjectRoot(process.cwd());
const publicDir = path.join(__dirname, 'public');

// Async main — sql.js requires async initialization
async function main() {

// Initialize database (WebAssembly SQLite)
await initDb();

// Auto-register and sync the current project on startup
const currentProjectId = syncProject(projectRoot);
console.log(`Synced project: ${projectRoot} (id: ${currentProjectId})`);
console.log(`Database: ${DB_PATH}`);

// ═══ Request Log Buffer ═══

const REQUEST_LOG_MAX = 500;
const requestLogs = [];

function addRequestLog(method, pathname, status, duration) {
  requestLogs.push({
    timestamp: new Date().toISOString(),
    method,
    path: pathname,
    status,
    duration,
  });
  if (requestLogs.length > REQUEST_LOG_MAX) requestLogs.shift();
}

function getRequestLogs(limit) {
  return requestLogs.slice(-limit).reverse();
}

// ═══ SSE (Server-Sent Events) for live updates ═══

const sseClients = new Set();
const sessionSSEClients = new Map(); // sessionId -> Set<res>

function broadcastSSE(event, data) {
  const message = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
  for (const client of sseClients) {
    try { client.write(message); } catch { sseClients.delete(client); }
  }
}

// ═══ File Watchers — watch .prd/ dirs for two-way sync ═══

const watchers = new Map(); // projectPath -> FSWatcher
let debounceTimer = null;

function watchProject(projectPath, projectId) {
  const prdDir = path.join(projectPath, '.prd');
  if (!fs.existsSync(prdDir)) return;
  if (watchers.has(projectPath)) return; // already watching

  try {
    const watcher = fs.watch(prdDir, { recursive: true }, (eventType, filename) => {
      // Debounce: wait 500ms after last change before syncing
      if (debounceTimer) clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => {
        console.log(`[watch] ${projectPath}: ${eventType} ${filename || ''}`);
        try {
          syncProject(projectPath);
          broadcastSSE('sync', { projectId, projectPath, trigger: filename });
        } catch (err) {
          console.error('[watch] sync error:', err.message);
        }
      }, 500);
    });

    watchers.set(projectPath, watcher);
    console.log(`[watch] Watching: ${prdDir}`);
  } catch (err) {
    console.error(`[watch] Failed to watch ${prdDir}:`, err.message);
  }
}

function unwatchProject(projectPath) {
  const watcher = watchers.get(projectPath);
  if (watcher) {
    watcher.close();
    watchers.delete(projectPath);
    console.log(`[watch] Unwatched: ${projectPath}`);
  }
}

// Watch all registered projects on startup
function watchAllProjects() {
  const projects = listProjects();
  for (const p of projects) {
    watchProject(p.path, p.id);
  }
}

watchAllProjects();

// ═══ HTTP Server ═══

function serveStatic(res, filePath) {
  const ext = path.extname(filePath);
  const mime = MIME_TYPES[ext] || 'text/plain';

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Not Found');
      return;
    }
    res.writeHead(200, { 'Content-Type': mime });
    res.end(data);
  });
}

// ═══ Token Auth (enabled when --lan or --tunnel) ═══
const crypto = require('crypto');
const requireAuth = (host === '0.0.0.0' || tunnelEnabled);
const authToken = requireAuth ? crypto.randomBytes(16).toString('hex') : null;

if (requireAuth) {
  console.log(`\n  Auth token: ${authToken}`);
  console.log(`  Add ?token=${authToken} to your URL or use Authorization: Bearer ${authToken}\n`);
}

function checkAuth(req, res) {
  if (!requireAuth) return true;

  // Allow token via query param, header, or cookie
  const url = new URL(req.url, 'http://localhost');
  const qToken = url.searchParams.get('token');
  const hToken = (req.headers.authorization || '').replace('Bearer ', '');
  const cookies = (req.headers.cookie || '').split(';').reduce((acc, c) => {
    const [k, v] = c.trim().split('=');
    if (k && v) acc[k] = v;
    return acc;
  }, {});
  const cToken = cookies['cks-token'];

  if (qToken === authToken || hToken === authToken || cToken === authToken) {
    // Set cookie so subsequent requests are authenticated
    if (!cToken && (qToken === authToken || hToken === authToken)) {
      res.setHeader('Set-Cookie', `cks-token=${authToken}; Path=/; HttpOnly; SameSite=Strict; Max-Age=86400`);
    }
    return true;
  }

  // Serve login page for browser requests, 401 for API
  if (req.url.startsWith('/api/')) {
    res.writeHead(401, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Unauthorized', message: 'Add ?token=TOKEN to your URL' }));
  } else {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(loginPage());
  }
  return false;
}

function loginPage() {
  return '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>CKS Board - Login</title><style>body{font-family:-apple-system,sans-serif;background:#0c0d12;color:#e4e7f1;display:flex;justify-content:center;align-items:center;height:100vh;margin:0}.login{text-align:center;padding:40px;background:#14161e;border:1px solid #252938;border-radius:14px;max-width:380px;width:90%}h1{font-size:20px;margin-bottom:8px}p{font-size:13px;color:#8891a8;margin-bottom:20px}input{width:100%;padding:10px 14px;background:#0c0d12;border:1px solid #252938;border-radius:6px;color:#e4e7f1;font-size:14px;margin-bottom:12px;box-sizing:border-box}input:focus{outline:none;border-color:#6c8cff}button{width:100%;padding:10px;background:#6c8cff;color:white;border:none;border-radius:6px;font-size:14px;cursor:pointer}button:hover{opacity:0.85}.err{color:#f87171;font-size:12px;display:none;margin-bottom:8px}</style></head><body><div class="login"><h1>CKS Board</h1><p>Enter the access token shown in your terminal</p><div class="err" id="err">Invalid token</div><input type="text" id="token" placeholder="Paste token here..." autofocus><button onclick="auth()">Access Board</button></div><script>function auth(){var t=document.getElementById("token").value.trim();if(!t)return;window.location.href="/?token="+encodeURIComponent(t)}document.getElementById("token").addEventListener("keydown",function(e){if(e.key==="Enter")auth()})</script></body></html>';
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Check auth for all requests when remote access is enabled
  if (!checkAuth(req, res)) return;

  // ═══ Request Logging ═══
  const reqStart = Date.now();
  const origEnd = res.end.bind(res);
  res.end = function(...args) {
    const duration = Date.now() - reqStart;
    const status = res.statusCode;
    const pathname = new URL(req.url, 'http://localhost').pathname;
    // Skip noisy SSE and static asset requests
    if (!pathname.startsWith('/api/events') && !pathname.startsWith('/api/session/') || pathname.endsWith('/respond') || pathname.endsWith('/start') || pathname.endsWith('/stop')) {
      const color = status >= 400 ? '\x1b[31m' : status >= 300 ? '\x1b[33m' : '\x1b[32m';
      console.log(`${color}${req.method} ${pathname}\x1b[0m ${status} ${duration}ms`);
    }
    // Store in recent logs buffer for UI
    addRequestLog(req.method, pathname, status, duration);
    return origEnd(...args);
  };

  // ═══ Session endpoints — live Claude Code execution ═══

  // SSE stream for a specific session
  const sessionEventsMatch = req.url.match(/^\/api\/session\/([^/]+)\/events/);
  if (sessionEventsMatch) {
    const sessionId = sessionEventsMatch[1];
    const session = sessionMgr.getSession(sessionId);
    if (!session) {
      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Session not found' }));
      return;
    }
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });
    res.write('event: connected\ndata: ' + JSON.stringify({ sessionId }) + '\n\n');

    // Replay all buffered events so the client catches up
    const pastEvents = sessionMgr.getSessionEvents(sessionId);
    for (const evt of pastEvents) {
      res.write('event: claude\ndata: ' + JSON.stringify(evt) + '\n\n');
    }

    // Track this SSE client for future events
    if (!sessionSSEClients.has(sessionId)) sessionSSEClients.set(sessionId, new Set());
    sessionSSEClients.get(sessionId).add(res);
    req.on('close', () => {
      const clients = sessionSSEClients.get(sessionId);
      if (clients) clients.delete(res);
    });
    return;
  }

  // Start a session
  if (req.url === '/api/session/start' && req.method === 'POST') {
    let body = '';
    await new Promise((resolve) => {
      req.on('data', c => { body += c; if (body.length > 1e5) req.destroy(); });
      req.on('end', resolve);
    });
    const data = JSON.parse(body || '{}');
    const projectId = data.projectId;
    const prompt = data.prompt;

    if (!prompt) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'prompt is required' }));
      return;
    }

    let projectPath = projectRoot;
    if (projectId) {
      const project = getProject(projectId);
      if (project) projectPath = project.path;
    }

    const sessionId = sessionMgr.startSession(projectPath, prompt, (sid, event) => {
      // Forward event to all SSE clients for this session
      const clients = sessionSSEClients.get(sid);
      if (!clients) return;
      const msg = 'event: claude\ndata: ' + JSON.stringify(event) + '\n\n';
      for (const client of clients) {
        try { client.write(msg); } catch { clients.delete(client); }
      }

      // Also broadcast to global SSE when session ends (to trigger board refresh)
      if (event.type === 'session_end') {
        broadcastSSE('session_end', { sessionId: sid, status: event.status });
        // Re-sync the project since Claude may have changed files
        syncProject(projectPath);
        broadcastSSE('sync', { projectPath, trigger: 'session_end' });
      }
    });

    console.log(`[session] Started: ${sessionId} in ${projectPath} — ${prompt}`);

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ sessionId, projectPath }));
    return;
  }

  // Respond to a session (send user input)
  const sessionRespondMatch = req.url.match(/^\/api\/session\/([^/]+)\/respond/);
  if (sessionRespondMatch && req.method === 'POST') {
    const sessionId = sessionRespondMatch[1];
    let body = '';
    await new Promise((resolve) => {
      req.on('data', c => { body += c; });
      req.on('end', resolve);
    });
    const data = JSON.parse(body || '{}');
    const ok = sessionMgr.respondToSession(sessionId, data.text || '', (sid, event) => {
      const clients = sessionSSEClients.get(sid);
      if (!clients) return;
      const msg = 'event: claude\ndata: ' + JSON.stringify(event) + '\n\n';
      for (const client of clients) {
        try { client.write(msg); } catch { clients.delete(client); }
      }
      if (event.type === 'session_end') {
        broadcastSSE('session_end', { sessionId: sid });
        const sess = sessionMgr.getSession(sid);
        if (sess) { syncProject(sess.projectPath); broadcastSSE('sync', { trigger: 'session_end' }); }
      }
    });
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ sent: ok }));
    return;
  }

  // Stop a session
  const sessionStopMatch = req.url.match(/^\/api\/session\/([^/]+)\/stop/);
  if (sessionStopMatch && req.method === 'POST') {
    const sessionId = sessionStopMatch[1];
    sessionMgr.stopSession(sessionId);
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ stopped: true }));
    return;
  }

  // List sessions
  if (req.url === '/api/sessions' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(sessionMgr.listSessions()));
    return;
  }

  // SSE endpoint for live updates (file watcher)
  if (req.url === '/api/events') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });
    res.write('event: connected\ndata: {}\n\n');
    sseClients.add(res);
    req.on('close', () => sseClients.delete(res));
    return;
  }

  // Server logs endpoint
  if (req.url.startsWith('/api/server-logs')) {
    const url = new URL(req.url, 'http://localhost');
    const limit = parseInt(url.searchParams.get('limit') || '100', 10);
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(getRequestLogs(limit)));
    return;
  }

  // API routes
  if (req.url.startsWith('/api/')) {
    try {
      const result = await handleApi(req, projectRoot);

      // After project add/sync, start watching the new project
      if (req.url.includes('/api/projects/add') || req.url.includes('/api/projects/sync')) {
        if (result && result.projectId) {
          const project = require('./db').getProject(result.projectId);
          if (project) watchProject(project.path, project.id);
        }
      }

      // After project remove, stop watching
      if (req.url.includes('/api/projects/remove') && result && result.removed) {
        // Re-sync watchers
        const currentPaths = new Set(listProjects().map(p => p.path));
        for (const [watchedPath] of watchers) {
          if (!currentPaths.has(watchedPath)) unwatchProject(watchedPath);
        }
      }

      if (result === null) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Not found' }));
      } else {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result, null, 2));
      }
    } catch (err) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
    return;
  }

  // Static file serving — strip query params
  const pathname = new URL(req.url, 'http://localhost').pathname;
  let filePath = path.join(publicDir, pathname === '/' ? 'index.html' : pathname);

  if (!filePath.startsWith(publicDir)) {
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    res.end('Forbidden');
    return;
  }

  serveStatic(res, filePath);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`Port ${port} in use, trying random port...`);
    server.listen(0, () => {
      const actualPort = server.address().port;
      console.log(`CKS Board running at http://localhost:${actualPort}`);
    });
  } else {
    console.error('Server error:', err.message);
    process.exit(1);
  }
});

server.listen(port, host, () => {
  const actualPort = server.address().port;
  const addr = host === '0.0.0.0' ? `http://<your-ip>:${actualPort}` : `http://${host}:${actualPort}`;
  console.log(`CKS Board running at http://localhost:${actualPort}`);
  if (host === '0.0.0.0') console.log(`LAN access: http://<your-ip>:${actualPort}`);
  console.log(`Project root: ${projectRoot}`);
  console.log(`SSE clients: /api/events`);
  console.log(`Watching ${watchers.size} project(s)`);

  // Start Cloudflare Tunnel if requested
  if (tunnelEnabled) {
    startTunnel(actualPort);
  }
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down...');
  for (const [p] of watchers) unwatchProject(p);
  server.close();
  process.exit(0);
});

// ═══ Cloudflare Tunnel (inside main scope for broadcastSSE access) ═══

function startTunnel(tunnelPort) {
  const { spawn: spawnTunnel } = require('child_process');
  console.log('[tunnel] Starting Cloudflare Tunnel...');
  const cf = spawnTunnel('cloudflared', ['tunnel', '--url', `http://localhost:${tunnelPort}`], {
    stdio: ['ignore', 'pipe', 'pipe'],
  });

  cf.stderr.on('data', (data) => {
    const text = data.toString();
    const match = text.match(/https:\/\/[^\s]+\.trycloudflare\.com/);
    if (match) {
      console.log(`[tunnel] Remote access: ${match[0]}`);
      broadcastSSE('tunnel_url', { url: match[0] });
    }
  });

  cf.on('error', () => {
    console.error('[tunnel] cloudflared not found. Install from: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/');
  });

  cf.on('close', (code) => {
    if (code !== 0) console.error(`[tunnel] Exited with code ${code}`);
  });

  process.on('SIGINT', () => { cf.kill(); });
}

} // end main()

main().catch(err => {
  console.error('Failed to start CKS Board:', err.message);
  process.exit(1);
});
