/**
 * CKS Board Session Manager — spawns and manages Claude Code CLI processes.
 * Each session is a Claude Code process with streaming JSON I/O.
 * Detects when Claude asks questions and enables board-based responses.
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
    claudeSessionId: null,
    status: 'running',
    startedAt: new Date().toISOString(),
    events: [],
    lastQuestion: null,     // The last question Claude asked (for display in UI)
    lastQuestionOptions: null, // Options if it was a multiple-choice question
  };

  sessions.set(sessionId, session);

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

        // Capture Claude's internal session ID for --resume
        if (event.session_id && !session.claudeSessionId) {
          session.claudeSessionId = event.session_id;
        }

        // Detect if Claude is asking a question (needs user input)
        detectQuestion(session, event);

        session.events.push(event);
        onEvent(sessionId, event);
      } catch {
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
    // Don't override needs_input — CLI exits after AskUserQuestion but user still needs to answer
    if (session.status !== 'needs_input') {
      session.status = code === 0 ? 'completed' : 'failed';
      session.lastQuestion = null;
      session.lastQuestionOptions = null;
    }
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
 * Detect if Claude is asking a question and update session state.
 * Claude Code's stream-json emits different event patterns when waiting for input:
 * - result events with subtype indicating turn end
 * - assistant messages containing AskUserQuestion tool calls
 */
function detectQuestion(session, event) {
  // Detect AskUserQuestion tool use in assistant messages
  if (event.type === 'assistant' && event.message && event.message.content) {
    for (const block of event.message.content) {
      if (block.type === 'tool_use' && block.name === 'AskUserQuestion') {
        const input = block.input || {};
        const questions = input.questions || [];
        if (questions.length > 0) {
          const q = questions[0]; // Primary question
          session.lastQuestion = q.question || 'Claude is asking a question...';
          session.lastQuestionOptions = (q.options || []).map(o => o.label);
          session.status = 'needs_input';

          // Emit a synthetic event so the UI knows
          const qEvent = {
            type: 'needs_input',
            question: session.lastQuestion,
            options: session.lastQuestionOptions,
            _sessionId: session.id,
            _timestamp: new Date().toISOString(),
          };
          session.events.push(qEvent);
        }
        return;
      }
    }
  }

  // Detect result events that indicate the session is waiting
  // (turn completed but process didn't exit — Claude is waiting for input)
  if (event.type === 'result' && !event.is_error) {
    // Result with subtype means Claude finished a turn
    // If the process is still running, it's waiting for the next prompt
    session.status = 'completed';
    session.lastQuestion = null;
    session.lastQuestionOptions = null;
  }
}

/**
 * Send a response to an active session.
 * Spawns a new claude --resume process to continue the conversation.
 */
function respondToSession(sessionId, text, onEvent) {
  const session = sessions.get(sessionId);
  if (!session) return false;
  if (!session.claudeSessionId) {
    console.error('[session] No Claude session ID to resume');
    return false;
  }

  // Clear the question state
  session.lastQuestion = null;
  session.lastQuestionOptions = null;
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
        detectQuestion(session, event);
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
    session.lastQuestion = null;
    session.lastQuestionOptions = null;
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

  if (session.status === 'running' || session.status === 'needs_input') {
    session.process.kill('SIGTERM');
    session.status = 'stopped';
    session.lastQuestion = null;
    session.lastQuestionOptions = null;
  }
  return true;
}

/**
 * Get session info (includes question state for UI).
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
    lastQuestion: session.lastQuestion,
    lastQuestionOptions: session.lastQuestionOptions,
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
    lastQuestion: s.lastQuestion,
    lastQuestionOptions: s.lastQuestionOptions,
  }));
}

function getSessionEvents(sessionId) {
  const session = sessions.get(sessionId);
  if (!session) return [];
  return session.events;
}

module.exports = { startSession, respondToSession, stopSession, getSession, listSessions, getSessionEvents };
