<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.hscms.model.*, com.hscms.db.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>HSCMS — Reports</title>
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
    <a href="report.jsp" class="nav-item active"><span class="nav-icon">◎</span><span class="nav-text">Reports</span></a>
    <a href="threatForm.jsp" class="nav-item"><span class="nav-icon">◉</span><span class="nav-text">Log Event</span></a>
    <a href="network.jsp" class="nav-item"><span class="nav-icon">◇</span><span class="nav-text">Network</span></a>
  </nav>
  <div class="sidebar-status">
    <div class="status-dot pulse"></div>
    <span>LIVE MONITORING</span>
  </div>
</aside>

<main class="main-content">
  <header class="topbar">
    <div class="topbar-left">
      <h1 class="page-title">Threat Reports & Analytics</h1>
      <span class="breadcrumb">Smart City / Reports</span>
    </div>
    <div class="topbar-right">
      <div class="clock" id="clock">--:--:--</div>
    </div>
  </header>

  <!-- FILTERS -->
  <div class="filter-bar">
    <div class="filter-group">
      <label>FILTER BY ZONE</label>
      <select id="filterZone" onchange="applyFilter()">
        <option value="">ALL ZONES</option>
        <option value="ZONE-A">Zone A</option>
        <option value="ZONE-B">Zone B</option>
        <option value="ZONE-C">Zone C</option>
        <option value="ZONE-D">Zone D</option>
      </select>
    </div>
    <div class="filter-group">
      <label>THREAT LEVEL</label>
      <select id="filterLevel" onchange="applyFilter()">
        <option value="">ALL LEVELS</option>
        <option value="CRITICAL">CRITICAL</option>
        <option value="HIGH">HIGH</option>
        <option value="MEDIUM">MEDIUM</option>
        <option value="LOW">LOW</option>
      </select>
    </div>
    <div class="filter-group">
      <label>SEARCH CAMERA ID</label>
      <input type="text" id="filterCamera" placeholder="e.g. CAM-01" oninput="applyFilter()"/>
    </div>
    <button class="btn-secondary" onclick="clearFilters()">CLEAR</button>
    <button class="btn-primary" onclick="exportCSV()">EXPORT CSV</button>
  </div>

  <!-- SUMMARY CARDS -->
  <section class="kpi-grid" id="summaryCards">
    <!-- populated by JS from mock data -->
  </section>

  <!-- REPORT TABLE -->
  <div class="panel" style="margin-top:1.5rem">
    <div class="panel-header">
      <span>◉ INCIDENT REPORT — SQL: SELECT * FROM threat_events JOIN response_actions</span>
      <span class="panel-badge live" id="rowCount">0 RECORDS</span>
    </div>
    <div class="table-scroll">
      <table class="incidents-table" id="reportTable">
        <thead>
          <tr>
            <th>EVENT_ID</th><th>TIMESTAMP</th><th>CAMERA_ID</th>
            <th>ZONE</th><th>SENSOR_TYPE</th><th>THREAT_LEVEL</th>
            <th>NETWORK_ANOMALY</th><th>DESCRIPTION</th><th>ADVISORY</th>
          </tr>
        </thead>
        <tbody id="reportTbody"></tbody>
      </table>
    </div>
  </div>

  <!-- THREAT SUMMARY BY ZONE -->
  <section class="panels-row" style="margin-top:1.5rem">
    <div class="panel" style="flex:1">
      <div class="panel-header"><span>◎ THREAT COUNT BY ZONE</span></div>
      <table class="incidents-table" id="zoneTable">
        <thead><tr><th>ZONE</th><th>TOTAL</th><th>CRITICAL</th><th>HIGH</th><th>MEDIUM</th><th>LOW</th></tr></thead>
        <tbody id="zoneTbody"></tbody>
      </table>
    </div>
    <div class="panel" style="flex:1">
      <div class="panel-header"><span>◇ SENSOR ALERT STATISTICS</span></div>
      <table class="incidents-table" id="sensorTable">
        <thead><tr><th>SENSOR TYPE</th><th>ALERTS</th><th>AVG LEVEL</th><th>LAST SEEN</th></tr></thead>
        <tbody id="sensorTbody"></tbody>
      </table>
    </div>
  </section>

</main>

<script src="js/dashboard.js"></script>
<script src="js/report.js"></script>
</body>
</html>
