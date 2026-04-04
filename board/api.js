/**
 * CKS Board API — reads .prd/ filesystem, syncs to SQLite, serves JSON.
 * Multi-project hub with per-feature/task chat.
 */
const fs = require('fs');
const path = require('path');
const db = require('./db');

function findProjectRoot(startDir) {
  let dir = startDir || process.cwd();
  while (dir !== path.dirname(dir)) {
    if (fs.existsSync(path.join(dir, '.prd'))) return dir;
    dir = path.dirname(dir);
  }
  return startDir || process.cwd();
}

function safeRead(filePath) {
  try { return fs.readFileSync(filePath, 'utf-8'); } catch { return null; }
}

function parseMarkdownField(content, field) {
  const regex = new RegExp(`\\*\\*${field}:\\*\\*\\s*(.+)`, 'i');
  const match = content.match(regex);
  return match ? match[1].trim() : null;
}

function parseMarkdownTable(content, headerPattern) {
  const lines = content.split('\n');
  const headerIdx = lines.findIndex(l => l.includes(headerPattern));
  if (headerIdx === -1) return [];

  const rows = [];
  for (let i = headerIdx + 2; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line.startsWith('|')) break;
    const cells = line.split('|').filter(Boolean).map(c => c.trim());
    rows.push(cells);
  }
  return rows;
}

function getProjectName(root) {
  const pkg = safeRead(path.join(root, 'package.json'));
  if (pkg) {
    try { return JSON.parse(pkg).name; } catch {}
  }
  const claude = safeRead(path.join(root, 'CLAUDE.md'));
  if (claude) {
    const match = claude.match(/^#\s+(.+)/m);
    if (match) return match[1].trim();
  }
  return path.basename(root);
}

function getState(root) {
  const content = safeRead(path.join(root, '.prd', 'PRD-STATE.md'));
  if (!content) return null;

  return {
    lastUpdated: parseMarkdownField(content, 'Last Updated'),
    activePhase: parseMarkdownField(content, 'Active Phase'),
    phaseName: parseMarkdownField(content, 'Phase Name'),
    phaseStatus: parseMarkdownField(content, 'Phase Status'),
    lastAction: parseMarkdownField(content, 'Last Action'),
    lastActionDate: parseMarkdownField(content, 'Last Action Date'),
    nextAction: parseMarkdownField(content, 'Next Action'),
    suggestedCommand: parseMarkdownField(content, 'Suggested Command'),
    iterationCount: parseMarkdownField(content, 'Iteration Count'),
    prdStatus: parseMarkdownField(content, 'PRD Status'),
    prNumber: parseMarkdownField(content, 'PR Number'),
  };
}

function statusToColumn(status) {
  if (!status) return 'backlog';
  const s = status.toLowerCase().replace(/[^a-z_]/g, '');
  if (['not_started'].includes(s)) return 'backlog';
  if (['discovering', 'discovered', 'iterating_discover'].includes(s)) return 'discover';
  if (['designing', 'designed', 'iterating_design'].includes(s)) return 'design';
  if (['sprinting', 'sprinted', 'iterating_sprint'].includes(s)) return 'sprint';
  if (['reviewing', 'reviewed'].includes(s)) return 'review';
  if (['releasing', 'released'].includes(s)) return 'release';
  return 'backlog';
}

function buildGuidance(status, featureName, ctx) {
  const s = (status || '').toLowerCase();
  if (s === 'not_started')
    return { action: 'Start Discovery', why: 'Gather requirements \u2014 the 11 Elements define what to build and why.' };
  if (s === 'discovering')
    return { action: 'Continue Discovery', why: `${ctx.elements || '?'} elements gathered. Complete all 11 before moving to Design.` };
  if (s === 'discovered')
    return { action: 'Ready for Design', why: 'All 11 elements gathered. Design will create UX flows, API contracts, and screen specs.' };
  if (s === 'designing')
    return { action: 'Continue Design', why: 'Creating UX flows, API contracts, and component specs.' };
  if (s === 'designed')
    return { action: 'Ready to Sprint', why: ctx.sprintGoal ? `Goal: ${ctx.sprintGoal}` : `Design complete. Sprint will plan and build the implementation.` };
  if (s === 'sprinting')
    return { action: 'Sprint in Progress', why: `${ctx.tasks.length} tasks planned${ctx.sprintGoal ? '. Goal: ' + ctx.sprintGoal : ''}.` };
  if (s === 'sprinted')
    return { action: 'Ready for Review', why: 'Code merged and verified. Review will collect feedback and decide: ship, iterate, or re-scope.' };
  if (s === 'reviewing')
    return { action: 'Review in Progress', why: 'Collecting feedback, running retrospective, deciding next action.' };
  if (s === 'reviewed')
    return { action: 'Ready to Release', why: 'Approved! Release will promote through Dev \u2192 Staging \u2192 RC \u2192 Production.' };
  if (s === 'releasing')
    return { action: 'Release in Progress', why: 'Deploying through environment promotion pipeline.' };
  if (s === 'released')
    return { action: 'Shipped', why: 'Deployed to production. Run /cks:retro to capture learnings.' };
  if (s.startsWith('iterating'))
    return { action: 'Iterating', why: 'Review sent this back for another pass. Check REVIEW.md for feedback.' };
  return { action: 'Next Step', why: '' };
}

function readFeaturesFromDisk(root) {
  const phasesDir = path.join(root, '.prd', 'phases');
  if (!fs.existsSync(phasesDir)) return [];

  const entries = fs.readdirSync(phasesDir, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .sort((a, b) => a.name.localeCompare(b.name));

  const state = getState(root);

  return entries.map(dir => {
    const match = dir.name.match(/^(\d+)-(.+)$/);
    if (!match) return null;

    const phaseNum = match[1];
    const featureName = match[2];
    const featureDir = path.join(phasesDir, dir.name);

    const context = safeRead(path.join(featureDir, `${phaseNum}-CONTEXT.md`));
    const plan = safeRead(path.join(featureDir, `${phaseNum}-PLAN.md`));
    const verification = safeRead(path.join(featureDir, `${phaseNum}-VERIFICATION.md`));
    const summary = safeRead(path.join(featureDir, `${phaseNum}-SUMMARY.md`));
    const design = safeRead(path.join(featureDir, `${phaseNum}-DESIGN.md`));
    const review = safeRead(path.join(featureDir, `${phaseNum}-REVIEW.md`));

    let phaseStatus = 'not_started';
    let elements = null;

    if (context) {
      elements = parseMarkdownField(context, 'Elements');
    }

    if (state && state.activePhase === phaseNum) {
      phaseStatus = state.phaseStatus || 'not_started';
    } else {
      if (review) phaseStatus = 'reviewed';
      else if (verification || summary) phaseStatus = 'sprinted';
      else if (plan) phaseStatus = 'sprinting';
      else if (design) phaseStatus = 'designed';
      else if (context) phaseStatus = 'discovered';
      else phaseStatus = 'not_started';
    }

    const column = statusToColumn(phaseStatus);

    const artifacts = {
      context: !!context, design: !!design, plan: !!plan,
      summary: !!summary, verification: !!verification, review: !!review,
    };

    let tasks = [];
    if (plan) {
      const taskRows = parseMarkdownTable(plan, 'Task');
      tasks = taskRows.map(cells => ({
        num: cells[0], name: cells[1], type: cells[2],
        effort: cells[3], deps: cells[4] || '\u2014',
      }));
    }

    // Build command based on exact status, not just column
    // -ing statuses = resume current phase; -ed statuses = advance to next
    let nextCommand = null;
    const s = (phaseStatus || '').toLowerCase();
    if (s === 'not_started') nextCommand = `/cks:discover ${featureName}`;
    else if (s === 'discovering' || s === 'iterating_discover') nextCommand = `/cks:discover ${featureName}`;
    else if (s === 'discovered') nextCommand = `/cks:design ${featureName}`;
    else if (s === 'designing' || s === 'iterating_design') nextCommand = `/cks:design ${featureName}`;
    else if (s === 'designed') nextCommand = `/cks:sprint ${featureName}`;
    else if (s === 'sprinting' || s === 'iterating_sprint') nextCommand = `/cks:sprint ${featureName}`;
    else if (s === 'sprinted') nextCommand = `/cks:review ${featureName}`;
    else if (s === 'reviewing') nextCommand = `/cks:review ${featureName}`;
    else if (s === 'reviewed') nextCommand = `/cks:release ${featureName}`;
    else if (s === 'releasing') nextCommand = `/cks:release ${featureName}`;
    else if (s === 'released') nextCommand = null;

    // Extract rich content for previews
    const problem = context ? parseMarkdownField(context, 'Problem') : null;
    const value = context ? parseMarkdownField(context, 'Value delivered') : null;
    const sprintGoal = plan ? parseMarkdownField(plan, 'Sprint Goal') : null;
    const effort = plan ? parseMarkdownField(plan, 'Estimated Effort') : null;

    // Phase progress: which of the 5 phases are done
    const phaseProgress = {
      discover: !!context,
      design: !!design,
      sprint: !!(summary || verification),
      review: !!review,
      release: phaseStatus === 'released',
    };
    const phasesComplete = Object.values(phaseProgress).filter(Boolean).length;

    // Smart guidance: explain WHY the next step matters
    const guidance = buildGuidance(phaseStatus, featureName, {
      elements, artifacts, tasks, phasesComplete, sprintGoal,
    });

    // Needs attention flag: phase is done, next action waiting
    const needsAttention = phaseStatus.match(/^(discovered|designed|sprinted|reviewed)$/);

    return {
      id: dir.name, phaseNum, name: featureName,
      displayName: featureName.replace(/-/g, ' '),
      status: phaseStatus, column, elements, artifacts, tasks, nextCommand,
      isActive: state && state.activePhase === phaseNum,
      problem, value, sprintGoal, effort,
      phaseProgress, phasesComplete,
      guidance, needsAttention: !!needsAttention,
    };
  }).filter(Boolean);
}

/**
 * Sync a project's .prd/ files into the database.
 * Called on server start and on refresh.
 */
function syncProject(projectPath) {
  const name = getProjectName(projectPath);
  const projectId = db.registerProject(name, projectPath);
  const hasPrd = fs.existsSync(path.join(projectPath, '.prd'));
  const state = getState(projectPath);
  const features = readFeaturesFromDisk(projectPath);

  db.syncProjectState(projectId, state, hasPrd);
  db.syncFeatures(projectId, features);
  db.touchProject(projectId);

  return projectId;
}

// --- Request body parser (for POST) ---

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk;
      if (body.length > 1e6) { req.destroy(); reject(new Error('Body too large')); }
    });
    req.on('end', () => {
      try { resolve(JSON.parse(body)); } catch { resolve({}); }
    });
  });
}

// --- Route handler ---

async function handleApi(req, currentProjectRoot) {
  const url = new URL(req.url, 'http://localhost');
  const pathname = url.pathname;
  const method = req.method;

  // --- Multi-project endpoints ---

  if (pathname === '/api/projects' && method === 'GET') {
    return db.listProjects();
  }

  if (pathname === '/api/projects/sync' && method === 'POST') {
    const body = await parseBody(req);
    const projectPath = body.path || currentProjectRoot;
    if (!projectPath || !fs.existsSync(projectPath)) {
      return { error: 'Invalid project path' };
    }
    const projectId = syncProject(projectPath);
    return { projectId, synced: true };
  }

  if (pathname === '/api/projects/remove' && method === 'POST') {
    const body = await parseBody(req);
    if (body.projectId) {
      db.removeProject(body.projectId);
      return { removed: true };
    }
    return { error: 'Missing projectId' };
  }

  // --- Add project (with validation) ---

  if (pathname === '/api/projects/add' && method === 'POST') {
    const body = await parseBody(req);
    const projectPath = body.path;
    if (!projectPath) return { error: 'Path is required' };

    const resolved = path.resolve(projectPath);
    if (!fs.existsSync(resolved)) return { error: 'Path does not exist: ' + resolved };

    const stat = fs.statSync(resolved);
    if (!stat.isDirectory()) return { error: 'Path is not a directory' };

    const projectId = syncProject(resolved);
    return { projectId, path: resolved, synced: true };
  }

  // --- Per-project endpoints (use ?projectId=N or fall back to current) ---

  const projectId = parseInt(url.searchParams.get('projectId'), 10) || null;

  if (pathname === '/api/state') {
    if (projectId) {
      const project = db.getProject(projectId);
      const state = db.getProjectDbState(projectId);
      return {
        project: project ? project.name : 'Unknown',
        state: state || null,
        hasPrd: state ? !!state.has_prd : false,
        projectId,
      };
    }
    // Fallback: read from disk (current project)
    return {
      project: getProjectName(currentProjectRoot),
      state: getState(currentProjectRoot),
      hasPrd: fs.existsSync(path.join(currentProjectRoot, '.prd')),
    };
  }

  if (pathname === '/api/features') {
    // Always read from disk for rich data (guidance, progress, needsAttention)
    if (projectId) {
      const project = db.getProject(projectId);
      if (project) return readFeaturesFromDisk(project.path);
    }
    return readFeaturesFromDisk(currentProjectRoot);
  }

  if (pathname.startsWith('/api/feature/')) {
    const featureId = pathname.split('/api/feature/')[1].replace(/\/.*$/, '');
    if (projectId) {
      const features = db.getProjectFeatures(projectId);
      return features.find(f => f.id === featureId) || null;
    }
    const features = readFeaturesFromDisk(currentProjectRoot);
    return features.find(f => f.id === featureId) || null;
  }

  // --- Chat endpoints ---

  if (pathname === '/api/messages' && method === 'GET') {
    const featureId = url.searchParams.get('featureId') || null;
    const taskNum = url.searchParams.get('taskNum') || null;
    const pid = projectId || 1;
    return db.getMessages(pid, featureId, taskNum);
  }

  if (pathname === '/api/messages' && method === 'POST') {
    const body = await parseBody(req);
    const pid = body.projectId || projectId || 1;
    const msgId = db.addMessage(
      pid, body.featureId || null, body.taskNum || null,
      body.role || 'user', body.content || ''
    );
    return { id: msgId, saved: true };
  }

  // --- Activity feed across all projects ---

  if (pathname === '/api/activity') {
    const limit = parseInt(url.searchParams.get('limit') || '30', 10);
    const allProjects = db.listProjects();
    const allEvents = [];

    for (const p of allProjects) {
      const logFile = path.join(p.path, '.prd', 'logs', 'lifecycle.jsonl');
      const content = safeRead(logFile);
      if (!content) continue;
      const lines = content.trim().split('\n').filter(Boolean);
      for (const line of lines.slice(-limit)) {
        try {
          const evt = JSON.parse(line);
          evt._project = p.name;
          evt._projectId = p.id;
          allEvents.push(evt);
        } catch {}
      }
    }

    // Sort by timestamp descending, take latest N
    allEvents.sort((a, b) => (b.timestamp || '').localeCompare(a.timestamp || ''));
    return allEvents.slice(0, limit);
  }

  // --- Notifications: pending actions across all projects ---

  if (pathname === '/api/notifications') {
    const allProjects = db.listProjects();
    const notifs = [];

    for (const p of allProjects) {
      // Read from disk to get rich fields (guidance, needsAttention)
      const feats = readFeaturesFromDisk(p.path);
      for (const f of feats) {
        if (f.needsAttention) {
          notifs.push({
            projectId: p.id,
            projectName: p.name,
            featureId: f.id,
            featureName: f.displayName,
            action: f.guidance ? f.guidance.action : 'Action needed',
            why: f.guidance ? f.guidance.why : '',
            command: f.nextCommand,
            status: f.status,
          });
        }
      }
    }
    return notifs;
  }

  // --- Legacy endpoints ---

  if (pathname === '/api/roadmap') {
    const content = safeRead(path.join(currentProjectRoot, '.prd', 'PRD-ROADMAP.md'));
    if (!content) return null;
    const sections = {};
    let currentSection = null;
    for (const line of content.split('\n')) {
      if (line.startsWith('## ')) {
        currentSection = line.replace('## ', '').trim().toLowerCase();
        sections[currentSection] = [];
      } else if (currentSection && line.trim()) {
        sections[currentSection].push(line.trim());
      }
    }
    return sections;
  }

  if (pathname === '/api/logs') {
    const logFile = path.join(currentProjectRoot, '.prd', 'logs', 'lifecycle.jsonl');
    const content = safeRead(logFile);
    if (!content) return [];
    const limit = parseInt(url.searchParams.get('limit') || '20', 10);
    const lines = content.trim().split('\n').filter(Boolean);
    return lines.slice(-limit).reverse().map(line => {
      try { return JSON.parse(line); } catch { return null; }
    }).filter(Boolean);
  }

  return null;
}

module.exports = { handleApi, findProjectRoot, syncProject, readFeaturesFromDisk, getState };
