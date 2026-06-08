'use strict';

function appPage() {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>CKS Console</title>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{
  --bg:#0c0d12;--surface:#14161e;--surface2:#1a1c27;
  --border:#1e2030;--border2:#252938;
  --text:#e4e7f1;--text2:#c9d1e0;--muted:#8891a8;--dim:#3d4355;
  --primary:#6c8cff;--green:#4ade80;--amber:#f59e0b;--red:#f87171;
  --blue:#3b82f6;--purple:#8b5cf6;--pink:#ec4899;
}
body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;background:var(--bg);color:var(--text);min-height:100vh;display:flex;flex-direction:column;font-size:14px}
code,pre{font-family:"SF Mono","Cascadia Code",Menlo,monospace}

/* NAV */
.nav{position:sticky;top:0;z-index:100;display:flex;align-items:center;height:52px;background:#0a0b11;border-bottom:1px solid var(--border);padding:0 20px;flex-shrink:0}
.brand{font-size:14px;font-weight:700;color:var(--primary);letter-spacing:-.02em;margin-right:20px;white-space:nowrap}
.brand small{font-weight:400;color:var(--muted);font-size:11px;margin-left:4px}
.nl{display:flex;align-items:center;height:100%;padding:0 12px;font-size:13px;color:var(--muted);text-decoration:none;border-bottom:2px solid transparent;transition:color .12s,border-color .12s;white-space:nowrap}
.nl:hover{color:var(--text)}
.nl.act{color:var(--primary);border-color:var(--primary)}
.nav-right{margin-left:auto;display:flex;align-items:center;gap:14px}
.live-dot{font-size:11px;color:var(--muted)}
.live-dot.on{color:var(--green)}

/* LAYOUT */
.page{flex:1;padding:24px 28px;display:none;overflow-y:auto}
.page.show{display:block}
.page-hdr{display:flex;align-items:center;gap:10px;margin-bottom:20px}
.page-title{font-size:17px;font-weight:600}
.page-sub{font-size:12px;color:var(--muted);margin-top:2px;margin-bottom:20px}

/* BUTTONS */
.btn{display:inline-flex;align-items:center;gap:6px;padding:6px 14px;border-radius:6px;border:1px solid var(--border2);background:var(--surface);color:var(--muted);font-size:12px;cursor:pointer;transition:all .12s;font-weight:500;font-family:inherit}
.btn:hover{border-color:var(--primary);color:var(--primary)}
.btn-primary{background:var(--primary);color:#fff;border-color:var(--primary)}
.btn-primary:hover{background:#5a7cf0;color:#fff;border-color:#5a7cf0}
.btn-danger{background:#3d1f1f;color:var(--red);border-color:#5a2d2d}

/* STATS */
.stats{display:flex;gap:12px;margin-bottom:20px;flex-wrap:wrap}
.stat-card{flex:1;min-width:110px;background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:14px 16px}
.stat-val{font-size:26px;font-weight:700;line-height:1.1}
.stat-lbl{font-size:10px;color:var(--muted);margin-top:4px;text-transform:uppercase;letter-spacing:.06em}

/* KANBAN */
.kanban{display:grid;grid-template-columns:repeat(6,minmax(155px,1fr));gap:10px;align-items:start;overflow-x:auto;padding-bottom:4px}
.col{background:var(--surface);border:1px solid var(--border);border-radius:10px;min-height:160px;display:flex;flex-direction:column}
.col-hdr{padding:9px 12px;display:flex;align-items:center;justify-content:space-between;flex-shrink:0;border-bottom:2px solid transparent}
.col-name{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.08em}
.col-cnt{font-size:10px;font-weight:700;padding:2px 6px;border-radius:8px}
.col-body{flex:1;padding:8px;display:flex;flex-direction:column;gap:6px}
.card{background:var(--bg);border:1px solid var(--border);border-radius:7px;padding:10px 11px;transition:border-color .12s}
.card:hover{border-color:var(--border2)}
.card.attn{border-left:3px solid var(--amber)}
.card.active-card{border-left:3px solid var(--primary)}
.card-title{font-size:12px;font-weight:500;color:var(--text2);margin-bottom:5px;word-break:break-word;line-height:1.35}
.phases{display:flex;gap:3px;margin-bottom:3px}
.pdot{width:7px;height:7px;border-radius:50%;background:var(--border2);flex-shrink:0}
.pdot.on{background:var(--primary)}
.card-cmd{font-size:9px;font-family:monospace;color:var(--primary);background:#6c8cff10;border:1px solid #6c8cff18;border-radius:3px;padding:2px 5px;margin-top:4px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.card-hint{font-size:10px;color:var(--muted);margin-top:3px;line-height:1.35;overflow:hidden;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}
.empty-col{font-size:11px;color:var(--dim);text-align:center;padding:28px 0;flex:1;display:flex;align-items:center;justify-content:center}

/* METRICS */
.m-grid{display:grid;grid-template-columns:1fr 1fr;gap:18px}
@media(max-width:700px){.m-grid{grid-template-columns:1fr}}
.m-card{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:18px}
.m-card-title{font-size:10px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:14px;font-weight:600}
.phase-row{margin-bottom:10px}
.phase-row-top{display:flex;justify-content:space-between;font-size:11px;margin-bottom:4px}
.phase-track{height:8px;background:var(--border);border-radius:4px;overflow:hidden}
.phase-fill{height:100%;border-radius:4px;transition:width .5s ease}
.act-list{display:flex;flex-direction:column;gap:1px;max-height:380px;overflow-y:auto}
.act-item{display:flex;gap:10px;padding:8px 0;border-bottom:1px solid var(--border)}
.act-item:last-child{border-bottom:none}
.act-time{font-size:10px;color:var(--muted);white-space:nowrap;flex-shrink:0;padding-top:1px}
.act-action{font-size:12px;color:var(--text2)}
.act-proj{font-size:10px;color:var(--muted)}
.no-data{font-size:12px;color:var(--dim);text-align:center;padding:36px 0}

/* LUV */
.active-bar{display:flex;align-items:center;gap:12px;background:var(--surface);border:1px solid var(--border2);border-radius:8px;padding:12px 18px;margin-bottom:18px}
.active-label{font-size:12px;color:var(--muted)}
#activeProfileName{font-size:14px;font-weight:600;color:var(--primary);font-family:monospace}
.active-right{margin-left:auto;display:flex;gap:8px;align-items:center}
select{background:var(--bg);border:1px solid var(--border2);border-radius:5px;color:var(--text);font-size:13px;padding:5px 10px;cursor:pointer;font-family:inherit}
select:focus{outline:none;border-color:var(--primary)}
.ltabs{display:flex;gap:8px;margin-bottom:16px}
.ltab{padding:6px 16px;border-radius:6px;border:1px solid var(--border2);background:var(--surface);color:var(--muted);font-size:13px;cursor:pointer;transition:all .12s;font-family:inherit}
.ltab:hover{border-color:var(--primary);color:var(--text)}
.ltab.act{background:#6c8cff15;border-color:var(--primary);color:var(--primary);font-weight:500}
.lpanel{display:none;background:var(--surface);border:1px solid var(--border2);border-radius:10px;padding:22px}
.lpanel.show{display:block}
.lpanel-hdr{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px}
.lpanel-name{font-size:13px;font-weight:500}
.badge{font-size:10px;padding:2px 8px;border-radius:4px;background:#6c8cff15;color:var(--primary);border:1px solid #6c8cff30}
.badge.ov{background:#f59e0b15;color:var(--amber);border-color:#f59e0b30}
table{width:100%;border-collapse:collapse;margin-bottom:18px}
th{text-align:left;font-size:10px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;padding:0 0 8px}
td{padding:5px 0;border-top:1px solid var(--border);vertical-align:middle}
.tl{font-size:12px;color:var(--text2)}.td{font-size:10px;color:var(--muted);display:block}
input.mi{width:100%;background:var(--bg);border:1px solid var(--border2);border-radius:5px;color:var(--text);font-size:11px;font-family:monospace;padding:4px 8px}
input.mi:focus{outline:none;border-color:var(--primary)}
.da{font-size:11px;font-family:monospace;color:var(--muted)}
.lacts{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
.bst{font-size:11px;margin-left:auto}
.ok{color:var(--green)}.er{color:var(--red)}

/* SETTINGS */
.s-grid{display:grid;grid-template-columns:1fr 1fr;gap:18px}
@media(max-width:700px){.s-grid{grid-template-columns:1fr}}
.s-card{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:18px}
.s-card-title{font-size:10px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:14px;font-weight:600}
.s-row{display:flex;gap:8px;padding:7px 0;border-bottom:1px solid var(--border);font-size:12px;align-items:baseline}
.s-row:last-child{border-bottom:none}
.s-key{color:var(--muted);flex-shrink:0;min-width:120px;font-size:11px}
.s-val{color:var(--text2);font-family:monospace;font-size:11px;word-break:break-all}
.domain-item{padding:10px 0;border-bottom:1px solid var(--border)}
.domain-item:last-child{border-bottom:none}
.domain-name{font-size:13px;font-weight:500;color:var(--text2);margin-bottom:3px}
.domain-desc{font-size:11px;color:var(--muted);margin-bottom:6px;line-height:1.4}
.domain-tasks{display:flex;flex-wrap:wrap;gap:4px}
.domain-task{font-size:10px;background:var(--bg);border:1px solid var(--border);border-radius:4px;padding:2px 8px;color:var(--muted)}
.s-full{grid-column:1/-1}
</style>
</head>
<body>

<nav class="nav">
  <span class="brand">CKS <small>Console</small></span>
  <a class="nl" href="#board" id="nl-board">Board</a>
  <a class="nl" href="#metrics" id="nl-metrics">Metrics</a>
  <a class="nl" href="#luv" id="nl-luv">Luv Profiles</a>
  <a class="nl" href="#settings" id="nl-settings">Settings</a>
  <div class="nav-right">
    <span class="live-dot" id="liveDot">○</span>
  </div>
</nav>

<div class="page" id="pg-board">
  <div class="page-hdr">
    <span class="page-title">Feature Board</span>
    <button class="btn" id="btnRefreshBoard">&#8635; Refresh</button>
    <span id="boardStatus" style="font-size:11px;color:var(--muted)"></span>
  </div>
  <div class="stats" id="boardStats"></div>
  <div class="kanban" id="kanban"></div>
</div>

<div class="page" id="pg-metrics">
  <div class="page-hdr">
    <span class="page-title">Metrics</span>
    <button class="btn" id="btnRefreshMetrics">&#8635; Refresh</button>
  </div>
  <div class="m-grid" id="metricGrid"></div>
</div>

<div class="page" id="pg-luv">
  <div class="page-hdr">
    <span class="page-title">Luv Model Routing</span>
  </div>
  <p class="page-sub">Configure which AI model each Luv agent uses. Overrides saved to <code>.luv/profiles/</code>.</p>
  <div class="active-bar">
    <span class="active-label">Active profile:</span>
    <span id="activeProfileName">loading</span>
    <div class="active-right">
      <select id="sw">
        <option value="quality">quality</option>
        <option value="budget">budget</option>
        <option value="speed">speed</option>
      </select>
      <button class="btn btn-primary" id="btnSetProfile">Set Active</button>
    </div>
  </div>
  <div class="ltabs">
    <button class="ltab" id="ltab-quality">quality</button>
    <button class="ltab" id="ltab-budget">budget</button>
    <button class="ltab" id="ltab-speed">speed</button>
  </div>
  <div>
    <div class="lpanel" id="lpanel-quality"></div>
    <div class="lpanel" id="lpanel-budget"></div>
    <div class="lpanel" id="lpanel-speed"></div>
  </div>
</div>

<div class="page" id="pg-settings">
  <div class="page-hdr">
    <span class="page-title">Settings</span>
    <button class="btn" id="btnRefreshSettings">&#8635; Refresh</button>
  </div>
  <p class="page-sub">Project state, Agentic OS domains, and configuration.</p>
  <div class="s-grid" id="settingsGrid"></div>
</div>

<script>
(function() {
'use strict';

function esc(s) {
  return String(s||'').replace(/[&<>"']/g,function(c){
    return{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c];
  });
}

function relTime(iso) {
  if (!iso) return '';
  var diff = Date.now() - new Date(iso).getTime();
  var m = Math.floor(diff/60000);
  if (m < 1) return 'just now';
  if (m < 60) return m + 'm ago';
  var h = Math.floor(m/60);
  if (h < 24) return h + 'h ago';
  return Math.floor(h/24) + 'd ago';
}

// Router
var PAGES = ['board','metrics','luv','settings'];
var loaded = {};

function navigate(hash) {
  var p = (hash||location.hash||'').replace(/^#/,'').toLowerCase() || 'board';
  if (!PAGES.includes(p)) p = 'board';
  PAGES.forEach(function(n) {
    document.getElementById('pg-'+n).classList.toggle('show', n===p);
    var nl = document.getElementById('nl-'+n);
    if (nl) nl.className = 'nl' + (n===p?' act':'');
  });
  if (!loaded[p]) { loaded[p] = true; loaders[p](); }
  else if (p === 'board') loadBoard();
}
window.addEventListener('hashchange', function() { navigate(location.hash); });

// Board
var COLS = [
  {id:'backlog',  label:'Backlog',  color:'#8891a8'},
  {id:'discover', label:'Discover', color:'#3b82f6'},
  {id:'design',   label:'Design',   color:'#8b5cf6'},
  {id:'sprint',   label:'Sprint',   color:'#f59e0b'},
  {id:'review',   label:'Review',   color:'#ec4899'},
  {id:'release',  label:'Release',  color:'#4ade80'},
];

function phaseBar(prog) {
  return ['discover','design','sprint','review','release'].map(function(k) {
    return '<span class="pdot'+(prog&&prog[k]?' on':'')+'"></span>';
  }).join('');
}

function statCard(v, lbl, col) {
  return '<div class="stat-card"><div class="stat-val"'+(col?' style="color:'+col+'"':'')+'>'+
    v+'</div><div class="stat-lbl">'+lbl+'</div></div>';
}

function renderBoard(features) {
  var byCol = {};
  COLS.forEach(function(c) { byCol[c.id] = []; });
  (features||[]).forEach(function(f) { if (byCol[f.column]) byCol[f.column].push(f); });

  var total  = features.length;
  var active = features.filter(function(f){ return f.isActive; }).length;
  var attn   = features.filter(function(f){ return f.needsAttention; }).length;
  var done   = features.filter(function(f){ return f.status==='released'; }).length;

  var statsEl = document.getElementById('boardStats');
  statsEl.textContent = '';
  statsEl.insertAdjacentHTML('beforeend',
    statCard(total,'Total') +
    statCard(active,'Active','var(--primary)') +
    statCard(attn,'Needs Attn','var(--amber)') +
    statCard(done,'Released','var(--green)')
  );

  var colsHtml = COLS.map(function(col) {
    var cards = byCol[col.id];
    var html = cards.map(function(f) {
      var cls = 'card'+(f.needsAttention?' attn':'')+(f.isActive?' active-card':'');
      var cmd  = f.nextCommand ? '<div class="card-cmd">'+esc(f.nextCommand)+'</div>' : '';
      var hint = f.guidance&&f.guidance.why ? '<div class="card-hint">'+esc(f.guidance.why.slice(0,85))+'</div>' : '';
      return '<div class="'+cls+'"><div class="card-title">'+esc(f.displayName||f.name)+
        '</div><div class="phases">'+phaseBar(f.phaseProgress)+'</div>'+hint+cmd+'</div>';
    }).join('') || '<div class="empty-col">empty</div>';

    return '<div class="col"><div class="col-hdr" style="border-color:'+col.color+'">'+
      '<span class="col-name" style="color:'+col.color+'">'+col.label+'</span>'+
      '<span class="col-cnt" style="background:'+col.color+'20;color:'+col.color+'">'+cards.length+'</span>'+
      '</div><div class="col-body">'+html+'</div></div>';
  }).join('');

  var kanban = document.getElementById('kanban');
  kanban.textContent = '';
  kanban.insertAdjacentHTML('beforeend', colsHtml);
}

async function loadBoard() {
  document.getElementById('boardStatus').textContent = 'Loading…';
  try {
    var r = await fetch('/api/features');
    var features = await r.json();
    var list = Array.isArray(features) ? features : [];
    renderBoard(list);
    document.getElementById('boardStatus').textContent =
      list.length + ' feature' + (list.length!==1?'s':'');
  } catch(e) {
    document.getElementById('boardStatus').textContent = 'Error loading features';
  }
}

document.getElementById('btnRefreshBoard').addEventListener('click', loadBoard);

// Metrics
async function loadMetrics() {
  var grid = document.getElementById('metricGrid');
  try {
    var featRes = await fetch('/api/features').then(function(r){return r.json();});
    var actRes  = await fetch('/api/activity?limit=30').then(function(r){return r.json();}).catch(function(){return [];});
    var features = Array.isArray(featRes) ? featRes : [];
    var activity = Array.isArray(actRes)  ? actRes  : [];

    var byCol = {};
    COLS.forEach(function(c) { byCol[c.id] = 0; });
    features.forEach(function(f) { if (byCol[f.column]!==undefined) byCol[f.column]++; });
    var maxCount = Math.max(1, Math.max.apply(null, Object.values(byCol)));

    var phaseHtml = COLS.map(function(col) {
      var count = byCol[col.id];
      var pct = Math.round((count/maxCount)*100);
      return '<div class="phase-row"><div class="phase-row-top">'+
        '<span style="color:'+col.color+'">'+col.label+'</span>'+
        '<span style="color:var(--muted)">'+count+'</span></div>'+
        '<div class="phase-track"><div class="phase-fill" style="width:'+pct+'%;background:'+col.color+'"></div></div></div>';
    }).join('');

    var actHtml = activity.length
      ? activity.map(function(e) {
          var action = esc(e.action||e.event||e.type||'event');
          var proj   = esc(e._project||'');
          return '<div class="act-item"><div class="act-time">'+relTime(e.timestamp)+'</div>'+
            '<div><div class="act-action">'+action+'</div>'+(proj?'<div class="act-proj">'+proj+'</div>':'')+
            '</div></div>';
        }).join('')
      : '<div class="no-data">No activity yet</div>';

    grid.textContent = '';
    grid.insertAdjacentHTML('beforeend',
      '<div class="m-card"><div class="m-card-title">Phase Distribution</div>'+phaseHtml+'</div>'+
      '<div class="m-card"><div class="m-card-title">Recent Activity</div><div class="act-list">'+actHtml+'</div></div>'
    );
  } catch(e) {
    grid.textContent = '';
    grid.insertAdjacentHTML('beforeend',
      '<div class="m-card"><div class="no-data" style="color:var(--red)">Failed: '+esc(e.message)+'</div></div>'
    );
  }
}

document.getElementById('btnRefreshMetrics').addEventListener('click', function() {
  loaded.metrics = false; loadMetrics(); loaded.metrics = true;
});

// Luv Profiles
var LUV_TASKS = [
  ['strategy',     'Strategy',     'Brand positioning, GTM analysis'],
  ['copywriting',  'Copywriting',  'Ads, emails, short-form'],
  ['long_form',    'Long-form',    'Blog posts, whitepapers'],
  ['fast_copy',    'Fast copy',    'Quick headline/CTA generation'],
  ['analysis',     'Analysis',     'Market research, competitor review'],
  ['brainstorming','Brainstorming','Ideation and concept work'],
];
var LUV_DIRECT = [['image','openai/gpt-image-1'],['video','kling/kling-v1-5']];
var LUV_NAMES  = ['quality','budget','speed'];
var luvState   = {};

function mk(tag, cls, txt) {
  var e = document.createElement(tag);
  if (cls) e.className = cls;
  if (txt !== undefined) e.textContent = txt;
  return e;
}

function buildLuvPanel(name) {
  var panel = document.getElementById('lpanel-'+name);
  panel.textContent = '';

  var hdr = mk('div','lpanel-hdr');
  hdr.appendChild(mk('span','lpanel-name', name+' profile'));
  var badge = mk('span','badge','default'); badge.id = 'lbadge-'+name;
  hdr.appendChild(badge);
  panel.appendChild(hdr);

  var tbl = document.createElement('table');
  var thead = tbl.createTHead();
  var hrow = thead.insertRow();
  ['Task type','Model ID'].forEach(function(h) {
    var th = document.createElement('th'); th.textContent = h; hrow.appendChild(th);
  });
  var tb = tbl.createTBody();

  LUV_TASKS.forEach(function(t) {
    var tr = tb.insertRow();
    var td1 = tr.insertCell();
    td1.appendChild(mk('span','tl',t[1]));
    td1.appendChild(mk('span','td',t[2]));
    var td2 = tr.insertCell();
    var inp = document.createElement('input');
    inp.type='text'; inp.className='mi'; inp.id=name+'-'+t[0];
    inp.placeholder='provider/model-id'; inp.spellcheck=false;
    td2.appendChild(inp);
  });
  LUV_DIRECT.forEach(function(d) {
    var tr = tb.insertRow();
    var td1 = tr.insertCell();
    td1.appendChild(mk('span','tl',d[0]));
    td1.appendChild(mk('span','td','Direct vendor API'));
    tr.insertCell().appendChild(mk('span','da',d[1]+' (direct)'));
  });
  panel.appendChild(tbl);

  var acts = mk('div','lacts');
  var bSave  = mk('button','btn btn-primary','Save overrides');
  bSave.addEventListener('click', function() { saveLuv(name); });
  var bReset = mk('button','btn btn-danger','Reset to default');
  bReset.id = 'lreset-'+name; bReset.style.display = 'none';
  bReset.addEventListener('click', function() { resetLuv(name); });
  var stEl = mk('span','bst',''); stEl.id = 'lst-'+name;
  acts.appendChild(bSave); acts.appendChild(bReset); acts.appendChild(stEl);
  panel.appendChild(acts);
}

function populateLuv(name) {
  var prof = (luvState.profiles && luvState.profiles[name]) || {};
  var hasOv = prof._hasOverride;
  var badge = document.getElementById('lbadge-'+name);
  if (badge) { badge.textContent = hasOv?'project override':'default'; badge.className='badge'+(hasOv?' ov':''); }
  var rb = document.getElementById('lreset-'+name);
  if (rb) rb.style.display = hasOv ? '' : 'none';
  LUV_TASKS.forEach(function(t) {
    var inp = document.getElementById(name+'-'+t[0]);
    if (inp) inp.value = prof[t[0]] || '';
  });
}

function showLuvTab(name) {
  LUV_NAMES.forEach(function(n) {
    var t = document.getElementById('ltab-'+n);
    var p = document.getElementById('lpanel-'+n);
    if (t) t.className = 'ltab'+(n===name?' act':'');
    if (p) p.className = 'lpanel'+(n===name?' show':'');
  });
}

function setLuvStatus(name, msg, cls) {
  var e = document.getElementById('lst-'+name);
  if (!e) return;
  e.textContent = msg; e.className = 'bst '+(cls||'');
  if (msg) setTimeout(function() { e.textContent=''; }, 3000);
}

async function loadLuv() {
  var r = await fetch('/api/luv/profiles');
  luvState = await r.json();
  var active = luvState.active || 'quality';
  document.getElementById('activeProfileName').textContent = active;
  document.getElementById('sw').value = active;
  LUV_NAMES.forEach(function(n) {
    var tab = document.getElementById('ltab-'+n);
    if (tab) tab.textContent = n + (n===active?' ✓':'');
    populateLuv(n);
  });
  showLuvTab(active);
}

async function saveLuv(name) {
  var models = {};
  LUV_TASKS.forEach(function(t) {
    var inp = document.getElementById(name+'-'+t[0]);
    if (inp && inp.value.trim()) models[t[0]] = inp.value.trim();
  });
  var r = await fetch('/api/luv/profiles/'+name, {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({models:models})
  });
  var data = await r.json();
  setLuvStatus(name, data.saved?'Saved ✓':(data.error||'Error'), data.saved?'ok':'er');
  await loadLuv();
}

async function resetLuv(name) {
  await fetch('/api/luv/profiles/'+name, {method:'DELETE'});
  await loadLuv(); showLuvTab(name);
}

LUV_NAMES.forEach(function(n) {
  buildLuvPanel(n);
  document.getElementById('ltab-'+n).addEventListener('click', function() { showLuvTab(n); });
});

document.getElementById('btnSetProfile').addEventListener('click', async function() {
  var name = document.getElementById('sw').value;
  await fetch('/api/luv/active', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({profile:name})});
  await loadLuv();
});

// Settings
async function loadSettings() {
  var grid = document.getElementById('settingsGrid');

  try {
    var stateRes = await fetch('/api/state').then(function(r){return r.json();}).catch(function(){return {};});
    var projRes  = await fetch('/api/projects').then(function(r){return r.json();}).catch(function(){return [];});
    var domsRes  = await fetch('/api/domains').then(function(r){return r.json();}).catch(function(){return {raw:''};});

    var projects = Array.isArray(projRes) ? projRes : [];
    var prdState = stateRes && stateRes.state ? stateRes.state : null;

    var projHtml = projects.map(function(p) {
      return '<div class="s-row"><span class="s-key">'+esc(p.name)+'</span><span class="s-val">'+esc(p.path)+'</span></div>';
    }).join('') || '<div class="s-row"><span class="s-val" style="color:var(--muted)">No projects registered</span></div>';

    var stRows = prdState
      ? [['Active Phase',prdState.activePhase],['Phase Name',prdState.phaseName],
         ['Status',prdState.phaseStatus],['Last Action',prdState.lastAction],
         ['Next Action',prdState.nextAction],['PRD Status',prdState.prdStatus]]
          .filter(function(r){return r[1];})
          .map(function(r){
            return '<div class="s-row"><span class="s-key">'+esc(r[0])+'</span><span class="s-val">'+esc(r[1])+'</span></div>';
          }).join('')
      : '<div class="s-row"><span class="s-val" style="color:var(--muted)">No PRD state — run /cks:new to start</span></div>';

    // Parse domains markdown
    var rawDomains = (domsRes && domsRes.raw) || '';
    var domsHtml = '';
    if (rawDomains) {
      var domBlocks = rawDomains.split(/^## /m).filter(function(b){return b.trim();});
      domsHtml = domBlocks.map(function(block) {
        var firstLine = block.split('\\n')[0].replace(/^##\\s*/,'').trim();
        var descMatch = block.match(/\\*\\*Description\\*\\*:?\\s*(.+)/);
        var desc = descMatch ? descMatch[1].trim() : '';
        var taskMatches = (block.match(/^- .+/gm)||[]).slice(0,6);
        var tasks = taskMatches.map(function(t){
          var label = t.replace(/^-\\s*/,'').split('—')[0].split('--')[0].trim();
          return '<span class="domain-task">'+esc(label)+'</span>';
        }).join('');
        return '<div class="domain-item">'+
          '<div class="domain-name">'+esc(firstLine)+'</div>'+
          (desc?'<div class="domain-desc">'+esc(desc)+'</div>':'')+
          (tasks?'<div class="domain-tasks">'+tasks+'</div>':'')+
          '</div>';
      }).join('');
    } else {
      domsHtml = '<div style="font-size:12px;color:var(--muted)">No .agentic-os/domains.md found</div>';
    }

    grid.textContent = '';
    grid.insertAdjacentHTML('beforeend',
      '<div class="s-card"><div class="s-card-title">Projects</div>'+projHtml+'</div>'+
      '<div class="s-card"><div class="s-card-title">PRD State</div>'+stRows+'</div>'+
      '<div class="s-card s-full"><div class="s-card-title">Agentic OS Domains</div>'+domsHtml+'</div>'
    );
  } catch(e) {
    grid.textContent = '';
    grid.insertAdjacentHTML('beforeend',
      '<div class="s-card"><div style="color:var(--red);font-size:12px">Failed: '+esc(e.message)+'</div></div>'
    );
  }
}

document.getElementById('btnRefreshSettings').addEventListener('click', function() {
  loaded.settings = false; loadSettings(); loaded.settings = true;
});

// SSE
function connectSSE() {
  var sse = new EventSource('/api/events');
  var dot = document.getElementById('liveDot');
  sse.addEventListener('connected', function() {
    dot.textContent = '● live'; dot.className = 'live-dot on';
  });
  sse.addEventListener('sync', function() {
    if (loaded.board) loadBoard();
    loaded.metrics = false;
  });
  sse.onerror = function() {
    dot.textContent = '○ offline'; dot.className = 'live-dot';
    setTimeout(connectSSE, 5000);
  };
}
connectSSE();

var loaders = {board:loadBoard, metrics:loadMetrics, luv:loadLuv, settings:loadSettings};
navigate(location.hash);
})();
</script>
</body>
</html>`;
}

module.exports = { appPage };
