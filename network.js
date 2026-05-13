// ============================================================
//  HSCMS — network.js
//  Live network log streaming, blacklist, topology canvas
// ============================================================

const EVENT_TYPES = ["PORT_SCAN","DDoS","INTRUSION","MALWARE","UNAUTH_ACCESS","BRUTE_FORCE"];
const SEVERITIES  = ["LOW","MEDIUM","HIGH"];
const IPS = ["10.22.4.8","192.168.0.44","172.16.3.99","203.0.113.5","198.51.100.12","10.0.0.254","192.0.2.1"];
const DEST_IPS = ["10.10.1.1","192.168.1.254","10.10.2.5","172.31.0.1"];

const BLACKLIST = [
  { ip:"10.22.4.8",      reason:"PORT_SCAN",  count:42 },
  { ip:"203.0.113.5",    reason:"DDoS",       count:91 },
  { ip:"198.51.100.12",  reason:"MALWARE",    count:17 },
  { ip:"192.0.2.1",      reason:"BRUTE_FORCE",count:28 },
  { ip:"45.33.32.156",   reason:"INTRUSION",  count:5  },
];

let networkLog = [];
let kpiState = { blocked: BLACKLIST.length, conns: 147, pps: 1240, bw: 342 };

// ─── RENDER BLACKLIST ─────────────────────────────────────────
function renderBlacklist() {
  const el = document.getElementById('blacklist');
  if (!el) return;
  el.innerHTML = BLACKLIST.map(b => `
    <div class="blacklist-item">
      <span>${b.ip}</span>
      <span>${b.reason} (${b.count})</span>
    </div>
  `).join('');
}

// ─── GENERATE NETWORK EVENT ───────────────────────────────────
function generateNetworkEvent() {
  const now = new Date().toLocaleTimeString('en-GB', {hour12:false});
  const src = IPS[Math.floor(Math.random()*IPS.length)];
  const dst = DEST_IPS[Math.floor(Math.random()*DEST_IPS.length)];
  const evt = EVENT_TYPES[Math.floor(Math.random()*EVENT_TYPES.length)];
  const sev = SEVERITIES[Math.floor(Math.random()*SEVERITIES.length)];
  const pkts = Math.floor(Math.random()*9000) + 100;
  return { time:now, src, dst, evt, pkts, sev };
}

// ─── RENDER NETWORK LOG ───────────────────────────────────────
function renderNetworkLog() {
  const tbody = document.getElementById('networkLogTbody');
  if (!tbody) return;
  const sevClass = { LOW:"badge-low", MEDIUM:"badge-medium", HIGH:"badge-high" };
  tbody.innerHTML = networkLog.slice(-15).reverse().map(e => `<tr>
    <td style="color:var(--cyan)">${e.time}</td>
    <td style="color:var(--red)">${e.src}</td>
    <td>${e.dst}</td>
    <td>${e.evt}</td>
    <td>${e.pkts.toLocaleString()}</td>
    <td><span class="badge ${sevClass[e.sev]||'badge-low'}">${e.sev}</span></td>
  </tr>`).join('');
}

// ─── UPDATE KPIs ─────────────────────────────────────────────
function updateNetworkKPIs() {
  kpiState.conns += Math.floor(Math.random()*6) - 2;
  kpiState.pps   += Math.floor(Math.random()*200) - 90;
  kpiState.bw    += Math.floor(Math.random()*10);
  kpiState.conns = Math.max(100, kpiState.conns);
  kpiState.pps   = Math.max(500, kpiState.pps);

  const el = (id) => document.getElementById(id);
  if (el('blockedIps'))  el('blockedIps').textContent  = kpiState.blocked;
  if (el('activeConn'))  el('activeConn').textContent  = kpiState.conns;
  if (el('pps'))         el('pps').textContent         = kpiState.pps.toLocaleString();
  if (el('bw'))          el('bw').innerHTML            = `${kpiState.bw}<span style="font-size:1rem">MB</span>`;
}

// ─── TOPOLOGY CANVAS ─────────────────────────────────────────
function drawTopology() {
  const canvas = document.getElementById('topoCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const W = canvas.width, H = canvas.height;
  ctx.clearRect(0, 0, W, H);

  // Background grid
  ctx.strokeStyle = 'rgba(26,58,92,0.4)';
  ctx.lineWidth = 1;
  for (let x = 0; x < W; x += 60) { ctx.beginPath(); ctx.moveTo(x,0); ctx.lineTo(x,H); ctx.stroke(); }
  for (let y = 0; y < H; y += 60) { ctx.beginPath(); ctx.moveTo(0,y); ctx.lineTo(W,y); ctx.stroke(); }

  // Nodes
  const nodes = [
    { x:450, y:150, label:"CITY HUB",   color:"#00d4ff", r:22, glow:true  },
    { x:150, y:80,  label:"ZONE A",     color:"#00ff9d", r:16, glow:false },
    { x:150, y:220, label:"ZONE B",     color:"#00ff9d", r:16, glow:false },
    { x:750, y:80,  label:"ZONE C",     color:"#ffe533", r:16, glow:false },
    { x:750, y:220, label:"ZONE D",     color:"#ff7c2a", r:16, glow:false },
    { x:450, y:40,  label:"FIREWALL",   color:"#ff2d4e", r:14, glow:false },
    { x:450, y:260, label:"INTERNET",   color:"#6a90b8", r:14, glow:false },
    { x:280, y:150, label:"SW-01",      color:"#00d4ff", r:10, glow:false },
    { x:620, y:150, label:"SW-02",      color:"#00d4ff", r:10, glow:false },
  ];

  const edges = [
    [0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,8],
    [7,1],[7,2],[8,3],[8,4]
  ];

  // Draw edges
  edges.forEach(([a,b]) => {
    ctx.beginPath();
    ctx.moveTo(nodes[a].x, nodes[a].y);
    ctx.lineTo(nodes[b].x, nodes[b].y);
    ctx.strokeStyle = 'rgba(0,212,255,0.25)';
    ctx.lineWidth = 1.5;
    ctx.setLineDash([4,4]);
    ctx.stroke();
    ctx.setLineDash([]);
  });

  // Animated packet (time-based)
  const t = (Date.now() % 3000) / 3000;
  const packetX = nodes[0].x + (nodes[1].x - nodes[0].x) * t;
  const packetY = nodes[0].y + (nodes[1].y - nodes[0].y) * t;
  ctx.beginPath();
  ctx.arc(packetX, packetY, 4, 0, Math.PI*2);
  ctx.fillStyle = '#00d4ff';
  ctx.shadowColor = '#00d4ff'; ctx.shadowBlur = 10;
  ctx.fill();
  ctx.shadowBlur = 0;

  // Draw nodes
  nodes.forEach(n => {
    if (n.glow) { ctx.shadowColor = n.color; ctx.shadowBlur = 20; }
    ctx.beginPath();
    ctx.arc(n.x, n.y, n.r, 0, Math.PI*2);
    ctx.fillStyle = 'rgba(6,14,28,0.9)';
    ctx.fill();
    ctx.strokeStyle = n.color;
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.shadowBlur = 0;

    ctx.fillStyle = n.color;
    ctx.font = `bold 10px 'Share Tech Mono', monospace`;
    ctx.textAlign = 'center';
    ctx.fillText(n.label, n.x, n.y + n.r + 14);
  });
}

// ─── STREAMING LOOP ──────────────────────────────────────────
function startStreaming() {
  setInterval(() => {
    networkLog.push(generateNetworkEvent());
    if (networkLog.length > 50) networkLog.shift();
    renderNetworkLog();
    updateNetworkKPIs();
    drawTopology();
  }, 1500);
}

// ─── INIT ────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  renderBlacklist();
  updateNetworkKPIs();
  drawTopology();
  // Seed initial log
  for (let i = 0; i < 10; i++) networkLog.push(generateNetworkEvent());
  renderNetworkLog();
  startStreaming();
  setInterval(drawTopology, 100); // animate packets
});
