// ============================================================
//  HSCMS — forms.js
//  Client-side validation + Advisory Engine preview
// ============================================================

// ─── ADVISORY PREVIEW (live) ─────────────────────────────────
function updateThreatPreview() {
  const level   = document.getElementById('threatLevel').value;
  const anomaly = document.querySelector('input[name="networkAnomaly"]:checked');
  const preview = document.getElementById('advisoryPreview');
  const text    = document.getElementById('advisoryText');
  if (!level) { preview.style.display = 'none'; return; }

  const isAnomaly = anomaly && anomaly.value === "YES";
  let msg, cls, borderColor;

  if (level === "CRITICAL" && isAnomaly) {
    msg = "🚨 CRITICAL ALERT: Immediate response required — combined physical + cyber threat!";
    cls = "alert-critical"; borderColor = "#ff2d4e";
  } else if (level === "CRITICAL") {
    msg = "🚨 CRITICAL: Physical threat detected. Deploy response team immediately.";
    cls = "alert-critical"; borderColor = "#ff2d4e";
  } else if (level === "HIGH" && isAnomaly) {
    msg = "⚠ HIGH ALERT: Network anomaly combined with sensor trigger. Investigate now.";
    cls = "alert-warning"; borderColor = "#ff7c2a";
  } else if (level === "HIGH") {
    msg = "⚠ HIGH: Elevated threat level. Monitor and prepare response.";
    cls = "alert-warning"; borderColor = "#ff7c2a";
  } else if (level === "MEDIUM") {
    msg = "◎ MEDIUM: Threat flagged. Continue monitoring — no immediate action.";
    cls = "alert-warning"; borderColor = "#ffe533";
  } else {
    msg = "✔ LOW: Routine flag. No action required.";
    cls = "alert-safe"; borderColor = "#00ff9d";
  }

  preview.className = `advisory-preview ${cls}`;
  preview.style.cssText = `display:flex;border-color:${borderColor}`;
  text.textContent = msg;
}

function resetPreview() {
  const preview = document.getElementById('advisoryPreview');
  if (preview) preview.style.display = 'none';
}

// ─── CHAR COUNTER ────────────────────────────────────────────
const descEl = document.getElementById('description');
if (descEl) {
  descEl.addEventListener('input', () => {
    const count = document.getElementById('charCount');
    if (count) count.textContent = `${descEl.value.length} / 500`;
  });
}

// ─── VALIDATE THREAT FORM ────────────────────────────────────
function validateThreat() {
  let valid = true;

  const camId = document.getElementById('cameraId');
  const camErr = document.getElementById('cameraIdErr');
  if (camId && !/^CAM-\d{2}$/i.test(camId.value.trim())) {
    camErr.textContent = "Format must be CAM-XX (e.g. CAM-01)";
    camId.classList.add('error');
    valid = false;
  } else if (camId) {
    camErr.textContent = "";
    camId.classList.remove('error');
  }

  const zone = document.getElementById('zone');
  const zoneErr = document.getElementById('zoneErr');
  if (zone && !zone.value) {
    zoneErr.textContent = "Please select a zone.";
    valid = false;
  } else if (zoneErr) {
    zoneErr.textContent = "";
  }

  const desc = document.getElementById('description');
  if (desc && desc.value.trim().length < 10) {
    desc.classList.add('error');
    valid = false;
  } else if (desc) {
    desc.classList.remove('error');
  }

  if (!valid) {
    showFormError("Please fix the errors before submitting.");
  }
  return valid;
}

// ─── VALIDATE SENSOR FORM ────────────────────────────────────
function validateSensor() {
  const val = document.getElementById('readingValue');
  const err = document.getElementById('readingErr');
  if (val && (val.value < 0 || val.value > 100)) {
    err.textContent = "Value must be between 0 and 100.";
    val.classList.add('error');
    return false;
  }
  if (err) err.textContent = "";
  return true;
}

// ─── VALIDATE NETWORK FORM ───────────────────────────────────
function validateNetwork() {
  const ip = document.getElementById('sourceIp');
  const err = document.getElementById('ipErr');
  const ipRegex = /^(\d{1,3}\.){3}\d{1,3}$/;
  if (ip && !ipRegex.test(ip.value.trim())) {
    err.textContent = "Enter a valid IPv4 address (e.g. 192.168.1.10)";
    ip.classList.add('error');
    return false;
  }
  if (err) err.textContent = "";
  return true;
}

// ─── INLINE FORM ERROR ───────────────────────────────────────
function showFormError(msg) {
  const b = document.getElementById('alertBanner');
  const t = document.getElementById('alertText');
  if (b && t) {
    b.className = 'alert-banner alert-warning';
    b.style.display = 'flex';
    t.textContent = msg;
  }
}

// ─── RADIO CHANGE → update advisory ────────────────────────
document.querySelectorAll('input[name="networkAnomaly"]').forEach(r => {
  r.addEventListener('change', updateThreatPreview);
});
