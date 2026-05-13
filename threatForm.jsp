<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>HSCMS — Log Threat Event</title>
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
    <a href="index.jsp" class="nav-item" data-label="Dashboard"><span class="nav-icon">◈</span><span class="nav-text">Dashboard</span></a>
    <a href="report.jsp" class="nav-item" data-label="Reports"><span class="nav-icon">◎</span><span class="nav-text">Reports</span></a>
    <a href="threatForm.jsp" class="nav-item active" data-label="Log Event"><span class="nav-icon">◉</span><span class="nav-text">Log Event</span></a>
    <a href="network.jsp" class="nav-item" data-label="Network"><span class="nav-icon">◇</span><span class="nav-text">Network</span></a>
  </nav>
  <div class="sidebar-status">
    <div class="status-dot pulse"></div>
    <span>LIVE MONITORING</span>
  </div>
</aside>

<main class="main-content">
  <header class="topbar">
    <div class="topbar-left">
      <h1 class="page-title">Log Threat Event</h1>
      <span class="breadcrumb">Smart City / Log Event</span>
    </div>
    <div class="topbar-right">
      <div class="clock" id="clock">--:--:--</div>
    </div>
  </header>

  <!-- Result banner -->
  <% String result = (String) request.getAttribute("result");
     String resultClass = (String) request.getAttribute("resultClass");
     if(result != null) { %>
  <div class="alert-banner <%= resultClass %>" style="display:flex">
    <span><%= result %></span>
  </div>
  <% } %>

  <div class="form-page">

    <!-- Threat Event Form -->
    <div class="form-card">
      <div class="form-card-header">◉ THREAT EVENT</div>
      <form id="threatForm" action="ThreatServlet" method="POST" onsubmit="return validateThreat()">
        <input type="hidden" name="formType" value="threat"/>
        <div class="form-row">
          <div class="form-group">
            <label>CAMERA ID</label>
            <input type="text" name="cameraId" id="cameraId" placeholder="e.g. CAM-01" required/>
            <span class="form-error" id="cameraIdErr"></span>
          </div>
          <div class="form-group">
            <label>ZONE</label>
            <select name="zone" id="zone" required>
              <option value="">— Select Zone —</option>
              <option value="ZONE-A">Zone A — Central</option>
              <option value="ZONE-B">Zone B — North</option>
              <option value="ZONE-C">Zone C — Industrial</option>
              <option value="ZONE-D">Zone D — Airport</option>
            </select>
            <span class="form-error" id="zoneErr"></span>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>SENSOR TYPE</label>
            <select name="sensorType" id="sensorType" required>
              <option value="">— Select Sensor —</option>
              <option value="MOTION">Motion Sensor</option>
              <option value="THERMAL">Thermal Camera</option>
              <option value="INTRUSION">Intrusion Detector</option>
              <option value="NETWORK">Network Probe</option>
              <option value="ACOUSTIC">Acoustic Sensor</option>
            </select>
          </div>
          <div class="form-group">
            <label>THREAT LEVEL</label>
            <select name="threatLevel" id="threatLevel" onchange="updateThreatPreview()" required>
              <option value="">— Select Level —</option>
              <option value="LOW">LOW</option>
              <option value="MEDIUM">MEDIUM</option>
              <option value="HIGH">HIGH</option>
              <option value="CRITICAL">CRITICAL</option>
            </select>
          </div>
        </div>
        <div class="form-group">
          <label>DESCRIPTION</label>
          <textarea name="description" id="description" rows="3" placeholder="Describe the incident..." required maxlength="500"></textarea>
          <span class="char-count" id="charCount">0 / 500</span>
        </div>
        <div class="form-group">
          <label>NETWORK ANOMALY DETECTED?</label>
          <div class="radio-group">
            <label class="radio-label"><input type="radio" name="networkAnomaly" value="YES"/> YES</label>
            <label class="radio-label"><input type="radio" name="networkAnomaly" value="NO" checked/> NO</label>
          </div>
        </div>

        <!-- Live advisory preview -->
        <div class="advisory-preview" id="advisoryPreview" style="display:none">
          <div class="advisory-icon">⚠</div>
          <div class="advisory-text" id="advisoryText"></div>
        </div>

        <div class="form-actions">
          <button type="reset" class="btn-secondary" onclick="resetPreview()">CLEAR</button>
          <button type="submit" class="btn-primary">SUBMIT THREAT EVENT →</button>
        </div>
      </form>
    </div>

    <!-- Sensor Feed Form -->
    <div class="form-card">
      <div class="form-card-header">◎ SENSOR FEED LOG</div>
      <form id="sensorForm" action="ThreatServlet" method="POST" onsubmit="return validateSensor()">
        <input type="hidden" name="formType" value="sensor"/>
        <div class="form-row">
          <div class="form-group">
            <label>SENSOR ID</label>
            <input type="text" name="sensorId" id="sensorId" placeholder="e.g. SEN-05" required/>
          </div>
          <div class="form-group">
            <label>READING VALUE</label>
            <input type="number" name="readingValue" id="readingValue" placeholder="0–100" min="0" max="100" required/>
            <span class="form-error" id="readingErr"></span>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>UNIT</label>
            <select name="unit" required>
              <option value="°C">°C (Temperature)</option>
              <option value="dB">dB (Sound)</option>
              <option value="%">% (Humidity)</option>
              <option value="lux">lux (Light)</option>
            </select>
          </div>
          <div class="form-group">
            <label>ZONE</label>
            <select name="zone" required>
              <option value="ZONE-A">Zone A</option>
              <option value="ZONE-B">Zone B</option>
              <option value="ZONE-C">Zone C</option>
              <option value="ZONE-D">Zone D</option>
            </select>
          </div>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn-primary" style="margin-left:auto">LOG SENSOR FEED →</button>
        </div>
      </form>
    </div>

    <!-- Network Event Form -->
    <div class="form-card">
      <div class="form-card-header">◇ NETWORK EVENT LOG</div>
      <form id="networkForm" action="ThreatServlet" method="POST" onsubmit="return validateNetwork()">
        <input type="hidden" name="formType" value="network"/>
        <div class="form-row">
          <div class="form-group">
            <label>SOURCE IP</label>
            <input type="text" name="sourceIp" id="sourceIp" placeholder="e.g. 192.168.1.10" required/>
            <span class="form-error" id="ipErr"></span>
          </div>
          <div class="form-group">
            <label>EVENT TYPE</label>
            <select name="eventType" required>
              <option value="PORT_SCAN">Port Scan</option>
              <option value="DDOS">DDoS Attempt</option>
              <option value="INTRUSION">Intrusion</option>
              <option value="MALWARE">Malware Detected</option>
              <option value="UNAUTHORIZED">Unauthorized Access</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>PACKETS (count)</label>
            <input type="number" name="packetCount" placeholder="e.g. 5000" min="1" required/>
          </div>
          <div class="form-group">
            <label>SEVERITY</label>
            <select name="severity" required>
              <option value="LOW">LOW</option>
              <option value="MEDIUM">MEDIUM</option>
              <option value="HIGH">HIGH</option>
            </select>
          </div>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn-primary" style="margin-left:auto">LOG NETWORK EVENT →</button>
        </div>
      </form>
    </div>

  </div>
</main>

<script src="js/dashboard.js"></script>
<script src="js/forms.js"></script>
</body>
</html>
