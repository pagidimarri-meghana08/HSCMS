// ============================================================
//  HSCMS — dashboard.js
//  Mock data engine + live clock + sensor + incident rendering
// ============================================================

// ─── MOCK DATA ───────────────────────────────────────────────
const MOCK_INCIDENTS = [
  { id:"EVT-001", ts:"2025-03-19 08:12:04", zone:"ZONE-A", cam:"CAM-01", sensor:"MOTION",    level:"CRITICAL", anomaly:"YES", desc:"Unauthorized entry at Gate 3" },
  { id:"EVT-002", ts:"2025-03-19 08:15:30", zone:"ZONE-B", cam:"CAM-03", sensor:"THERMAL",   level:"HIGH",     anomaly:"NO",  desc:"Heat signature — unregistered vehicle" },
  { id:"EVT-003", ts:"2025-03-19 08:22:11", zone:"ZONE-C", cam:"CAM-05", sensor:"NETWORK",   level:"HIGH",     anomaly:"YES", desc:"Port scan detected from 10.22.4.8" },
  { id:"EVT-004", ts:"2025-03-19 08:31:55", zone:"ZONE-D", cam:"CAM-06", sensor:"INTRUSION", level:"CRITICAL", anomaly:"YES", desc:"Perimeter breach — Airport sector" },
  { id:"EVT-005", ts:"2025-03-19 08:40:22", zone:"ZONE-A", cam:"CAM-02", sensor:"ACOUSTIC",  level:"MEDIUM",   anomaly:"NO",  desc:"Elevated noise level in Zone A" },
  { id:"EVT-006", ts:"2025-03-19 09:01:07", zone:"ZONE-B", cam:"CAM-04", sensor:"MOTION",    level:"LOW",      anomaly:"NO",  desc:"Routine patrol flagged" },
  { id:"EVT-007", ts:"2025-03-19 09:14:43", zone:"ZONE-C", cam:"CAM-05", sensor:"THERMAL",   level:"MEDIUM",   anomaly:"NO",  desc:"Temperature spike in server room" },
  { id:"EVT-008", ts:"2025-03-19 09:28:18", zone:"ZONE-A", cam:"CAM-01", sensor:"NETWORK",   level:"CRITICAL", anomaly:"YES", desc:"DDoS attack — 48k packets/sec" },
];

const MOCK_SENSORS = [
  { id:"SEN-01", name:"MOTION / Zone A", val:87,  unit:"%" , color:"#ff2d4e" },
  { id:"SEN-02", name:"THERMAL / Zone B", val:62, unit:"°C", color:"#ff7c2a" },
  { id:"SEN-03", name:"ACOUSTIC / Zone A", val:44,unit:"dB", color:"#ffe533" },
  { id:"SEN-04", name:"NETWORK / Zone C", val:91, unit:"%" , color:"#ff2d4e" },
  { id:"SEN-05", name:"INTRUSION / Zone D",val:33,unit:"%" , color:"#00ff9d" },
  { id:"SEN-06", name:"HUMIDITY / Zone B", val:58,unit:"%" , color:"#00d4ff" },
];

const MOCK_CYBER = [
  { label:"INTRUSION ATTEMPTS", val:"14 today" },
  { label:"BLOCKED IPs",        val:"7 active" },
  { label:"OPEN PORTS",         val:"3 critical" },
  { label:"MALWARE ALERTS",     val:"2 quarantined" },
  { label:"FIREWALL EVENTS",    val:"312 today" },
];

// ─── ADVISORY ENGINE ─────────────────────────────────────────
function runAdvisory(level, anomaly) {
  const isAnomaly = (anomaly === "YES");
  if (level === "CRITICAL" && isAnomaly) return { msg: "🚨 CRITICAL ALERT: Immediate response required — combined physical + cyber threat!", cls: "alert-critical" };
  if (level === "CRITICAL")             return { msg: "🚨 CRITICAL: Physical threat detected. Deploy response team immediately.", cls: "alert-critical" };
  if (level === "HIGH" && isAnomaly)    return { msg: "⚠ HIGH ALERT: Network anomaly combined with sensor trigger. Investigate now.", cls: "alert-warning" };
  if (level === "HIGH")                 return { msg: "⚠ HIGH: Elevated threat level. Monitor and prepare response.", cls: "alert-warning" };
  if (level === "MEDIUM")               return { msg: "◎ MEDIUM: Threat flagged. Continue monitoring — no immediate action needed.", cls: "alert-warning" };
  return { msg: "✔ LOW: Routine flag. No action required.", cls: "alert-safe" };
}

// ─── BADGE HELPER ────────────────────────────────────────────
function levelBadge(level) {
  const map = { CRITICAL:"badge-critical", HIGH:"badge-high", MEDIUM:"badge-medium", LOW:"badge-low" };
  return `<span class="badge ${map[level]||'badge-low'}">${level}</span>`;
}

// ─── RENDER INCIDENTS TABLE ──────────────────────────────────
function renderIncidents(data, tbodyId) {
  const tbody = document.getElementById(tbodyId);
  if (!tbody) return;
  tbody.innerHTML = data.map(ev => {
    const adv = runAdvisory(ev.level, ev.anomaly);
    const shortAdv = adv.msg.substring(0, 40) + (adv.msg.length > 40 ? "…" : "");
    return `<tr>
      <td style="color:var(--cyan)">${ev.id}</td>
      <td>${ev.ts}</td>
      <td>${ev.zone}</td>
      <td>${ev.cam}</td>
      <td>${ev.sensor}</td>
      <td>${levelBadge(ev.level)}</td>
      <td>${ev.anomaly === "YES" ? '<span style="color:var(--red)">YES</span>' : '<span style="color:var(--green)">NO</span>'}</td>
    </tr>`;
  }).join('');
}

// ─── RENDER SENSORS ──────────────────────────────────────────
function renderSensors() {
  const el = document.getElementById('sensorList');
  if (!el) return;
  el.innerHTML = MOCK_SENSORS.map(s => `
    <div class="sensor-item">
      <div class="sensor-dot" style="background:${s.color};box-shadow:0 0 6px ${s.color}"></div>
      <div class="sensor-name">${s.name}</div>
      <div class="sensor-val">${s.val}${s.unit}</div>
      <div class="sensor-bar-wrap">
        <div class="sensor-bar" style="width:${s.val}%;background:${s.color}"></div>
      </div>
    </div>
  `).join('');
}

// ─── RENDER CYBER LIST ───────────────────────────────────────
function renderCyber() {
  const el = document.getElementById('cyberList');
  if (!el) return;
  el.innerHTML = MOCK_CYBER.map(c => `
    <div class="cyber-item">
      <span class="cyber-label">${c.label}</span>
      <span class="cyber-val">${c.val}</span>
    </div>
  `).join('');
}

// ─── NETWORK MINI CHART ──────────────────────────────────────
function drawNetworkChart() {
  const canvas = document.getElementById('networkChart');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const pts = Array.from({length:20}, () => Math.random() * 80 + 10);
  const w = canvas.width, h = canvas.height;
  ctx.clearRect(0, 0, w, h);

  // Grid lines
  ctx.strokeStyle = '#1a3a5c';
  ctx.lineWidth = 1;
  for (let i = 0; i < 4; i++) {
    ctx.beginPath();
    ctx.moveTo(0, (h/4)*i); ctx.lineTo(w, (h/4)*i);
    ctx.stroke();
  }

  // Gradient fill
  const grad = ctx.createLinearGradient(0, 0, 0, h);
  grad.addColorStop(0, 'rgba(0,212,255,0.3)');
  grad.addColorStop(1, 'rgba(0,212,255,0)');
  ctx.beginPath();
  pts.forEach((p, i) => {
    const x = (i / (pts.length-1)) * w;
    const y = h - (p/100)*h;
    i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
  });
  ctx.lineTo(w, h); ctx.lineTo(0, h); ctx.closePath();
  ctx.fillStyle = grad; ctx.fill();

  // Line
  ctx.beginPath();
  pts.forEach((p, i) => {
    const x = (i / (pts.length-1)) * w;
    const y = h - (p/100)*h;
    i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
  });
  ctx.strokeStyle = '#00d4ff'; ctx.lineWidth = 2;
  ctx.shadowColor = '#00d4ff'; ctx.shadowBlur = 6;
  ctx.stroke();
  ctx.shadowBlur = 0;
}

// ─── KPI COUNTERS ────────────────────────────────────────────
function updateKPIs(data) {
  const critEl   = document.getElementById('kpiCritical');
  const alertsEl = document.getElementById('kpiAlerts');
  if (critEl)   critEl.textContent   = data.filter(e => e.level === "CRITICAL").length;
  if (alertsEl) alertsEl.textContent = data.filter(e => e.level !== "LOW").length;
}

// ─── ZONE FILTER ─────────────────────────────────────────────
let _allIncidents = [...MOCK_INCIDENTS];
function filterByZone(zone) {
  const filtered = zone === "ALL" || zone === ""
    ? _allIncidents
    : _allIncidents.filter(e => e.zone === zone);
  renderIncidents(filtered, 'incidentsTbody');
  updateKPIs(filtered);
}

// ─── CLOCK ───────────────────────────────────────────────────
function startClock() {
  const update = () => {
    const el = document.getElementById('clock');
    if (el) el.textContent = new Date().toLocaleTimeString('en-GB', {hour12:false});
  };
  update();
  setInterval(update, 1000);
}

// ─── LIVE SENSOR FLUCTUATION ─────────────────────────────────
function startSensorUpdates() {
  setInterval(() => {
    MOCK_SENSORS.forEach(s => {
      s.val = Math.max(5, Math.min(99, s.val + (Math.random()*6 - 3)));
      s.val = Math.round(s.val);
    });
    renderSensors();
    drawNetworkChart();
  }, 2000);
}

// ─── INIT ────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  startClock();
  renderSensors();
  renderCyber();
  renderIncidents(_allIncidents, 'incidentsTbody');
  updateKPIs(_allIncidents);
  drawNetworkChart();
  startSensorUpdates();
});
