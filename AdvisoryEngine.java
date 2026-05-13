package com.hscms.engine;

import com.hscms.model.ThreatEvent;

/**
 * HSCMS — AdvisoryEngine.java
 * Rule-based advisory engine for threat assessment.
 *
 * Rules (6–10):
 *  R1: CRITICAL + NETWORK_ANOMALY=YES → "CRITICAL: Combined physical+cyber threat"
 *  R2: CRITICAL + INTRUSION sensor    → "CRITICAL: Physical breach detected"
 *  R3: CRITICAL (any)                 → "CRITICAL: Immediate response required"
 *  R4: HIGH + NETWORK_ANOMALY=YES     → "HIGH: Cyber+physical combined alert"
 *  R5: HIGH + NETWORK sensor          → "HIGH: Network attack in progress"
 *  R6: HIGH (any)                     → "HIGH: Elevated threat — investigate"
 *  R7: MEDIUM + NETWORK_ANOMALY=YES   → "WARNING: Anomaly with medium threat"
 *  R8: MEDIUM                         → "MEDIUM: Monitor closely"
 *  R9: LOW + NETWORK_ANOMALY=YES      → "INFO: Low threat but anomaly present"
 * R10: LOW                            → "LOW: Routine — no action needed"
 */
public class AdvisoryEngine {

    // Alert CSS classes for JSP rendering
    public static final String CLASS_CRITICAL = "alert-critical";
    public static final String CLASS_WARNING  = "alert-warning";
    public static final String CLASS_SAFE     = "alert-safe";

    /**
     * Evaluate threat and return advisory result.
     */
    public static AdvisoryResult evaluate(ThreatEvent event) {
        if (event == null) {
            return new AdvisoryResult("✔ No event data.", CLASS_SAFE);
        }

        String level   = event.getThreatLevel();
        String sensor  = event.getSensorType();
        boolean anomaly = "YES".equalsIgnoreCase(event.getNetworkAnomaly());

        // ── RULE 1 ─────────────────────────────────────────
        if ("CRITICAL".equals(level) && anomaly) {
            return new AdvisoryResult(
                "🚨 CRITICAL ALERT: Combined physical + cyber threat detected. Deploy response team immediately!",
                CLASS_CRITICAL
            );
        }
        // ── RULE 2 ─────────────────────────────────────────
        if ("CRITICAL".equals(level) && "INTRUSION".equals(sensor)) {
            return new AdvisoryResult(
                "🚨 CRITICAL: Physical perimeter breach detected via intrusion sensor. Lockdown initiated.",
                CLASS_CRITICAL
            );
        }
        // ── RULE 3 ─────────────────────────────────────────
        if ("CRITICAL".equals(level)) {
            return new AdvisoryResult(
                "🚨 CRITICAL: High-priority threat event logged. Immediate intervention required.",
                CLASS_CRITICAL
            );
        }
        // ── RULE 4 ─────────────────────────────────────────
        if ("HIGH".equals(level) && anomaly) {
            return new AdvisoryResult(
                "⚠ HIGH ALERT: Network anomaly combined with physical sensor trigger. Investigate immediately.",
                CLASS_WARNING
            );
        }
        // ── RULE 5 ─────────────────────────────────────────
        if ("HIGH".equals(level) && "NETWORK".equals(sensor)) {
            return new AdvisoryResult(
                "⚠ HIGH: Active network attack detected. Review firewall rules and isolate affected nodes.",
                CLASS_WARNING
            );
        }
        // ── RULE 6 ─────────────────────────────────────────
        if ("HIGH".equals(level)) {
            return new AdvisoryResult(
                "⚠ HIGH: Elevated threat detected. Monitor closely and prepare response team.",
                CLASS_WARNING
            );
        }
        // ── RULE 7 ─────────────────────────────────────────
        if ("MEDIUM".equals(level) && anomaly) {
            return new AdvisoryResult(
                "◎ WARNING: Medium threat with network anomaly. Log for review and increase monitoring frequency.",
                CLASS_WARNING
            );
        }
        // ── RULE 8 ─────────────────────────────────────────
        if ("MEDIUM".equals(level)) {
            return new AdvisoryResult(
                "◎ MEDIUM: Moderate threat flagged. Continue monitoring — no immediate action required.",
                CLASS_WARNING
            );
        }
        // ── RULE 9 ─────────────────────────────────────────
        if ("LOW".equals(level) && anomaly) {
            return new AdvisoryResult(
                "◎ INFO: Low-level threat with minor network anomaly. Record and monitor.",
                CLASS_SAFE
            );
        }
        // ── RULE 10 ────────────────────────────────────────
        return new AdvisoryResult(
            "✔ LOW: Routine event. No action required. Logged for historical records.",
            CLASS_SAFE
        );
    }

    // ── Inner result class ────────────────────────────────────
    public static class AdvisoryResult {
        private final String message;
        private final String cssClass;

        public AdvisoryResult(String message, String cssClass) {
            this.message  = message;
            this.cssClass = cssClass;
        }
        public String getMessage()  { return message; }
        public String getCssClass() { return cssClass; }
    }
}
