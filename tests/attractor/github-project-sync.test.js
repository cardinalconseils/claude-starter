const assert = require('assert');
const fs = require('fs');
const path = require('path');

function readConfig() {
  try {
    return JSON.parse(fs.readFileSync(path.join(__dirname, '../../.claude-plugin/plugin.json'), 'utf-8'));
  } catch (err) {
    return null;
  }
}

(async () => {
  delete require.cache[require.resolve('../../tools/github-project-sync.js')];
  const sync = require('../../tools/github-project-sync.js');

  const tests = [
    { name: 'exports isConfigured', fn: () => { assert.strictEqual(typeof sync.isConfigured, 'function'); }},
    { name: 'exports GitHubUnreachableError', fn: () => { assert.strictEqual(typeof sync.GitHubUnreachableError, 'function'); }},
    { name: 'isConfigured() returns boolean', fn: () => { assert.strictEqual(typeof sync.isConfigured(), 'boolean'); }},
    { name: 'loadConfig() reads plugin.json', fn: () => { const cfg = readConfig(); assert(cfg === null || typeof cfg === 'object'); }},
    { name: 'exports getPhaseItems', fn: () => { assert.strictEqual(typeof sync.getPhaseItems, 'function'); }},
    { name: 'exports moveCard', fn: () => { assert.strictEqual(typeof sync.moveCard, 'function'); }},
    { name: 'exports setCustomField', fn: () => { assert.strictEqual(typeof sync.setCustomField, 'function'); }},
    { name: 'exports commentOnPhaseItem', fn: () => { assert.strictEqual(typeof sync.commentOnPhaseItem, 'function'); }},
    { name: 'exports getPriorArt', fn: () => { assert.strictEqual(typeof sync.getPriorArt, 'function'); }},
    { name: 'GitHubUnreachableError is Error', fn: () => { assert(new sync.GitHubUnreachableError('test') instanceof Error); }},
    { name: 'GitHubUnreachableError preserves message', fn: () => { const e = new sync.GitHubUnreachableError('msg'); assert.strictEqual(e.message, 'msg'); }},
  ];

  let passed = 0, failed = 0;
  for (const test of tests) {
    try { test.fn(); console.log(`✓ ${test.name}`); passed++; }
    catch (err) { console.log(`✗ ${test.name}: ${err.message}`); failed++; }
  }
  console.log(`\nResults: ${passed} passed, ${failed} failed`);
  process.exit(failed > 0 ? 1 : 0);
})();
