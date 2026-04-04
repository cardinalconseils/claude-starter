/**
 * CKS Board Session Manager — spawns and manages Claude Code CLI processes.
 * Each session is a Claude Code process with streaming JSON I/O.
 */
const { spawn } = require('child_process');
const path = require('path');

const sessions = new Map();

/**
 * Start a new Claude Code session.
 * @param {string} projectPath - Working directory for the session
 * @param {string} prompt - Initial prompt (e.g., "/cks:kickstart")
 * @param {function} onEvent - Callback for each JSON event: (sessionId, event) => void
 * @returns {string} sessionId
 */
function startSession(projectPath, prompt, onEvent) {
  const sessionId = 'ses-' + Date.now() + '-' + Math.random().toString(36).slice(2, 8);

  // Use -p for the prompt with stream-json output
  // For follow-up responses, we'll spawn a --resume session
  const args = [
    '-p', prompt,
    '--output-format', 'stream-json',
    '--verbose',
    '--max-turns', '50',
    '--permission-mode', 'acceptEdits',
  ];

  const proc = spawn('claude', args, {
    cwd: projectPath,
    stdio: ['ignore', 'pipe', 'pipe'],
    env: { ...process.env },
  });

  const session = {
    id: sessionId,
    projectPath,
    prompt,
    process: proc,
    claudeSessionId: null, // Captured from system:init event
    status: 'running',
    startedAt: new Date().toISOString(),
    events: [],
  };

  sessions.set(sessionId, session);

  let buffer = '';

  proc.stdout.on('data', (chunk) => {
    buffer += chunk.toString();
    const lines = buffer.split('\n');
    buffer = lines.pop(); // Keep incomplete last line in buffer

    for (const line of lines) {
      if (!line.trim()) continue;
      try {
        const event = JSON.parse(line);
        event._sessionId = sessionId;
        event._timestamp = new Date().toISOString();

        // Capture Claude's internal session ID for --resume
        if (event.session_id && !session.claudeSessionId) {
          session.claudeSessionId = event.session_id;
        }

        session.events.push(event);
        onEvent(sessionId, event);
      } catch {
        // Non-JSON output, wrap it
        const textEvent = { type: 'text', content: line, _sessionId: sessionId, _timestamp: new Date().toISOString() };
        session.events.push(textEvent);
        onEvent(sessionId, textEvent);
      }
    }
  });

  proc.stderr.on('data', (chunk) => {
    const text = chunk.toString().trim();
    if (!text) return;
    const errEvent = { type: 'stderr', content: text, _sessionId: sessionId, _timestamp: new Date().toISOString() };
    session.events.push(errEvent);
    onEvent(sessionId, errEvent);
  });

  proc.on('close', (code) => {
    session.status = code === 0 ? 'completed' : 'failed';
    session.exitCode = code;
    const doneEvent = {
      type: 'session_end',
      status: session.status,
      exitCode: code,
      _sessionId: sessionId,
      _timestamp: new Date().toISOString(),
    };
    session.events.push(doneEvent);
    onEvent(sessionId, doneEvent);
  });

  proc.on('error', (err) => {
    session.status = 'error';
    const errEvent = {
      type: 'session_error',
      error: err.message,
      _sessionId: sessionId,
      _timestamp: new Date().toISOString(),
    };
    session.events.push(errEvent);
    onEvent(sessionId, errEvent);
  });

  return sessionId;
}

/**
 * Send a response to an active session's stdin.
 * Used when Claude asks a question and the user answers from the board.
 */
function respondToSession(sessionId, text, onEvent) {
  const session = sessions.get(sessionId);
  if (!session) return false;
  if (!session.claudeSessionId) {
    console.error('[session] No Claude session ID to resume');
    return false;
  }

  // Spawn a new claude --resume process to continue the conversation
  session.status = 'running';

  const args = [
    '-p', text,
    '--resume', session.claudeSessionId,
    '--output-format', 'stream-json',
    '--verbose',
    '--max-turns', '50',
    '--permission-mode', 'acceptEdits',
  ];

  const proc = spawn('claude', args, {
    cwd: session.projectPath,
    stdio: ['ignore', 'pipe', 'pipe'],
    env: { ...process.env },
  });

  session.process = proc;
  let buffer = '';

  proc.stdout.on('data', (chunk) => {
    buffer += chunk.toString();
    const lines = buffer.split('\n');
    buffer = lines.pop();
    for (const line of lines) {
      if (!line.trim()) continue;
      try {
        const event = JSON.parse(line);
        event._sessionId = sessionId;
        event._timestamp = new Date().toISOString();
        session.events.push(event);
        if (onEvent) onEvent(sessionId, event);
      } catch {}
    }
  });

  proc.stderr.on('data', (chunk) => {
    const t = chunk.toString().trim();
    if (!t) return;
    const evt = { type: 'stderr', content: t, _sessionId: sessionId, _timestamp: new Date().toISOString() };
    session.events.push(evt);
    if (onEvent) onEvent(sessionId, evt);
  });

  proc.on('close', (code) => {
    session.status = code === 0 ? 'completed' : 'failed';
    const evt = { type: 'session_end', status: session.status, exitCode: code, _sessionId: sessionId, _timestamp: new Date().toISOString() };
    session.events.push(evt);
    if (onEvent) onEvent(sessionId, evt);
  });

  return true;
}

/**
 * Stop an active session.
 */
function stopSession(sessionId) {
  const session = sessions.get(sessionId);
  if (!session) return false;

  if (session.status === 'running') {
    session.process.kill('SIGTERM');
    session.status = 'stopped';
  }
  return true;
}

/**
 * Get session info.
 */
function getSession(sessionId) {
  const session = sessions.get(sessionId);
  if (!session) return null;
  return {
    id: session.id,
    projectPath: session.projectPath,
    prompt: session.prompt,
    status: session.status,
    startedAt: session.startedAt,
    eventCount: session.events.length,
  };
}

/**
 * List all sessions.
 */
function listSessions() {
  return [...sessions.values()].map(s => ({
    id: s.id,
    projectPath: s.projectPath,
    prompt: s.prompt,
    status: s.status,
    startedAt: s.startedAt,
  }));
}

function getSessionEvents(sessionId) {
  const session = sessions.get(sessionId);
  if (!session) return [];
  return session.events;
}

module.exports = { startSession, respondToSession, stopSession, getSession, listSessions, getSessionEvents };
