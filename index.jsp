<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.hscms.model.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>HSCMS — Smart City Security</title>
  <link rel="stylesheet" href="css/style.css"/>
  <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Exo+2:wght@300;400;600;800&display=swap" rel="stylesheet"/>
</head>
<body>

<!-- SIDEBAR -->
<aside class="sidebar" id="sidebar">
  <div class="sidebar-logo">
    <span class="logo-icon">⬡</span>
    <span class="logo-text">HSCMS</span>
  </div>
  <nav class="sidebar-nav">
    <a href="index.jsp" class="nav-item active" data-label="Dashboard"><span class="nav-icon">◈</span><span class="nav-text">Dashboard</span></a>
    <a href="report.jsp" class="nav-item" data-label="Reports"><span class="nav-icon">◎</span><span class="nav-text">Reports</span></a>
    <a href="threatForm.jsp" class="nav-item" data-label="Log Event"><span class="nav-icon">◉</span><span class="nav-text">Log Event</span></a>
    <a href="network.jsp" class="nav-item" data-label="Network"><span class="nav-icon">◇</span><span class="nav-text">Network</span></a>
  </nav>
  <div class="sidebar-status">
    <div class="status-dot pulse"></div>
    <span>LIVE MONITORING</span>
  </div>
</aside>

<!-- MAIN CONTENT -->
<main class="main-content">

  <!-- TOP BAR -->
  <header class="topbar">
    <div class="topbar-left">
      <h1 class="page-title">Security Operations Center</h1>
      <span class="breadcrumb">Smart City / Dashboard</span>
    </div>
    <div class="topbar-right">
      <div class="zone-selector">
        <label>ZONE</label>
        <select id="zoneFilter" onchange="filterByZone(this.value)">
          <option value="ALL">ALL ZONES</option>
          <option value="ZONE-A">Zone A — Central</option>
          <option value="ZONE-B">Zone B — North</option>
          <option value="ZONE-C">Zone C — Industrial</option>
          <option value="ZONE-D">Zone D — Airport</option>
        </select>
      </div>
      <div class="clock" id="clock">--:--:--</div>
    </div>
  </header>

  <!-- ALERT BANNER -->
  <% String alertMsg = (String) request.getAttribute("alertMsg");
     String alertClass = (String) request.getAttribute("alertClass");
     if(alertMsg == null) { alertMsg = ""; alertClass = ""; } %>
  <div id="alertBanner" class="alert-banner <%= alertClass %>" style="<%= alertMsg.isEmpty() ? "display:none" : "" %>">
    <span id="alertText"><%= alertMsg %></span>
    <button onclick="document.getElementById('alertBanner').style.display='none'">✕</button>
  </div>

  <!-- KPI CARDS -->
  <section class="kpi-grid">
    <div class="kpi-card critical">
      <div class="kpi-label">CRITICAL THREATS</div>
      <div class="kpi-value" id="kpiCritical">0</div>
      <div class="kpi-sub">↑ Real-time count</div>
    </div>
    <div class="kpi-card warning">
      <div class="kpi-label">ACTIVE ALERTS</div>
      <div class="kpi-value" id="kpiAlerts">0</div>
      <div class="kpi-sub">Across all zones</div>
    </div>
    <div class="kpi-card info">
      <div class="kpi-label">CAMERAS ONLINE</div>
      <div class="kpi-value" id="kpiCameras">12</div>
      <div class="kpi-sub">4 zones monitored</div>
    </div>
    <div class="kpi-card safe">
      <div class="kpi-label">NETWORK STATUS</div>
      <div class="kpi-value" id="kpiNetwork">99.2%</div>
      <div class="kpi-sub">Uptime this session</div>
    </div>
    <div class="kpi-card neutral">
      <div class="kpi-label">AVG RESPONSE TIME</div>
      <div class="kpi-value" id="kpiResponse">2.4<span style="font-size:1rem">min</span></div>
      <div class="kpi-sub">Last 10 incidents</div>
    </div>
  </section>

  <!-- PANELS ROW -->
  <section class="panels-row">

    <!-- CAMERA FEEDS -->
    <div class="panel camera-panel">
      <div class="panel-header">
        <span>◈ CAMERA FEEDS</span>
        <span class="panel-badge live">LIVE</span>
      </div>
      <div class="camera-grid">
        <% String[] zones = {"CAM-01 / Zone A","CAM-02 / Zone A","CAM-03 / Zone B","CAM-04 / Zone B","CAM-05 / Zone C","CAM-06 / Zone D"}; %>
        <% for(String cam : zones) { %>
        <div class="camera-feed">
          <div class="cam-screen">
            <div class="scan-line"></div>
            <div class="cam-overlay">
              <span class="rec-dot">● REC</span>
            </div>
            <div class="cam-noise"></div>
          </div>
          <div class="cam-label"><%= cam %></div>
        </div>
        <% } %>
      </div>
    </div>

    <!-- SENSOR STATUS -->
    <div class="panel sensor-panel">
      <div class="panel-header">
        <span>◎ SENSOR STATUS</span>
        <span class="panel-badge ok">ALL ACTIVE</span>
      </div>
      <div class="sensor-list" id="sensorList">
        <!-- populated by JS -->
      </div>
    </div>

  </section>

  <!-- INCIDENTS + CYBER -->
  <section class="panels-row">

    <!-- INCIDENTS TABLE -->
    <div class="panel incidents-panel">
      <div class="panel-header">
        <span>◉ RECENT INCIDENTS</span>
        <a href="threatForm.jsp" class="add-btn">+ LOG EVENT</a>
      </div>
      <div class="table-scroll">
        <table class="incidents-table" id="incidentsTable">
          <thead>
            <tr>
              <th>ID</th><th>TIMESTAMP</th><th>ZONE</th><th>CAMERA</th>
              <th>SENSOR</th><th>THREAT</th><th>STATUS</th>
            </tr>
          </thead>
          <tbody id="incidentsTbody">
            <!-- populated by JS -->
          </tbody>
        </table>
      </div>
    </div>

    <!-- CYBER INDICATORS -->
    <div class="panel cyber-panel">
      <div class="panel-header">
        <span>◇ CYBER INDICATORS</span>
      </div>
      <div class="cyber-list" id="cyberList">
        <!-- populated by JS -->
      </div>
      <div class="network-graph">
        <canvas id="networkChart" width="260" height="120"></canvas>
      </div>
    </div>

  </section>

</main>

<script src="js/dashboard.js"></script>
</body>
</html>
