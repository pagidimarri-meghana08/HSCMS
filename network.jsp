<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>HSCMS — Network Monitor</title>
  <link rel="stylesheet" href="css/style.css"/>
  <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Exo+2:wght@300;400;600;800&display=swap" rel="stylesheet"/>
</head>
<body>

<aside class="sidebar">
  <div class="sidebar-logo">
    <span class="logo-icon">⬡</span>
    <span class="logo-text">HSCMS</span>
  </div>
  <nav class="sidebar-nav">
    <a href="index.jsp" class="nav-item"><span class="nav-icon">◈</span><span class="nav-text">Dashboard</span></a>
    <a href="report.jsp" class="nav-item"><span class="nav-icon">◎</span><span class="nav-text">Reports</span></a>
    <a href="threatForm.jsp" class="nav-item"><span class="nav-icon">◉</span><span class="nav-text">Log Event</span></a>
    <a href="network.jsp" class="nav-item active"><span class="nav-icon">◇</span><span class="nav-text">Network</span></a>
  </nav>
  <div class="sidebar-status">
    <div class="status-dot pulse"></div>
    <span>LIVE MONITORING</span>
  </div>
</aside>

<main class="main-content">
  <header class="topbar">
    <div class="topbar-left">
      <h1 class="page-title">Network Security Monitor</h1>
      <span class="breadcrumb">Smart City / Network</span>
    </div>
    <div class="topbar-right">
      <div class="clock" id="clock">--:--:--</div>
    </div>
  </header>

  <!-- Network KPIs -->
  <section class="kpi-grid">
    <div class="kpi-card critical"><div class="kpi-label">BLOCKED IPs</div><div class="kpi-value" id="blockedIps">0</div></div>
    <div class="kpi-card warning"><div class="kpi-label">ACTIVE CONNECTIONS</div><div class="kpi-value" id="activeConn">0</div></div>
    <div class="kpi-card info"><div class="kpi-label">PACKETS/SEC</div><div class="kpi-value" id="pps">0</div></div>
    <div class="kpi-card safe"><div class="kpi-label">BANDWIDTH USED</div><div class="kpi-value" id="bw">0<span style="font-size:1rem">MB</span></div></div>
    <div class="kpi-card neutral"><div class="kpi-label">FIREWALL RULES</div><div class="kpi-value">24</div></div>
  </section>

  <section class="panels-row" style="margin-top:1.5rem">
    <!-- Live Network Log -->
    <div class="panel" style="flex:2">
      <div class="panel-header">
        <span>◇ LIVE NETWORK LOG</span>
        <span class="panel-badge live">STREAMING</span>
      </div>
      <div class="table-scroll" style="max-height:320px">
        <table class="incidents-table">
          <thead>
            <tr><th>TIME</th><th>SOURCE IP</th><th>DEST IP</th><th>EVENT</th><th>PACKETS</th><th>SEVERITY</th></tr>
          </thead>
          <tbody id="networkLogTbody"></tbody>
        </table>
      </div>
    </div>

    <!-- IP Blacklist -->
    <div class="panel" style="flex:1">
      <div class="panel-header"><span>⛔ IP BLACKLIST</span></div>
      <div class="blacklist" id="blacklist"></div>
    </div>
  </section>

  <!-- Topology Map -->
  <div class="panel" style="margin-top:1.5rem">
    <div class="panel-header"><span>◈ CITY NETWORK TOPOLOGY</span></div>
    <canvas id="topoCanvas" width="900" height="300" style="width:100%;border-radius:6px"></canvas>
  </div>

</main>

<script src="js/dashboard.js"></script>
<script src="js/network.js"></script>
</body>
</html>
