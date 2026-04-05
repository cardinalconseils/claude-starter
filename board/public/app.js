/* CKS Board — Multi-Project Command Center */

const COLUMNS = [
  { id: 'backlog', label: 'Backlog', phase: 'backlog' },
  { id: 'discover', label: 'Discover', phase: 'discover' },
  { id: 'design', label: 'Design', phase: 'design' },
  { id: 'sprint', label: 'Sprint', phase: 'sprint' },
  { id: 'review', label: 'Review', phase: 'review' },
  { id: 'release', label: 'Release', phase: 'release' },
];

const PHASE_KEYS = ['discover', 'design', 'sprint', 'review', 'release'];

let projects = [];
let activeProjectId = null;
let features = [];
let projectState = {};
let notifications = [];

let panelOpen = false;
let activeTab = 'chat';
let chatContext = { projectId: null, featureId: null, taskNum: null };

function esc(str) {
  const d = document.createElement('div');
  d.textContent = str || '';
  return d.innerHTML;
}

function getAuthHeaders() {
  var token = localStorage.getItem('cks-auth-token');
  var headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = 'Bearer ' + token;
  return headers;
}

async function fetchJSON(url) {
  try {
    const r = await fetch(url, { headers: getAuthHeaders() });
    if (r.status === 401) { handleAuthRequired(); return null; }
    if (!r.ok) return null;
    return r.json();
  } catch { return null; }
}

async function postJSON(url, body) {
  try {
    const r = await fetch(url, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(body),
    });
    if (r.status === 401) { handleAuthRequired(); return { error: 'Unauthorized' }; }
    return r.json();
  } catch { return { error: 'Server unreachable' }; }
}

function handleAuthRequired() {
  // Extract token from URL if present (redirect from login page)
  var params = new URLSearchParams(window.location.search);
  var token = params.get('token');
  if (token) {
    localStorage.setItem('cks-auth-token', token);
    // Clean URL
    window.history.replaceState({}, '', '/');
    location.reload();
    return;
  }
  showToast('Authentication required. Check your terminal for the token.');
}

// ═══ Projects Sidebar ═══

async function loadProjects() {
  projects = await fetchJSON('/api/projects') || [];
  notifications = await fetchJSON('/api/notifications') || [];
  renderSidebar();
  updateNotificationBadges();
  if (!activeProjectId && projects.length > 0) {
    activeProjectId = projects[0].id;
  }
}

function renderSidebar() {
  const list = document.getElementById('project-list');
  list.textContent = '';

  if (projects.length === 0) {
    const empty = document.createElement('div');
    empty.className = 'panel-empty';
    empty.textContent = 'No projects linked yet';
    list.appendChild(empty);
    return;
  }

  projects.forEach(p => {
    const alertCount = notifications.filter(n => n.projectId === p.id).length;
    const item = document.createElement('div');
    item.className = 'sidebar-project' + (p.id === activeProjectId ? ' active' : '') + (alertCount > 0 ? ' has-alert' : '');
    item.addEventListener('click', () => selectProject(p.id));

    const dot = document.createElement('div');
    dot.className = 'sidebar-project-dot';
    item.appendChild(dot);

    const info = document.createElement('div');
    info.className = 'sidebar-project-info';

    const name = document.createElement('div');
    name.className = 'sidebar-project-name';
    name.textContent = p.name;
    info.appendChild(name);

    const meta = document.createElement('div');
    meta.className = 'sidebar-project-meta';
    const count = p.feature_count || 0;
    meta.textContent = count + ' feature' + (count !== 1 ? 's' : '');

    if (alertCount > 0) {
      const badge = document.createElement('span');
      badge.className = 'sidebar-project-alert-badge';
      badge.textContent = alertCount + ' action' + (alertCount > 1 ? 's' : '');
      meta.appendChild(badge);
    }

    info.appendChild(meta);
    item.appendChild(info);

    const removeBtn = document.createElement('button');
    removeBtn.className = 'sidebar-project-remove';
    removeBtn.textContent = '\u00d7';
    removeBtn.addEventListener('click', (e) => { e.stopPropagation(); removeProject(p.id); });
    item.appendChild(removeBtn);

    list.appendChild(item);
  });
}

function updateNotificationBadges() {
  const bell = document.getElementById('notification-bell');
  const bellBadge = document.getElementById('bell-badge');
  const tabBadge = document.getElementById('tab-alerts-badge');
  const count = notifications.length;

  if (count > 0) {
    bell.classList.add('has-alerts');
    bellBadge.textContent = count;
    bellBadge.style.display = '';
    tabBadge.textContent = count;
    tabBadge.style.display = '';
  } else {
    bell.classList.remove('has-alerts');
    bellBadge.style.display = 'none';
    tabBadge.style.display = 'none';
  }
}

async function selectProject(projectId) {
  activeProjectId = projectId;
  renderSidebar();
  await refreshBoard();
}

async function removeProject(projectId) {
  await postJSON('/api/projects/remove', { projectId });
  if (activeProjectId === projectId) activeProjectId = null;
  await loadProjects();
  if (projects.length > 0 && !activeProjectId) await selectProject(projects[0].id);
  else { features = []; renderBoard(); renderHeader(); }
}

// ═══ Board ═══

async function refreshBoard() {
  if (!activeProjectId) return;
  await postJSON('/api/projects/sync', { projectId: activeProjectId });

  const [stateData, featuresData] = await Promise.all([
    fetchJSON('/api/state?projectId=' + activeProjectId),
    fetchJSON('/api/features?projectId=' + activeProjectId),
  ]);

  projectState = stateData || {};
  features = featuresData || [];
  renderHeader();
  renderBoard();
}

async function refresh() {
  await loadProjects();
  if (activeProjectId) await refreshBoard();
}

function renderHeader() {
  document.getElementById('project-name').textContent = projectState.project || 'Select a project';

  const phaseEl = document.getElementById('phase-status');
  if (projectState.state && projectState.state.phase_status) {
    phaseEl.textContent = (projectState.state.phase_name || '') + ' \u2014 ' + (projectState.state.phase_status || '').replace(/_/g, ' ');
    phaseEl.style.display = '';
  } else {
    phaseEl.style.display = 'none';
  }

  const statsEl = document.getElementById('stats');
  statsEl.textContent = '';
  if (!features.length) return;

  const total = features.length;
  const active = features.filter(f => f.status && f.status.endsWith('ing')).length;
  const waiting = features.filter(f => f.needsAttention).length;

  [[total, 'features'], [active, 'active'], [waiting, 'waiting']].forEach(([val, label]) => {
    const span = document.createElement('span');
    const v = document.createElement('span');
    v.className = 'stat-value';
    v.textContent = val;
    span.appendChild(v);
    span.appendChild(document.createTextNode(' ' + label));
    statsEl.appendChild(span);
  });
}

function renderBoard() {
  const board = document.getElementById('board');
  board.textContent = '';

  if (!activeProjectId) {
    board.appendChild(makeEmpty('Select a project', 'Choose from the sidebar or link a new project.'));
    return;
  }

  if (features.length === 0) {
    const empty = makeEmpty('No features yet', 'Create your first feature to see it on the board.');
    const btn = document.createElement('button');
    btn.className = 'btn btn-accent';
    btn.style.marginTop = '12px';
    btn.textContent = '+ New Feature';
    btn.addEventListener('click', showNewFeatureDialog);
    empty.appendChild(btn);
    board.appendChild(empty);
    return;
  }

  COLUMNS.forEach(col => {
    const colFeatures = features.filter(f => f.column === col.id);
    const colEl = document.createElement('div');
    colEl.className = 'column';
    colEl.dataset.phase = col.phase;

    const header = document.createElement('div');
    header.className = 'column-header';
    const title = document.createElement('div');
    title.className = 'column-title';
    const dot = document.createElement('span');
    dot.className = 'column-dot';
    title.appendChild(dot);
    title.appendChild(document.createTextNode(col.label));
    header.appendChild(title);
    const count = document.createElement('span');
    count.className = 'column-count';
    count.textContent = colFeatures.length;
    header.appendChild(count);
    colEl.appendChild(header);

    const cards = document.createElement('div');
    cards.className = 'column-cards';
    colFeatures.forEach(f => cards.appendChild(createCard(f)));
    colEl.appendChild(cards);
    board.appendChild(colEl);
  });
}

function makeEmpty(title, desc) {
  const div = document.createElement('div');
  div.className = 'empty-state';
  const h = document.createElement('h2');
  h.textContent = title;
  div.appendChild(h);
  const p = document.createElement('p');
  p.textContent = desc;
  div.appendChild(p);
  return div;
}

function createCard(feature) {
  const card = document.createElement('div');
  card.className = 'card' + (feature.needsAttention ? ' needs-attention' : '');

  // Click to expand, double-click for detail modal
  card.addEventListener('click', function(e) {
    // Don't expand if clicking a button
    if (e.target.closest('.card-btn') || e.target.closest('.card-actions')) return;
    card.classList.toggle('expanded');
  });
  card.addEventListener('dblclick', function() { openDetail(feature.id); });

  // Top: name + status badge (always visible)
  const top = document.createElement('div');
  top.className = 'card-top';

  const name = document.createElement('div');
  name.className = 'card-name';
  name.textContent = feature.displayName;
  top.appendChild(name);

  const badge = document.createElement('span');
  badge.className = 'card-phase-badge';
  if (feature.isActive) { badge.dataset.status = 'active'; badge.textContent = 'Active'; }
  else if (feature.needsAttention) { badge.dataset.status = 'waiting'; badge.textContent = 'Action needed'; }
  else if (feature.status === 'released') { badge.dataset.status = 'done'; badge.textContent = 'Shipped'; }
  else { badge.style.display = 'none'; }
  top.appendChild(badge);
  card.appendChild(top);

  // Phase progress dots (always visible)
  const progress = document.createElement('div');
  progress.className = 'card-progress';
  PHASE_KEYS.forEach(pk => {
    const dot = document.createElement('div');
    dot.className = 'progress-dot' + (feature.phaseProgress && feature.phaseProgress[pk] ? ' filled' : '');
    dot.dataset.phase = pk;
    dot.title = pk;
    progress.appendChild(dot);
  });
  card.appendChild(progress);

  // ─── Expandable section (hidden by default, shown on click) ───
  const expandable = document.createElement('div');
  expandable.className = 'card-expandable';

  // Problem / value preview
  if (feature.problem) {
    const desc = document.createElement('div');
    desc.className = 'card-description';
    desc.textContent = feature.problem;
    expandable.appendChild(desc);
  }

  // Smart guidance
  if (feature.guidance && feature.guidance.action) {
    const guide = document.createElement('div');
    guide.className = 'card-guidance';

    const action = document.createElement('div');
    action.className = 'card-guidance-action';
    action.textContent = feature.guidance.action;
    guide.appendChild(action);

    if (feature.guidance.why) {
      const why = document.createElement('div');
      why.className = 'card-guidance-why';
      why.textContent = feature.guidance.why;
      guide.appendChild(why);
    }
    expandable.appendChild(guide);
  }

  // Footer: meta + actions
  const footer = document.createElement('div');
  footer.className = 'card-footer';

  const meta = document.createElement('div');
  meta.className = 'card-meta';
  const artCount = Object.values(feature.artifacts || {}).filter(Boolean).length;
  meta.textContent = 'P' + feature.phaseNum + ' \u00b7 ' + artCount + '/6';
  if (feature.tasks && feature.tasks.length > 0) {
    meta.textContent += ' \u00b7 ' + feature.tasks.length + ' tasks';
  }
  footer.appendChild(meta);

  const actions = document.createElement('div');
  actions.className = 'card-actions';

  if (feature.nextCommand) {
    const runBtn = document.createElement('button');
    runBtn.className = 'card-btn card-btn-primary';
    runBtn.textContent = '\u25b6 ' + feature.nextCommand;
    runBtn.title = 'Run live in the board';
    runBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      runSession(activeProjectId, feature.nextCommand, feature.displayName + ': ' + feature.nextCommand);
    });
    actions.appendChild(runBtn);
  }

  const detailBtn = document.createElement('button');
  detailBtn.className = 'card-btn';
  detailBtn.textContent = '\u2197';
  detailBtn.title = 'Open detail';
  detailBtn.addEventListener('click', function(e) { e.stopPropagation(); openDetail(feature.id); });
  actions.appendChild(detailBtn);

  const chatBtn = document.createElement('button');
  chatBtn.className = 'card-btn';
  chatBtn.textContent = '\ud83d\udcac';
  chatBtn.title = 'Notes & chat';
  chatBtn.addEventListener('click', function(e) {
    e.stopPropagation();
    openChat(activeProjectId, feature.id, null, feature.displayName);
  });
  actions.appendChild(chatBtn);

  footer.appendChild(actions);
  expandable.appendChild(footer);
  card.appendChild(expandable);

  return card;
}

// ═══ Feature Detail Modal ═══

function openDetail(featureId) {
  const f = features.find(x => x.id === featureId);
  if (!f) return;

  const modal = document.getElementById('modal');
  modal.textContent = '';

  // Header
  const header = document.createElement('div');
  header.className = 'modal-header';
  const title = document.createElement('div');
  title.className = 'modal-title';
  title.textContent = f.displayName;
  header.appendChild(title);
  const close = document.createElement('button');
  close.className = 'modal-close';
  close.textContent = '\u00d7';
  close.addEventListener('click', closeModal);
  header.appendChild(close);
  modal.appendChild(header);

  // Progress bar
  const prog = document.createElement('div');
  prog.className = 'card-progress';
  prog.style.marginBottom = '16px';
  PHASE_KEYS.forEach(pk => {
    const dot = document.createElement('div');
    dot.className = 'progress-dot' + (f.phaseProgress && f.phaseProgress[pk] ? ' filled' : '');
    dot.dataset.phase = pk;
    dot.title = pk;
    dot.style.height = '5px';
    prog.appendChild(dot);
  });
  modal.appendChild(prog);

  // Guidance banner
  if (f.guidance) {
    const banner = document.createElement('div');
    banner.className = 'card-guidance';
    banner.style.marginBottom = '16px';
    const a = document.createElement('div');
    a.className = 'card-guidance-action';
    a.style.fontSize = '14px';
    a.textContent = f.guidance.action;
    banner.appendChild(a);
    if (f.guidance.why) {
      const w = document.createElement('div');
      w.className = 'card-guidance-why';
      w.style.fontSize = '12px';
      w.textContent = f.guidance.why;
      banner.appendChild(w);
    }
    modal.appendChild(banner);
  }

  // Info grid
  addSection(modal, 'Details', () => {
    const grid = document.createElement('div');
    grid.style.cssText = 'display: grid; grid-template-columns: 1fr 1fr; gap: 8px; font-size: 13px;';
    const items = [
      ['Phase', f.phaseNum],
      ['Status', (f.status || '').replace(/_/g, ' ')],
      ['Elements', f.elements || '\u2014'],
      ['Effort', f.effort || '\u2014'],
    ];
    if (f.problem) items.push(['Problem', f.problem]);
    if (f.value) items.push(['Value', f.value]);
    if (f.sprintGoal) items.push(['Sprint Goal', f.sprintGoal]);

    items.forEach(([label, val]) => {
      const item = document.createElement('div');
      item.innerHTML = '<span style="color:var(--text-dim)">' + esc(label) + ':</span> ' + esc(val);
      grid.appendChild(item);
    });
    return grid;
  });

  // Artifacts
  addSection(modal, 'Artifacts', () => {
    const grid = document.createElement('div');
    grid.className = 'artifacts-grid';
    Object.entries(f.artifacts || {}).forEach(([n, exists]) => {
      const art = document.createElement('div');
      art.className = 'artifact ' + (exists ? 'exists' : 'missing');
      art.textContent = (exists ? '\u2713' : '\u2013') + ' ' + n;
      grid.appendChild(art);
    });
    return grid;
  });

  // Tasks
  if (f.tasks && f.tasks.length > 0) {
    addSection(modal, 'Sprint Tasks (' + f.tasks.length + ')', () => {
      const list = document.createElement('div');
      list.className = 'task-list';
      f.tasks.forEach(t => {
        const item = document.createElement('div');
        item.className = 'task-item';
        item.appendChild(Object.assign(document.createElement('span'), { className: 'task-num', textContent: '#' + t.num }));
        item.appendChild(Object.assign(document.createElement('span'), { className: 'task-name', textContent: t.name }));
        item.appendChild(Object.assign(document.createElement('span'), { className: 'task-type', textContent: t.type }));
        item.appendChild(Object.assign(document.createElement('span'), { className: 'task-effort', textContent: t.effort }));

        const chatIcon = document.createElement('span');
        chatIcon.className = 'task-chat-icon';
        chatIcon.textContent = '\ud83d\udcac';
        chatIcon.addEventListener('click', (e) => {
          e.stopPropagation();
          closeModal();
          openChat(activeProjectId, f.id, t.num, f.displayName + ' > #' + t.num + ' ' + t.name);
        });
        item.appendChild(chatIcon);
        list.appendChild(item);
      });
      return list;
    });
  }

  // Actions
  addSection(modal, 'Actions', () => {
    const row = document.createElement('div');
    row.style.cssText = 'display: flex; gap: 8px; flex-wrap: wrap;';

    if (f.nextCommand) {
      const btn = document.createElement('button');
      btn.className = 'btn btn-accent';
      btn.textContent = '\u25b6 Run: ' + f.nextCommand;
      btn.addEventListener('click', () => {
        closeModal();
        runSession(activeProjectId, f.nextCommand, f.displayName + ': ' + f.nextCommand);
      });
      row.appendChild(btn);
    }

    const chatBtn = document.createElement('button');
    chatBtn.className = 'btn';
    chatBtn.textContent = '\ud83d\udcac Open Chat';
    chatBtn.addEventListener('click', () => { closeModal(); openChat(activeProjectId, f.id, null, f.displayName); });
    row.appendChild(chatBtn);

    return row;
  });

  document.getElementById('modal-overlay').classList.add('open');
}

function addSection(parent, title, contentFn) {
  const section = document.createElement('div');
  section.className = 'modal-section';
  const h = document.createElement('h3');
  h.textContent = title;
  section.appendChild(h);
  section.appendChild(contentFn());
  parent.appendChild(section);
}

function closeModal(e) {
  if (e && e.target !== e.currentTarget) return;
  document.getElementById('modal-overlay').classList.remove('open');
}

// ═══ Right Panel (Chat / Activity / Notifications) ═══

function openPanel(tab) {
  activeTab = tab || 'chat';
  document.getElementById('right-panel').classList.add('open');
  panelOpen = true;
  switchTab(activeTab);
}

function closePanel() {
  document.getElementById('right-panel').classList.remove('open');
  panelOpen = false;
}

function switchTab(tab) {
  activeTab = tab;
  document.querySelectorAll('.panel-tab').forEach(t => t.classList.toggle('active', t.dataset.tab === tab));
  document.getElementById('panel-session').style.display = tab === 'session' ? '' : 'none';
  document.getElementById('panel-chat').style.display = tab === 'chat' ? '' : 'none';
  document.getElementById('panel-activity').style.display = tab === 'activity' ? '' : 'none';
  document.getElementById('panel-logs').style.display = tab === 'logs' ? '' : 'none';
  document.getElementById('panel-notifications').style.display = tab === 'notifications' ? '' : 'none';

  // Show/hide session tab based on whether sessions exist
  const sessionTab = document.getElementById('tab-session');
  sessionTab.style.display = activeSessions && activeSessions.size > 0 ? '' : 'none';

  if (tab === 'session' && viewingSessionId) renderSessionPanel();
  if (tab === 'activity') loadActivity();
  if (tab === 'logs') loadLogs();
  if (tab === 'notifications') renderNotifications();
}

// Chat
async function openChat(projectId, featureId, taskNum, label) {
  chatContext = { projectId, featureId, taskNum };
  document.getElementById('chat-context').textContent = label || 'Project Chat';
  var exportBtn = document.getElementById('export-notes-btn');
  exportBtn.style.display = featureId ? '' : 'none';
  openPanel('chat');
  await loadMessages();
  document.getElementById('chat-input').focus();
}

async function exportNotesToRepo() {
  if (!chatContext.featureId) { showToast('Select a feature first'); return; }
  var result = await postJSON('/api/export-notes', {
    projectId: chatContext.projectId || activeProjectId,
    featureId: chatContext.featureId,
  });
  if (result && result.exported) {
    showToast('Exported ' + result.count + ' notes to BOARD-NOTES.md');
  } else {
    showToast('Export failed');
  }
}

async function loadMessages() {
  const p = new URLSearchParams();
  if (chatContext.projectId) p.set('projectId', chatContext.projectId);
  if (chatContext.featureId) p.set('featureId', chatContext.featureId);
  if (chatContext.taskNum) p.set('taskNum', chatContext.taskNum);
  const msgs = await fetchJSON('/api/messages?' + p.toString()) || [];
  const container = document.getElementById('chat-messages');
  container.textContent = '';

  if (msgs.length === 0) {
    const empty = document.createElement('div');
    empty.className = 'panel-empty';
    empty.textContent = 'No notes yet. Add context, decisions, or blockers.';
    container.appendChild(empty);
    return;
  }

  msgs.forEach(m => {
    const bubble = document.createElement('div');
    bubble.className = 'chat-msg ' + (m.role === 'user' ? 'user' : 'system');
    bubble.textContent = m.content;
    const time = document.createElement('div');
    time.className = 'chat-msg-time';
    time.textContent = new Date(m.created_at + 'Z').toLocaleString();
    bubble.appendChild(time);
    container.appendChild(bubble);
  });
  container.scrollTop = container.scrollHeight;
}

async function sendMessage() {
  const input = document.getElementById('chat-input');
  const content = input.value.trim();
  if (!content) return;
  await postJSON('/api/messages', {
    projectId: chatContext.projectId, featureId: chatContext.featureId,
    taskNum: chatContext.taskNum, role: 'user', content,
  });
  input.value = '';
  await loadMessages();
}

// Activity
async function loadActivity() {
  const events = await fetchJSON('/api/activity?limit=30') || [];
  const feed = document.getElementById('activity-feed');
  feed.textContent = '';

  if (events.length === 0) {
    const empty = document.createElement('div');
    empty.className = 'panel-empty';
    empty.textContent = 'No lifecycle events yet.';
    feed.appendChild(empty);
    return;
  }

  events.forEach(evt => {
    const item = document.createElement('div');
    item.className = 'activity-item';
    const dot = document.createElement('div');
    dot.className = 'activity-dot';
    item.appendChild(dot);
    const text = document.createElement('div');
    text.className = 'activity-text';
    const proj = document.createElement('span');
    proj.className = 'activity-project';
    proj.textContent = evt._project || 'Unknown';
    text.appendChild(proj);
    text.appendChild(document.createTextNode(' \u2014 ' + (evt.event || evt.message || JSON.stringify(evt))));
    if (evt.timestamp) {
      const time = document.createElement('div');
      time.className = 'activity-time';
      time.textContent = evt.timestamp;
      text.appendChild(time);
    }
    item.appendChild(text);
    feed.appendChild(item);
  });
}

// Logs
async function loadLogs() {
  var filter = document.getElementById('logs-filter').value;
  var list = document.getElementById('logs-list');
  list.textContent = '';

  // Fetch both sources in parallel
  var [lifecycleEvents, serverLogs] = await Promise.all([
    (filter === 'all' || filter === 'lifecycle' || filter === 'errors') ? fetchJSON('/api/activity?limit=50') : Promise.resolve([]),
    (filter === 'all' || filter === 'requests' || filter === 'errors') ? fetchJSON('/api/server-logs?limit=100') : Promise.resolve([]),
  ]);

  lifecycleEvents = lifecycleEvents || [];
  serverLogs = serverLogs || [];

  // Merge and sort by timestamp
  var allLogs = [];

  lifecycleEvents.forEach(function(evt) {
    allLogs.push({
      timestamp: evt.timestamp || evt.date || '',
      type: 'lifecycle',
      level: (evt.event || '').includes('error') ? 'error' : 'info',
      message: (evt._project ? evt._project + ' — ' : '') + (evt.event || evt.message || JSON.stringify(evt)),
      detail: evt.feature || evt.phase || '',
    });
  });

  serverLogs.forEach(function(log) {
    if (filter === 'errors' && log.status < 400) return;
    allLogs.push({
      timestamp: log.timestamp,
      type: 'request',
      level: log.status >= 400 ? 'error' : log.status >= 300 ? 'warn' : 'info',
      message: log.method + ' ' + log.path + ' — ' + log.status + ' (' + log.duration + 'ms)',
      detail: '',
    });
  });

  allLogs.sort(function(a, b) { return (b.timestamp || '').localeCompare(a.timestamp || ''); });

  if (allLogs.length === 0) {
    var empty = document.createElement('div');
    empty.className = 'panel-empty';
    empty.textContent = 'No logs yet.';
    list.appendChild(empty);
    return;
  }

  allLogs.forEach(function(log) {
    var item = document.createElement('div');
    item.className = 'log-item log-' + log.level;

    var time = document.createElement('span');
    time.className = 'log-time';
    time.textContent = log.timestamp ? new Date(log.timestamp).toLocaleTimeString() : '';
    item.appendChild(time);

    var badge = document.createElement('span');
    badge.className = 'log-badge log-badge-' + log.type;
    badge.textContent = log.type === 'lifecycle' ? 'LC' : 'REQ';
    item.appendChild(badge);

    var msg = document.createElement('span');
    msg.className = 'log-message';
    msg.textContent = log.message;
    item.appendChild(msg);

    if (log.detail) {
      var detail = document.createElement('span');
      detail.className = 'log-detail';
      detail.textContent = log.detail;
      item.appendChild(detail);
    }

    list.appendChild(item);
  });
}

// Notifications
function renderNotifications() {
  const list = document.getElementById('notifications-list');
  list.textContent = '';

  if (notifications.length === 0) {
    const empty = document.createElement('div');
    empty.className = 'panel-empty';
    empty.textContent = 'All clear \u2014 no actions needed.';
    list.appendChild(empty);
    return;
  }

  notifications.forEach(n => {
    const item = document.createElement('div');
    item.className = 'notification-item';
    item.addEventListener('click', () => {
      selectProject(n.projectId);
      closePanel();
    });

    const proj = document.createElement('div');
    proj.className = 'notification-project';
    proj.textContent = n.projectName + ' \u203a ' + n.featureName;
    item.appendChild(proj);

    const action = document.createElement('div');
    action.className = 'notification-action';
    action.textContent = n.action;
    item.appendChild(action);

    const why = document.createElement('div');
    why.className = 'notification-why';
    why.textContent = n.why;
    item.appendChild(why);

    if (n.command) {
      const cmd = document.createElement('div');
      cmd.className = 'notification-command';
      cmd.textContent = n.command;
      cmd.addEventListener('click', (e) => { e.stopPropagation(); copyForClaude(n.command); });
      item.appendChild(cmd);
    }

    list.appendChild(item);
  });
}

// ═══ New Feature / New Project Dialogs ═══

function showNewFeatureDialog() {
  const modal = document.getElementById('modal');
  modal.textContent = '';

  const header = document.createElement('div');
  header.className = 'modal-header';
  header.appendChild(Object.assign(document.createElement('div'), { className: 'modal-title', textContent: 'New Feature' }));
  const close = document.createElement('button');
  close.className = 'modal-close';
  close.textContent = '\u00d7';
  close.addEventListener('click', closeModal);
  header.appendChild(close);
  modal.appendChild(header);

  addSection(modal, 'Describe your feature', () => {
    const wrap = document.createElement('div');

    const hint = document.createElement('p');
    hint.style.cssText = 'font-size: 12px; color: var(--text-muted); margin-bottom: 10px; line-height: 1.4;';
    hint.textContent = 'Describe what you want to build. CKS will take it through Discovery \u2192 Design \u2192 Sprint \u2192 Review \u2192 Release.';
    wrap.appendChild(hint);

    const input = document.createElement('textarea');
    input.className = 'chat-input';
    input.style.cssText = 'width: 100%; min-height: 80px; margin-bottom: 12px;';
    input.placeholder = 'e.g., Add user authentication with JWT tokens and OAuth2 social login...';
    wrap.appendChild(input);

    const row = document.createElement('div');
    row.style.cssText = 'display: flex; gap: 8px;';

    const createBtn = document.createElement('button');
    createBtn.className = 'btn btn-accent';
    createBtn.textContent = 'Create Feature';
    createBtn.addEventListener('click', () => {
      const brief = input.value.trim();
      if (!brief) { showToast('Describe the feature first'); return; }
      const cmd = '/cks:new "' + brief.replace(/"/g, '\\"') + '"';
      closeModal();
      runSession(activeProjectId, cmd, 'New Feature: ' + brief.slice(0, 50));
    });
    row.appendChild(createBtn);

    wrap.appendChild(row);
    return wrap;
  });

  document.getElementById('modal-overlay').classList.add('open');
}

function showAddProjectDialog() {
  const modal = document.getElementById('modal');
  modal.textContent = '';

  const header = document.createElement('div');
  header.className = 'modal-header';
  header.appendChild(Object.assign(document.createElement('div'), { className: 'modal-title', textContent: 'Link Existing Project' }));
  const close = document.createElement('button');
  close.className = 'modal-close';
  close.textContent = '\u00d7';
  close.addEventListener('click', closeModal);
  header.appendChild(close);
  modal.appendChild(header);

  addSection(modal, 'Project Path', () => {
    const wrap = document.createElement('div');

    const hint = document.createElement('p');
    hint.style.cssText = 'font-size: 12px; color: var(--text-muted); margin-bottom: 10px;';
    hint.textContent = 'Paste the full path to a project directory that uses CKS.';
    wrap.appendChild(hint);

    const input = document.createElement('input');
    input.type = 'text';
    input.className = 'chat-input';
    input.style.cssText = 'width: 100%; margin-bottom: 10px;';
    input.placeholder = '/Users/you/projects/my-app';
    wrap.appendChild(input);

    const errorMsg = document.createElement('div');
    errorMsg.style.cssText = 'font-size: 11px; color: var(--danger); margin-bottom: 8px; display: none;';
    wrap.appendChild(errorMsg);

    const addBtn = document.createElement('button');
    addBtn.className = 'btn btn-accent';
    addBtn.textContent = 'Link Project';
    addBtn.addEventListener('click', async () => {
      const p = input.value.trim();
      if (!p) return;
      addBtn.textContent = 'Linking...';
      addBtn.disabled = true;
      const result = await postJSON('/api/projects/add', { path: p });
      if (result.error) {
        errorMsg.textContent = result.error;
        errorMsg.style.display = 'block';
        addBtn.textContent = 'Link Project';
        addBtn.disabled = false;
        return;
      }
      closeModal();
      await loadProjects();
      await selectProject(result.projectId);
      showToast('Project linked!');
    });
    wrap.appendChild(addBtn);

    return wrap;
  });

  document.getElementById('modal-overlay').classList.add('open');
  setTimeout(() => modal.querySelector('input').focus(), 100);
}

function showNewProjectDialog() {
  const modal = document.getElementById('modal');
  modal.textContent = '';

  const header = document.createElement('div');
  header.className = 'modal-header';
  header.appendChild(Object.assign(document.createElement('div'), { className: 'modal-title', textContent: 'Start New Project' }));
  const close = document.createElement('button');
  close.className = 'modal-close';
  close.textContent = '\u00d7';
  close.addEventListener('click', closeModal);
  header.appendChild(close);
  modal.appendChild(header);

  addSection(modal, 'Project Directory', () => {
    const wrap = document.createElement('div');

    const hint = document.createElement('p');
    hint.style.cssText = 'font-size: 12px; color: var(--text-muted); margin-bottom: 10px; line-height: 1.4;';
    hint.textContent = 'Enter the path where you want to create the project. CKS will run /cks:kickstart to take you from idea to scaffolded project \u2014 right here in the board.';
    wrap.appendChild(hint);

    const pathInput = document.createElement('input');
    pathInput.type = 'text';
    pathInput.className = 'chat-input';
    pathInput.style.cssText = 'width: 100%; margin-bottom: 12px;';
    pathInput.placeholder = '/Users/you/projects/new-project';
    wrap.appendChild(pathInput);

    const errorMsg = document.createElement('div');
    errorMsg.style.cssText = 'font-size: 11px; color: var(--danger); margin-bottom: 8px; display: none;';
    wrap.appendChild(errorMsg);

    const startBtn = document.createElement('button');
    startBtn.className = 'btn btn-accent';
    startBtn.textContent = 'Start Kickstart';
    startBtn.addEventListener('click', async () => {
      const projPath = pathInput.value.trim();
      if (!projPath) { showToast('Enter a project path'); return; }

      // Register the project first
      startBtn.textContent = 'Starting...';
      startBtn.disabled = true;

      const addResult = await postJSON('/api/projects/add', { path: projPath });
      if (addResult.error) {
        errorMsg.textContent = addResult.error;
        errorMsg.style.display = 'block';
        startBtn.textContent = 'Start Kickstart';
        startBtn.disabled = false;
        return;
      }

      // Select the project and run kickstart
      await loadProjects();
      activeProjectId = addResult.projectId;
      renderSidebar();
      closeModal();
      runSession(addResult.projectId, '/cks:kickstart', 'Kickstart: ' + projPath.split('/').pop());
    });
    wrap.appendChild(startBtn);

    return wrap;
  });

  document.getElementById('modal-overlay').classList.add('open');
}

// ═══ Multi-Session Manager (bottom bar + right panel) ═══

const activeSessions = new Map(); // sessionId -> { id, title, status, evtSource, output[] }
let viewingSessionId = null;

async function runSession(projectId, prompt, title) {
  const result = await postJSON('/api/session/start', { projectId, prompt });
  if (result.error) { showToast('Failed: ' + result.error); return; }

  const sessionId = result.sessionId;
  const session = {
    id: sessionId, title: title || prompt, prompt, projectId,
    status: 'running',
    output: [{ type: 'system', text: 'Starting session: ' + prompt + '...' }],
    evtSource: null,
    lastQuestion: null,
    lastQuestionOptions: null,
  };
  activeSessions.set(sessionId, session);
  renderSessionBar();

  // Connect SSE
  const evtSource = new EventSource('/api/session/' + sessionId + '/events');
  session.evtSource = evtSource;
  evtSource.addEventListener('claude', (e) => {
    try {
      const event = JSON.parse(e.data);
      console.log('[session] Event:', event.type, event.subtype || '', event.message ? 'has-message' : '');
      processSessionEvent(sessionId, event);
    } catch (err) {
      console.error('[session] Event parse error:', err);
    }
  });
  evtSource.addEventListener('message', (e) => {
    console.log('[session] Default message event:', e.data.substring(0, 100));
  });
  evtSource.onopen = () => {
    console.log('[session] SSE connected for', sessionId);
  };
  evtSource.onerror = (e) => {
    console.log('[session] SSE error for', sessionId);
  };

  // Show this session in the right panel
  viewingSessionId = sessionId;
  openPanel('session');

  // Poll as fallback in case SSE events don't trigger rendering
  const pollInterval = setInterval(() => {
    if (!activeSessions.has(sessionId)) { clearInterval(pollInterval); return; }
    if (viewingSessionId === sessionId) renderSessionPanel();
    const s = activeSessions.get(sessionId);
    if (s && (s.status === 'completed' || s.status === 'failed' || s.status === 'stopped' || s.status === 'error')) {
      clearInterval(pollInterval);
    }
  }, 1000);
}

function processSessionEvent(sessionId, event) {
  const session = activeSessions.get(sessionId);
  if (!session) return;

  // Assistant messages — the main Claude output
  if (event.type === 'assistant' && event.message && event.message.content) {
    for (const block of event.message.content) {
      if (block.type === 'text' && block.text) {
        session.output.push({ type: 'assistant', text: block.text });
      }
      if (block.type === 'tool_use') {
        const name = block.name || 'tool';
        let detail = '';
        if (block.input) {
          if (block.input.command) detail = ': ' + block.input.command;
          else if (block.input.file_path) detail = ': ' + block.input.file_path;
          else if (block.input.pattern) detail = ': ' + block.input.pattern;
          else if (block.input.prompt) detail = ' (agent)';
          else if (block.input.skill) detail = ': ' + block.input.skill;
        }
        session.output.push({ type: 'tool', text: '\u2699\ufe0f ' + name + detail });

        // Detect AskUserQuestion — Claude is asking the user something
        if (name === 'AskUserQuestion' && block.input && block.input.questions) {
          var q = block.input.questions[0];
          if (q) {
            session.status = 'needs_input';
            session.lastQuestion = q.question || 'Claude is asking a question...';
            session.lastQuestionOptions = (q.options || []).map(function(o) { return o.label; });
            session.output.push({
              type: 'question',
              text: session.lastQuestion,
              options: session.lastQuestionOptions,
            });
          }
        }
      }
    }
  }

  // Synthetic needs_input event from server-side detection
  else if (event.type === 'needs_input') {
    session.status = 'needs_input';
    session.lastQuestion = event.question || null;
    session.lastQuestionOptions = event.options || [];
    session.output.push({
      type: 'question',
      text: event.question || 'Claude needs your input',
      options: event.options || [],
    });
  }

  // System events
  else if (event.type === 'system') {
    if (event.subtype === 'init') {
      session.output.push({ type: 'system', text: 'Claude session initialized' });
    } else if (event.subtype === 'hook_response' && event.stdout) {
      const stdout = event.stdout || '';
      if (stdout.includes('CKS Session Resume') || stdout.includes('Phase:')) {
        const lines = stdout.split('\n').filter(l => l.trim() && !l.includes('\u2501'));
        session.output.push({ type: 'system', text: lines.join('\n') });
      }
    } else if (event.subtype === 'hook_started') {
      const last = session.output[session.output.length - 1];
      if (!last || last.text !== 'Loading plugins...') {
        session.output.push({ type: 'system', text: 'Loading plugins...' });
      }
    }
  }

  // Result — session finished or turn ended
  else if (event.type === 'result') {
    if (!session.status || session.status !== 'needs_input') {
      session.status = event.is_error ? 'failed' : 'completed';
    }
    session.lastQuestion = null;
    session.lastQuestionOptions = null;
    session.output.push({
      type: event.is_error ? 'error' : 'complete',
      text: event.is_error ? 'Error: ' + (event.error || '') : 'Complete \u2014 ' + (event.num_turns || 0) + ' turns',
    });
    refresh();
  }

  // Session end from process exit
  else if (event.type === 'session_end') {
    // Don't override needs_input — CLI exits after AskUserQuestion but user still needs to answer
    if (session.status !== 'needs_input') {
      session.status = event.status === 'completed' ? 'completed' : (event.status || 'stopped');
      session.lastQuestion = null;
      session.lastQuestionOptions = null;
      if (!session.output.some(o => o.type === 'complete' || o.type === 'error')) {
        session.output.push({ type: session.status === 'completed' ? 'complete' : 'error', text: 'Session ' + session.status });
      }
    }
    refresh();
  }

  // Errors
  else if (event.type === 'session_error') {
    session.status = 'error';
    session.output.push({ type: 'error', text: 'Error: ' + event.error });
  }

  // Stderr (filter noise)
  else if (event.type === 'stderr' && event.content) {
    const c = event.content;
    if (!c.includes('ExperimentalWarning') && !c.includes('punycode') && !c.includes('DEP0')) {
      session.output.push({ type: 'system', text: c });
    }
  }

  // Rate limit events
  else if (event.type === 'rate_limit_event') {
    session.output.push({ type: 'system', text: 'Rate limited, waiting...' });
  }

  renderSessionBar();
  if (viewingSessionId === sessionId) renderSessionPanel();
}

function renderSessionBar() {
  const bar = document.getElementById('session-bar');
  const chips = document.getElementById('session-chips');
  if (activeSessions.size === 0) { bar.style.display = 'none'; return; }

  bar.style.display = 'flex';
  chips.textContent = '';

  for (const [sid, s] of activeSessions) {
    const chip = document.createElement('div');
    chip.className = 'session-chip' + (sid === viewingSessionId ? ' active' : '');
    chip.addEventListener('click', () => { viewingSessionId = sid; openPanel('session'); });

    const dot = document.createElement('span');
    dot.className = 'session-chip-dot ' + s.status;
    chip.appendChild(dot);

    const text = document.createElement('span');
    text.className = 'session-chip-text';
    text.textContent = s.title;
    chip.appendChild(text);

    const x = document.createElement('button');
    x.className = 'session-chip-close';
    x.textContent = '\u00d7';
    x.addEventListener('click', (e) => { e.stopPropagation(); removeSession(sid); });
    chip.appendChild(x);

    chips.appendChild(chip);
  }
}

function renderSessionPanel() {
  const session = activeSessions.get(viewingSessionId);
  if (!session) {
    document.getElementById('session-output').textContent = 'No session selected';
    return;
  }

  const header = document.getElementById('session-panel-header');
  header.textContent = '';
  const t = document.createElement('span');
  t.textContent = session.title + ' (' + session.output.length + ' msgs)';
  t.style.cssText = 'overflow:hidden; text-overflow:ellipsis; white-space:nowrap; flex:1;';
  header.appendChild(t);

  const badge = document.createElement('span');
  badge.className = 'session-panel-status ' + session.status;
  badge.textContent = session.status === 'needs_input' ? 'waiting for you' : session.status;
  header.appendChild(badge);

  if (session.status === 'running' || session.status === 'needs_input') {
    const stopBtn = document.createElement('button');
    stopBtn.className = 'btn btn-ghost';
    stopBtn.style.cssText = 'font-size:11px; padding:2px 8px; margin-left:6px;';
    stopBtn.textContent = 'Stop';
    stopBtn.addEventListener('click', () => { postJSON('/api/session/' + session.id + '/stop', {}); });
    header.appendChild(stopBtn);
  }

  const output = document.getElementById('session-output');
  output.textContent = '';

  if (session.output.length === 0) {
    const empty = document.createElement('div');
    empty.style.cssText = 'padding: 20px; color: var(--text-muted); font-size: 13px;';
    empty.textContent = 'Waiting for Claude to respond...';
    output.appendChild(empty);
  }

  for (const entry of session.output) {
    if (entry.type === 'question') {
      // Render question with clickable option buttons
      const qBlock = document.createElement('div');
      qBlock.className = 'session-msg question';
      const qText = document.createElement('div');
      qText.className = 'session-question-text';
      qText.textContent = entry.text;
      qBlock.appendChild(qText);

      if (entry.options && entry.options.length > 0) {
        const optionsRow = document.createElement('div');
        optionsRow.className = 'session-question-options';
        entry.options.forEach(function(opt) {
          const btn = document.createElement('button');
          btn.className = 'session-option-btn';
          btn.textContent = opt;
          btn.addEventListener('click', function() { sendSessionResponse(opt); });
          optionsRow.appendChild(btn);
        });
        qBlock.appendChild(optionsRow);
      }
      output.appendChild(qBlock);
    } else {
      const cls = entry.type === 'assistant' ? 'assistant' : entry.type === 'tool' ? 'tool' : entry.type === 'error' ? 'error' : entry.type === 'complete' ? 'complete' : entry.type === 'user-response' ? 'assistant' : 'system-msg';
      const msg = document.createElement('div');
      msg.className = 'session-msg ' + cls;
      if (entry.type === 'assistant') {
        msg.appendChild(renderMarkdownSafe(entry.text));
      } else {
        msg.textContent = entry.text;
      }
      output.appendChild(msg);
    }
  }
  output.scrollTop = output.scrollHeight;

  // Show input area for active sessions (running, needs_input, or completed but resumable)
  const inputArea = document.getElementById('session-input-area');
  const showInput = session.status === 'running' || session.status === 'needs_input' || session.status === 'completed';
  inputArea.style.display = showInput ? '' : 'none';

  // If needs_input, show the question above the input
  var questionEl = document.getElementById('session-question-banner');
  if (!questionEl) { questionEl = createQuestionBanner(); }
  if (session.status === 'needs_input' && session.lastQuestion) {
    questionEl.textContent = session.lastQuestion;
    questionEl.style.display = '';
  } else {
    questionEl.style.display = 'none';
  }
}

function createQuestionBanner() {
  const banner = document.createElement('div');
  banner.id = 'session-question-banner';
  banner.className = 'session-question';
  banner.style.display = 'none';
  const inputArea = document.getElementById('session-input-area');
  inputArea.parentNode.insertBefore(banner, inputArea);
  return banner;
}

// Safe Markdown Renderer (DOM-based, no raw HTML injection)

function renderMarkdownSafe(text) {
  const container = document.createElement('div');
  container.className = 'md-content';
  if (!text) return container;

  // Split into code blocks and regular text
  const parts = text.split(/(```[\s\S]*?```)/g);

  for (var i = 0; i < parts.length; i++) {
    var part = parts[i];
    if (part.startsWith('```')) {
      var pre = document.createElement('pre');
      pre.className = 'md-code-block';
      var code = document.createElement('code');
      var content = part.replace(/^```\w*\n?/, '').replace(/\n?```$/, '');
      code.textContent = content;
      pre.appendChild(code);
      container.appendChild(pre);
    } else {
      var lines = part.split('\n');
      for (var j = 0; j < lines.length; j++) {
        var line = lines[j];
        if (!line.trim()) { container.appendChild(document.createElement('br')); continue; }
        var h3M = line.match(/^### (.+)$/);
        var h2M = line.match(/^## (.+)$/);
        var h1M = line.match(/^# (.+)$/);
        if (h3M) { var h = document.createElement('h4'); h.className = 'md-h'; h.textContent = h3M[1]; container.appendChild(h); continue; }
        if (h2M) { var h = document.createElement('h3'); h.className = 'md-h'; h.textContent = h2M[1]; container.appendChild(h); continue; }
        if (h1M) { var h = document.createElement('h2'); h.className = 'md-h'; h.textContent = h1M[1]; container.appendChild(h); continue; }
        if (line.startsWith('> ')) { var bq = document.createElement('blockquote'); bq.className = 'md-quote'; bq.textContent = line.slice(2); container.appendChild(bq); continue; }
        if (line.match(/^[-*] /)) { var li = document.createElement('div'); li.className = 'md-li'; renderInline(li, line.slice(2)); container.appendChild(li); continue; }
        var p = document.createElement('span');
        renderInline(p, line);
        container.appendChild(p);
        container.appendChild(document.createElement('br'));
      }
    }
  }
  return container;
}

/** Render inline markdown (bold, italic, code) using safe DOM methods */
function renderInline(parent, text) {
  var regex = /(`[^`]+`|\*\*[^*]+\*\*|\*[^*]+\*)/g;
  var lastIndex = 0;
  var match;
  while ((match = regex.exec(text)) !== null) {
    if (match.index > lastIndex) {
      parent.appendChild(document.createTextNode(text.slice(lastIndex, match.index)));
    }
    var token = match[0];
    if (token.startsWith('`')) {
      var el = document.createElement('code');
      el.className = 'md-inline-code';
      el.textContent = token.slice(1, -1);
      parent.appendChild(el);
    } else if (token.startsWith('**')) {
      var el = document.createElement('strong');
      el.textContent = token.slice(2, -2);
      parent.appendChild(el);
    } else if (token.startsWith('*')) {
      var el = document.createElement('em');
      el.textContent = token.slice(1, -1);
      parent.appendChild(el);
    }
    lastIndex = match.index + token.length;
  }
  if (lastIndex < text.length) {
    parent.appendChild(document.createTextNode(text.slice(lastIndex)));
  }
}

async function sendSessionResponse(text) {
  if (!viewingSessionId) return;
  const session = activeSessions.get(viewingSessionId);
  if (!session) return;
  // Allow response when running, needs_input, OR completed (CLI exited but waiting for --resume)
  if (session.status !== 'running' && session.status !== 'needs_input' && session.status !== 'completed') return;

  const input = document.getElementById('session-input');
  const response = text || input.value.trim();
  if (!response) return;

  // Immediately update UI
  session.status = 'running';
  session.lastQuestion = null;
  session.lastQuestionOptions = null;
  session.output.push({ type: 'user-response', text: '\u27a4 ' + response });
  renderSessionBar();
  renderSessionPanel();

  await postJSON('/api/session/' + viewingSessionId + '/respond', { text: response });
  input.value = '';
}

function removeSession(sessionId) {
  const session = activeSessions.get(sessionId);
  if (!session) return;
  if (session.status === 'running') postJSON('/api/session/' + sessionId + '/stop', {});
  if (session.evtSource) session.evtSource.close();
  activeSessions.delete(sessionId);

  if (viewingSessionId === sessionId) {
    viewingSessionId = activeSessions.size > 0 ? activeSessions.keys().next().value : null;
    if (viewingSessionId) renderSessionPanel();
    else switchTab('chat');
  }
  renderSessionBar();
}

// ═══ Utils ═══

function copyForClaude(command) {
  const project = projects.find(p => p.id === activeProjectId);
  navigator.clipboard.writeText(command).then(() => {
    showToast('Copied! Paste in Claude Code' + (project ? ' (' + project.name + ')' : ''));
  }).catch(() => {
    showToast(command);
  });
}

function showToast(message) {
  const toast = document.getElementById('toast');
  toast.textContent = message;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 2500);
}

// ═══ SSE ═══

function connectSSE() {
  const src = new EventSource('/api/events');
  src.addEventListener('sync', async () => {
    await loadProjects();
    if (activeProjectId) {
      const fd = await fetchJSON('/api/features?projectId=' + activeProjectId);
      if (fd) { features = fd; renderBoard(); }
    }
  });
  src.addEventListener('tunnel_url', (e) => {
    try { const data = JSON.parse(e.data); if (data.url) handleTunnelUrl(data.url); } catch {}
  });
  src.addEventListener('connected', () => console.log('[SSE] Live'));
}

// ═══ Events ═══

// ═══ Sidebar Toggle ═══

function toggleSidebar() {
  const sidebar = document.getElementById('sidebar');
  sidebar.classList.toggle('collapsed');
  // On mobile, also toggle overlay
  if (window.innerWidth <= 768) {
    sidebar.classList.toggle('mobile-open');
  }
}

// Auto-collapse sidebar on small screens
function handleResize() {
  const sidebar = document.getElementById('sidebar');
  if (window.innerWidth <= 768) {
    sidebar.classList.add('collapsed');
    sidebar.classList.remove('mobile-open');
  } else if (window.innerWidth <= 1200) {
    sidebar.classList.add('collapsed');
  } else {
    sidebar.classList.remove('collapsed');
    sidebar.classList.remove('mobile-open');
  }
}

window.addEventListener('resize', handleResize);
handleResize(); // Run on init

document.getElementById('hamburger-btn').addEventListener('click', toggleSidebar);
document.getElementById('refresh-btn').addEventListener('click', refresh);
document.getElementById('close-panel').addEventListener('click', closePanel);
document.getElementById('modal-overlay').addEventListener('click', (e) => { if (e.target === e.currentTarget) closeModal(); });
document.getElementById('send-chat').addEventListener('click', sendMessage);
document.getElementById('chat-input').addEventListener('keydown', (e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); } });
document.getElementById('new-project-btn').addEventListener('click', showNewProjectDialog);
document.getElementById('session-send').addEventListener('click', () => sendSessionResponse());
document.getElementById('session-input').addEventListener('keydown', (e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendSessionResponse(); } });
document.getElementById('add-existing-btn').addEventListener('click', showAddProjectDialog);
document.getElementById('view-activity-btn').addEventListener('click', () => openPanel('activity'));
document.getElementById('notification-bell').addEventListener('click', () => openPanel('notifications'));
document.getElementById('logs-refresh').addEventListener('click', loadLogs);
document.getElementById('logs-filter').addEventListener('change', loadLogs);
document.getElementById('export-notes-btn').addEventListener('click', exportNotesToRepo);

document.querySelectorAll('.panel-tab').forEach(tab => {
  tab.addEventListener('click', () => switchTab(tab.dataset.tab));
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') { if (panelOpen) closePanel(); else closeModal(); }
  if (e.key === 'r' && !e.metaKey && !e.ctrlKey && document.activeElement === document.body) refresh();
  if (e.key === 'n' && !e.metaKey && !e.ctrlKey && document.activeElement === document.body) showNewFeatureDialog();
});

// ═══ Theme Toggle ═══

function initTheme() {
  var saved = localStorage.getItem('cks-theme') || 'dark';
  document.documentElement.dataset.theme = saved;
  updateThemeIcon(saved);
}

function toggleTheme() {
  var current = document.documentElement.dataset.theme || 'dark';
  var next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.dataset.theme = next;
  localStorage.setItem('cks-theme', next);
  updateThemeIcon(next);
}

function updateThemeIcon(theme) {
  var btn = document.getElementById('theme-toggle');
  btn.textContent = theme === 'dark' ? '\u2600' : '\u263E';
  btn.title = theme === 'dark' ? 'Switch to light theme' : 'Switch to dark theme';
}

document.getElementById('theme-toggle').addEventListener('click', toggleTheme);

// ═══ Tunnel URL display ═══

function handleTunnelUrl(url) {
  var existing = document.getElementById('tunnel-url');
  if (existing) existing.remove();
  var el = document.createElement('div');
  el.id = 'tunnel-url';
  el.style.cssText = 'font-size:11px; color:var(--accent); cursor:pointer; padding:3px 10px; background:var(--accent-soft); border-radius:12px;';
  el.textContent = url;
  el.title = 'Click to copy remote URL';
  el.addEventListener('click', function() {
    navigator.clipboard.writeText(url).then(function() { showToast('Remote URL copied!'); });
  });
  document.querySelector('.header-stats').appendChild(el);
}

// ═══ Init ═══

initTheme();
connectSSE();
(async () => {
  await loadProjects();
  if (activeProjectId) await refreshBoard();
})();
