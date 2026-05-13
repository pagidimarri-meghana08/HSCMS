// ============================================================
//  HSCMS — report.js
//  Dynamic report table, zone/sensor summaries, CSV export
// ============================================================

// Pull mock data from dashboard.js (shared global MOCK_INCIDENTS)
let reportData = typeof MOCK_INCIDENTS !== 'undefined' ? [...MOCK_INCIDENTS] : [];

// ─── ADVISORY ────────────────────────────────────────────────
function getAdvisory(level, anomaly) {
  if (level === "CRITICAL" && anomaly === "YES") return "🚨 Deploy Response Team";
  if (level === "CRITICAL")                      return "🚨 Physical Threat";
  if (level === "HIGH" && anomaly === "YES")     return "⚠ Cyber+Physical";
  if (level === "HIGH")                          return "⚠ Investigate";
  if (level === "MEDIUM")                        return "◎ Monitor";
  return "✔ Routine";
}

function levelBadge(level) {
  const map = { CRITICAL:"badge-critical", HIGH:"badge-high", MEDIUM:"badge-medium", LOW:"badge-low" };
  return `<span class="badge ${map[level]||'badge-low'}">${level}</span>`;
}

// ─── RENDER FULL REPORT TABLE ────────────────────────────────
function renderReportTable(data) {
  const tbody = document.getElementById('reportTbody');
  const count = document.getElementById('rowCount');
  if (!tbody) return;

  if (count) count.textContent = `${data.length} RECORDS`;

  tbody.innerHTML = data.map(ev => `<tr>
    <td style="color:var(--cyan)">${ev.id}</td>
    <td>${ev.ts}</td>
    <td>${ev.cam}</td>
    <td>${ev.zone}</td>
    <td>${ev.sensor}</td>
    <td>${levelBadge(ev.level)}</td>
    <td>${ev.anomaly === "YES" ? '<span style="color:var(--red)">YES</span>' : '<span style="color:var(--green)">NO</span>'}</td>
    <td style="max-width:180px;white-space:normal;font-size:10px">${ev.desc}</td>
    <td style="font-size:10px">${getAdvisory(ev.level, ev.anomaly)}</td>
  </tr>`).join('');
}

// ─── ZONE SUMMARY TABLE ──────────────────────────────────────
function renderZoneSummary(data) {
  const tbody = document.getElementById('zoneTbody');
  if (!tbody) return;
  const zones = ["ZONE-A","ZONE-B","ZONE-C","ZONE-D"];
  tbody.innerHTML = zones.map(z => {
    const zd = data.filter(e => e.zone === z);
    return `<tr>
      <td style="color:var(--cyan)">${z}</td>
      <td>${zd.length}</td>
      <td style="color:var(--red)">${zd.filter(e=>e.level==="CRITICAL").length}</td>
      <td style="color:var(--orange)">${zd.filter(e=>e.level==="HIGH").length}</td>
      <td style="color:var(--yellow)">${zd.filter(e=>e.level==="MEDIUM").length}</td>
      <td style="color:var(--green)">${zd.filter(e=>e.level==="LOW").length}</td>
    </tr>`;
  }).join('');
}

// ─── SENSOR STATS TABLE ──────────────────────────────────────
function renderSensorStats(data) {
  const tbody = document.getElementById('sensorTbody');
  if (!tbody) return;
  const types = ["MOTION","THERMAL","NETWORK","INTRUSION","ACOUSTIC"];
  const lvlScore = {LOW:1,MEDIUM:2,HIGH:3,CRITICAL:4};
  const lvlName  = ["","LOW","MEDIUM","HIGH","CRITICAL"];
  tbody.innerHTML = types.map(t => {
    const td = data.filter(e => e.sensor === t);
    const avgScore = td.length ? Math.round(td.reduce((s,e) => s + (lvlScore[e.level]||1), 0) / td.length) : 0;
    const last = td.length ? td[td.length-1].ts.split(' ')[1] : '--';
    return `<tr>
      <td style="color:var(--cyan)">${t}</td>
      <td>${td.length}</td>
      <td>${td.length ? levelBadge(lvlName[avgScore]||"LOW") : '--'}</td>
      <td>${last}</td>
    </tr>`;
  }).join('');
}

// ─── SUMMARY KPI CARDS ───────────────────────────────────────
function renderSummaryCards(data) {
  const el = document.getElementById('summaryCards');
  if (!el) return;
  const crit = data.filter(e=>e.level==="CRITICAL").length;
  const high = data.filter(e=>e.level==="HIGH").length;
  const anomalies = data.filter(e=>e.anomaly==="YES").length;
  el.innerHTML = `
    <div class="kpi-card critical"><div class="kpi-label">CRITICAL</div><div class="kpi-value">${crit}</div></div>
    <div class="kpi-card warning"><div class="kpi-label">HIGH</div><div class="kpi-value">${high}</div></div>
    <div class="kpi-card neutral"><div class="kpi-label">NETWORK ANOMALIES</div><div class="kpi-value">${anomalies}</div></div>
    <div class="kpi-card info"><div class="kpi-label">TOTAL EVENTS</div><div class="kpi-value">${data.length}</div></div>
    <div class="kpi-card safe"><div class="kpi-label">RESOLVED</div><div class="kpi-value">${data.filter(e=>e.level==="LOW").length}</div></div>
  `;
}

// ─── FILTER ──────────────────────────────────────────────────
function applyFilter() {
  const zone   = document.getElementById('filterZone').value;
  const level  = document.getElementById('filterLevel').value;
  const camera = document.getElementById('filterCamera').value.trim().toUpperCase();

  let filtered = [...reportData];
  if (zone)   filtered = filtered.filter(e => e.zone === zone);
  if (level)  filtered = filtered.filter(e => e.level === level);
  if (camera) filtered = filtered.filter(e => e.cam.includes(camera));

  renderReportTable(filtered);
  renderZoneSummary(filtered);
  renderSensorStats(filtered);
  renderSummaryCards(filtered);
}

function clearFilters() {
  document.getElementById('filterZone').value  = '';
  document.getElementById('filterLevel').value = '';
  document.getElementById('filterCamera').value = '';
  applyFilter();
}

// ─── CSV EXPORT ──────────────────────────────────────────────
function exportCSV() {
  const headers = ["ID","TIMESTAMP","ZONE","CAMERA","SENSOR","THREAT_LEVEL","NETWORK_ANOMALY","DESCRIPTION"];
  const rows = reportData.map(e =>
    [e.id, e.ts, e.zone, e.cam, e.sensor, e.level, e.anomaly, `"${e.desc}"`].join(',')
  );
  const csv = [headers.join(','), ...rows].join('\n');
  const blob = new Blob([csv], {type:'text/csv'});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `HSCMS_Report_${new Date().toISOString().slice(0,10)}.csv`;
  a.click();
}

// ─── INIT ────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  renderReportTable(reportData);
  renderZoneSummary(reportData);
  renderSensorStats(reportData);
  renderSummaryCards(reportData);
});
