/**
 * CKS Board Database — SQLite persistence for multi-project hub.
 * Stores at ~/.cks/board.db. The .prd/ filesystem remains source of truth;
 * this DB is a synced index that enables persistence and cross-project access.
 */
const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');
const os = require('os');

const DB_DIR = path.join(os.homedir(), '.cks');
const DB_PATH = path.join(DB_DIR, 'board.db');

let db = null;

function getDb() {
  if (db) return db;

  if (!fs.existsSync(DB_DIR)) {
    fs.mkdirSync(DB_DIR, { recursive: true });
  }

  db = new Database(DB_PATH);
  db.pragma('journal_mode = WAL');
  db.pragma('foreign_keys = ON');

  migrate(db);
  return db;
}

function migrate(db) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      path TEXT UNIQUE NOT NULL,
      added_at TEXT DEFAULT (datetime('now')),
      last_opened TEXT DEFAULT (datetime('now'))
    );

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
    );

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
    );

    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
      feature_id TEXT,
      task_num TEXT,
      role TEXT NOT NULL DEFAULT 'user',
      content TEXT NOT NULL,
      created_at TEXT DEFAULT (datetime('now'))
    );

    CREATE INDEX IF NOT EXISTS idx_features_project ON features(project_id);
    CREATE INDEX IF NOT EXISTS idx_messages_context ON messages(project_id, feature_id, task_num);
  `);
}

// --- Project CRUD ---

function registerProject(name, projectPath) {
  const d = getDb();
  const existing = d.prepare('SELECT id FROM projects WHERE path = ?').get(projectPath);
  if (existing) {
    d.prepare("UPDATE projects SET last_opened = datetime('now'), name = ? WHERE id = ?")
      .run(name, existing.id);
    return existing.id;
  }
  const result = d.prepare('INSERT INTO projects (name, path) VALUES (?, ?)').run(name, projectPath);
  return result.lastInsertRowid;
}

function listProjects() {
  const d = getDb();
  return d.prepare(`
    SELECT p.*, ps.active_phase, ps.phase_status, ps.has_prd,
           (SELECT COUNT(*) FROM features WHERE project_id = p.id) as feature_count
    FROM projects p
    LEFT JOIN project_state ps ON ps.project_id = p.id
    ORDER BY p.last_opened DESC
  `).all();
}

function getProject(projectId) {
  return getDb().prepare('SELECT * FROM projects WHERE id = ?').get(projectId);
}

function getProjectByPath(projectPath) {
  return getDb().prepare('SELECT * FROM projects WHERE path = ?').get(projectPath);
}

function removeProject(projectId) {
  getDb().prepare('DELETE FROM projects WHERE id = ?').run(projectId);
}

function touchProject(projectId) {
  getDb().prepare("UPDATE projects SET last_opened = datetime('now') WHERE id = ?").run(projectId);
}

// --- State sync ---

function syncProjectState(projectId, state, hasPrd) {
  const d = getDb();
  if (!state) {
    d.prepare(`
      INSERT INTO project_state (project_id, has_prd, synced_at)
      VALUES (?, ?, datetime('now'))
      ON CONFLICT(project_id) DO UPDATE SET has_prd = ?, synced_at = datetime('now')
    `).run(projectId, hasPrd ? 1 : 0, hasPrd ? 1 : 0);
    return;
  }

  d.prepare(`
    INSERT INTO project_state (project_id, active_phase, phase_name, phase_status,
      last_action, last_action_date, next_action, suggested_command, iteration_count, has_prd, synced_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
    ON CONFLICT(project_id) DO UPDATE SET
      active_phase = ?, phase_name = ?, phase_status = ?,
      last_action = ?, last_action_date = ?, next_action = ?,
      suggested_command = ?, iteration_count = ?, has_prd = ?, synced_at = datetime('now')
  `).run(
    projectId,
    state.activePhase, state.phaseName, state.phaseStatus,
    state.lastAction, state.lastActionDate, state.nextAction,
    state.suggestedCommand, state.iterationCount, hasPrd ? 1 : 0,
    state.activePhase, state.phaseName, state.phaseStatus,
    state.lastAction, state.lastActionDate, state.nextAction,
    state.suggestedCommand, state.iterationCount, hasPrd ? 1 : 0
  );
}

function syncFeatures(projectId, features) {
  const d = getDb();

  const upsert = d.prepare(`
    INSERT INTO features (project_id, feature_id, phase_num, name, display_name,
      status, column_name, elements, artifacts, tasks, next_command, is_active, synced_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
    ON CONFLICT(project_id, feature_id) DO UPDATE SET
      phase_num = ?, name = ?, display_name = ?,
      status = ?, column_name = ?, elements = ?,
      artifacts = ?, tasks = ?, next_command = ?,
      is_active = ?, synced_at = datetime('now')
  `);

  const syncMany = d.transaction((feats) => {
    const currentIds = feats.map(f => f.id);
    if (currentIds.length > 0) {
      const placeholders = currentIds.map(() => '?').join(',');
      d.prepare(
        'DELETE FROM features WHERE project_id = ? AND feature_id NOT IN (' + placeholders + ')'
      ).run(projectId, ...currentIds);
    } else {
      d.prepare('DELETE FROM features WHERE project_id = ?').run(projectId);
    }

    for (const f of feats) {
      const arts = JSON.stringify(f.artifacts);
      const tasks = JSON.stringify(f.tasks);
      upsert.run(
        projectId, f.id, f.phaseNum, f.name, f.displayName,
        f.status, f.column, f.elements, arts, tasks,
        f.nextCommand, f.isActive ? 1 : 0,
        f.phaseNum, f.name, f.displayName,
        f.status, f.column, f.elements,
        arts, tasks, f.nextCommand,
        f.isActive ? 1 : 0
      );
    }
  });

  syncMany(features);
}

// --- Query from DB ---

function getProjectFeatures(projectId) {
  const rows = getDb().prepare('SELECT * FROM features WHERE project_id = ? ORDER BY phase_num')
    .all(projectId);

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
  return getDb().prepare('SELECT * FROM project_state WHERE project_id = ?').get(projectId);
}

// --- Chat messages ---

function addMessage(projectId, featureId, taskNum, role, content) {
  const result = getDb().prepare(`
    INSERT INTO messages (project_id, feature_id, task_num, role, content)
    VALUES (?, ?, ?, ?, ?)
  `).run(projectId, featureId || null, taskNum || null, role, content);
  return result.lastInsertRowid;
}

function getMessages(projectId, featureId, taskNum, limit) {
  limit = limit || 50;
  if (taskNum) {
    return getDb().prepare(`
      SELECT * FROM messages
      WHERE project_id = ? AND feature_id = ? AND task_num = ?
      ORDER BY created_at ASC LIMIT ?
    `).all(projectId, featureId, taskNum, limit);
  }
  if (featureId) {
    return getDb().prepare(`
      SELECT * FROM messages
      WHERE project_id = ? AND feature_id = ? AND task_num IS NULL
      ORDER BY created_at ASC LIMIT ?
    `).all(projectId, featureId, limit);
  }
  return getDb().prepare(`
    SELECT * FROM messages
    WHERE project_id = ? AND feature_id IS NULL
    ORDER BY created_at ASC LIMIT ?
  `).all(projectId, limit);
}

module.exports = {
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
