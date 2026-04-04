/**
 * CKS Board Database — sql.js (WebAssembly SQLite) persistence.
 * Zero native dependencies — works on any platform without compilation.
 * Stores at ~/.cks/board.db. The .prd/ filesystem remains source of truth;
 * this DB is a synced index that enables persistence and cross-project access.
 */
const initSqlJs = require('sql.js');
const path = require('path');
const fs = require('fs');
const os = require('os');

const DB_DIR = path.join(os.homedir(), '.cks');
const DB_PATH = path.join(DB_DIR, 'board.db');

let db = null;
let SQL = null;

/**
 * Initialize sql.js and open (or create) the database.
 * Must be called once before any other DB function.
 */
async function initDb() {
  if (db) return db;

  SQL = await initSqlJs();

  if (!fs.existsSync(DB_DIR)) {
    fs.mkdirSync(DB_DIR, { recursive: true });
  }

  if (fs.existsSync(DB_PATH)) {
    const buffer = fs.readFileSync(DB_PATH);
    db = new SQL.Database(buffer);
  } else {
    db = new SQL.Database();
  }

  db.run('PRAGMA foreign_keys = ON');
  migrate();
  saveDb();
  return db;
}

function getDb() {
  if (!db) throw new Error('Database not initialized. Call initDb() first.');
  return db;
}

/** Write the in-memory DB to disk */
function saveDb() {
  if (!db) return;
  const data = db.export();
  const buffer = Buffer.from(data);
  fs.writeFileSync(DB_PATH, buffer);
}

function migrate() {
  db.run(`
    CREATE TABLE IF NOT EXISTS projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      path TEXT UNIQUE NOT NULL,
      added_at TEXT DEFAULT (datetime('now')),
      last_opened TEXT DEFAULT (datetime('now'))
    )
  `);
  db.run(`
    CREATE TABLE IF NOT EXISTS project_state (
      project_id INTEGER PRIMARY KEY REFERENCES projects(id) ON DELETE CASCADE,
      active_phase TEXT,
      phase_name TEXT,
      phase_status TEXT,
      last_action TEXT,
      last_action_date TEXT,
      next_action TEXT,
      suggested_command TEXT,
      iteration_count TEXT,
      has_prd INTEGER DEFAULT 0,
      synced_at TEXT DEFAULT (datetime('now'))
    )
  `);
  db.run(`
    CREATE TABLE IF NOT EXISTS features (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
      feature_id TEXT NOT NULL,
      phase_num TEXT NOT NULL,
      name TEXT NOT NULL,
      display_name TEXT NOT NULL,
      status TEXT DEFAULT 'not_started',
      column_name TEXT DEFAULT 'backlog',
      elements TEXT,
      artifacts TEXT,
      tasks TEXT,
      next_command TEXT,
      is_active INTEGER DEFAULT 0,
      synced_at TEXT DEFAULT (datetime('now')),
      UNIQUE(project_id, feature_id)
    )
  `);
  db.run(`
    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
      feature_id TEXT,
      task_num TEXT,
      role TEXT NOT NULL DEFAULT 'user',
      content TEXT NOT NULL,
      created_at TEXT DEFAULT (datetime('now'))
    )
  `);
  db.run('CREATE INDEX IF NOT EXISTS idx_features_project ON features(project_id)');
  db.run('CREATE INDEX IF NOT EXISTS idx_messages_context ON messages(project_id, feature_id, task_num)');
}

// --- Helpers for query results ---

/** Run a SELECT and return all rows as objects */
function queryAll(sql, params) {
  const stmt = db.prepare(sql);
  if (params) stmt.bind(params);
  const rows = [];
  while (stmt.step()) {
    rows.push(stmt.getAsObject());
  }
  stmt.free();
  return rows;
}

/** Run a SELECT and return the first row as object, or null */
function queryOne(sql, params) {
  const stmt = db.prepare(sql);
  if (params) stmt.bind(params);
  let row = null;
  if (stmt.step()) {
    row = stmt.getAsObject();
  }
  stmt.free();
  return row;
}

/** Run an INSERT/UPDATE/DELETE with params, then save to disk */
function runAndSave(sql, params) {
  if (params) {
    db.run(sql, params);
  } else {
    db.run(sql);
  }
  saveDb();
}

// --- Project CRUD ---

function registerProject(name, projectPath) {
  const existing = queryOne('SELECT id FROM projects WHERE path = ?', [projectPath]);
  if (existing) {
    runAndSave("UPDATE projects SET last_opened = datetime('now'), name = ? WHERE id = ?", [name, existing.id]);
    return existing.id;
  }
  db.run('INSERT INTO projects (name, path) VALUES (?, ?)', [name, projectPath]);
  const row = queryOne('SELECT last_insert_rowid() as id');
  const id = row.id;
  saveDb();
  return id;
}

function listProjects() {
  return queryAll(`
    SELECT p.*, ps.active_phase, ps.phase_status, ps.has_prd,
           (SELECT COUNT(*) FROM features WHERE project_id = p.id) as feature_count
    FROM projects p
    LEFT JOIN project_state ps ON ps.project_id = p.id
    ORDER BY p.last_opened DESC
  `);
}

function getProject(projectId) {
  return queryOne('SELECT * FROM projects WHERE id = ?', [projectId]);
}

function getProjectByPath(projectPath) {
  return queryOne('SELECT * FROM projects WHERE path = ?', [projectPath]);
}

function removeProject(projectId) {
  runAndSave('DELETE FROM projects WHERE id = ?', [projectId]);
}

function touchProject(projectId) {
  runAndSave("UPDATE projects SET last_opened = datetime('now') WHERE id = ?", [projectId]);
}

// --- State sync ---

function syncProjectState(projectId, state, hasPrd) {
  if (!state) {
    runAndSave(`
      INSERT INTO project_state (project_id, has_prd, synced_at)
      VALUES (?, ?, datetime('now'))
      ON CONFLICT(project_id) DO UPDATE SET has_prd = ?, synced_at = datetime('now')
    `, [projectId, hasPrd ? 1 : 0, hasPrd ? 1 : 0]);
    return;
  }

  runAndSave(`
    INSERT INTO project_state (project_id, active_phase, phase_name, phase_status,
      last_action, last_action_date, next_action, suggested_command, iteration_count, has_prd, synced_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
    ON CONFLICT(project_id) DO UPDATE SET
      active_phase = ?, phase_name = ?, phase_status = ?,
      last_action = ?, last_action_date = ?, next_action = ?,
      suggested_command = ?, iteration_count = ?, has_prd = ?, synced_at = datetime('now')
  `, [
    projectId,
    state.activePhase, state.phaseName, state.phaseStatus,
    state.lastAction, state.lastActionDate, state.nextAction,
    state.suggestedCommand, state.iterationCount, hasPrd ? 1 : 0,
    state.activePhase, state.phaseName, state.phaseStatus,
    state.lastAction, state.lastActionDate, state.nextAction,
    state.suggestedCommand, state.iterationCount, hasPrd ? 1 : 0,
  ]);
}

function syncFeatures(projectId, features) {
  // Delete features not in current list
  const currentIds = features.map(f => f.id);
  if (currentIds.length > 0) {
    // sql.js doesn't support array params in IN clause, so build it manually
    const placeholders = currentIds.map(() => '?').join(',');
    db.run(
      'DELETE FROM features WHERE project_id = ? AND feature_id NOT IN (' + placeholders + ')',
      [projectId, ...currentIds]
    );
  } else {
    db.run('DELETE FROM features WHERE project_id = ?', [projectId]);
  }

  for (const f of features) {
    const arts = JSON.stringify(f.artifacts);
    const tasks = JSON.stringify(f.tasks);
    db.run(`
      INSERT INTO features (project_id, feature_id, phase_num, name, display_name,
        status, column_name, elements, artifacts, tasks, next_command, is_active, synced_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
      ON CONFLICT(project_id, feature_id) DO UPDATE SET
        phase_num = ?, name = ?, display_name = ?,
        status = ?, column_name = ?, elements = ?,
        artifacts = ?, tasks = ?, next_command = ?,
        is_active = ?, synced_at = datetime('now')
    `, [
      projectId, f.id, f.phaseNum, f.name, f.displayName,
      f.status, f.column, f.elements, arts, tasks,
      f.nextCommand, f.isActive ? 1 : 0,
      f.phaseNum, f.name, f.displayName,
      f.status, f.column, f.elements,
      arts, tasks, f.nextCommand,
      f.isActive ? 1 : 0,
    ]);
  }

  saveDb();
}

// --- Query from DB ---

function getProjectFeatures(projectId) {
  const rows = queryAll('SELECT * FROM features WHERE project_id = ? ORDER BY phase_num', [projectId]);
  return rows.map(r => ({
    id: r.feature_id,
    phaseNum: r.phase_num,
    name: r.name,
    displayName: r.display_name,
    status: r.status,
    column: r.column_name,
    elements: r.elements,
    artifacts: JSON.parse(r.artifacts || '{}'),
    tasks: JSON.parse(r.tasks || '[]'),
    nextCommand: r.next_command,
    isActive: !!r.is_active,
  }));
}

function getProjectDbState(projectId) {
  return queryOne('SELECT * FROM project_state WHERE project_id = ?', [projectId]);
}

// --- Chat messages ---

function addMessage(projectId, featureId, taskNum, role, content) {
  db.run(`
    INSERT INTO messages (project_id, feature_id, task_num, role, content)
    VALUES (?, ?, ?, ?, ?)
  `, [projectId, featureId || null, taskNum || null, role, content]);
  const row = queryOne('SELECT last_insert_rowid() as id');
  const id = row.id;
  saveDb();
  return id;
}

function getMessages(projectId, featureId, taskNum, limit) {
  limit = limit || 50;
  if (taskNum) {
    return queryAll(`
      SELECT * FROM messages
      WHERE project_id = ? AND feature_id = ? AND task_num = ?
      ORDER BY created_at ASC LIMIT ?
    `, [projectId, featureId, taskNum, limit]);
  }
  if (featureId) {
    return queryAll(`
      SELECT * FROM messages
      WHERE project_id = ? AND feature_id = ? AND task_num IS NULL
      ORDER BY created_at ASC LIMIT ?
    `, [projectId, featureId, limit]);
  }
  return queryAll(`
    SELECT * FROM messages
    WHERE project_id = ? AND feature_id IS NULL
    ORDER BY created_at ASC LIMIT ?
  `, [projectId, limit]);
}

module.exports = {
  initDb,
  getDb,
  registerProject,
  listProjects,
  getProject,
  getProjectByPath,
  removeProject,
  touchProject,
  syncProjectState,
  syncFeatures,
  getProjectFeatures,
  getProjectDbState,
  addMessage,
  getMessages,
  DB_PATH,
};
