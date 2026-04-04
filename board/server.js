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
const { DB_PATH, listProjects, getProject } = require('./db');
const sessionMgr = require('./session');

const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
};

const args = process.argv.slice(2);
let port = 4200;
let projectRoot = null;

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--port' && args[i + 1]) port = parseInt(args[i + 1], 10);
  if (args[i] === '--project-root' && args[i + 1]) projectRoot = args[i + 1];
}

projectRoot = projectRoot || findProjectRoot(process.cwd());
const publicDir = path.join(__dirname, 'public');

// Auto-register and sync the current project on startup
const currentProjectId = syncProject(projectRoot);
console.log(`Synced project: ${projectRoot} (id: ${currentProjectId})`);
console.log(`Database: ${DB_PATH}`);

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

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

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

  // Static file serving
  let filePath = path.join(publicDir, req.url === '/' ? 'index.html' : req.url);

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

server.listen(port, () => {
  const actualPort = server.address().port;
  console.log(`CKS Board running at http://localhost:${actualPort}`);
  console.log(`Project root: ${projectRoot}`);
  console.log(`SSE clients: /api/events`);
  console.log(`Watching ${watchers.size} project(s)`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down...');
  for (const [p] of watchers) unwatchProject(p);
  server.close();
  process.exit(0);
});
