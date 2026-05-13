package com.hscms.servlet;

import com.hscms.db.DBConnection;
import com.hscms.engine.AdvisoryEngine;
import com.hscms.engine.AdvisoryEngine.AdvisoryResult;
import com.hscms.model.ThreatEvent;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

/**
 * HSCMS — ThreatServlet.java
 * Handles POST from: threatForm.jsp
 * Routes by formType: threat | sensor | network
 */
@WebServlet("/ThreatServlet")
public class ThreatServlet extends HttpServlet {

    // ── SQL Statements ────────────────────────────────────────
    private static final String INSERT_THREAT =
        "INSERT INTO threat_events (camera_id, zone, sensor_type, threat_level, description, network_anomaly, created_at) " +
        "VALUES (?, ?, ?, ?, ?, ?, SYSDATE)";

    private static final String INSERT_SENSOR =
        "INSERT INTO sensor_feeds (sensor_id, zone, reading_value, unit, logged_at) " +
        "VALUES (?, ?, ?, ?, SYSDATE)";

    private static final String INSERT_NETWORK =
        "INSERT INTO network_logs (source_ip, event_type, packet_count, severity, logged_at) " +
        "VALUES (?, ?, ?, ?, SYSDATE)";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String formType = req.getParameter("formType");

        if (formType == null) {
            forwardWithMessage(req, resp, "Unknown form type.", "alert-warning");
            return;
        }

        switch (formType) {
            case "threat":   handleThreat(req, resp);  break;
            case "sensor":   handleSensor(req, resp);  break;
            case "network":  handleNetwork(req, resp); break;
            default:
                forwardWithMessage(req, resp, "Unknown form type: " + formType, "alert-warning");
        }
    }

    // ── THREAT EVENT HANDLER ──────────────────────────────────
    private void handleThreat(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String cameraId      = sanitize(req.getParameter("cameraId"));
        String zone          = sanitize(req.getParameter("zone"));
        String sensorType    = sanitize(req.getParameter("sensorType"));
        String threatLevel   = sanitize(req.getParameter("threatLevel"));
        String description   = sanitize(req.getParameter("description"));
        String networkAnomaly = sanitize(req.getParameter("networkAnomaly"));

        // Build model
        ThreatEvent event = new ThreatEvent(
            cameraId, zone, sensorType, threatLevel, description, networkAnomaly
        );

        // Run advisory engine
        AdvisoryResult advisory = AdvisoryEngine.evaluate(event);

        // Persist to Oracle DB
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(INSERT_THREAT);
            ps.setString(1, cameraId);
            ps.setString(2, zone);
            ps.setString(3, sensorType);
            ps.setString(4, threatLevel);
            ps.setString(5, description);
            ps.setString(6, networkAnomaly);
            ps.executeUpdate();
            ps.close();

            // Forward to dashboard with advisory message
            req.setAttribute("alertMsg",   advisory.getMessage());
            req.setAttribute("alertClass", advisory.getCssClass());
            req.getRequestDispatcher("index.jsp").forward(req, resp);

        } catch (SQLException e) {
            System.err.println("[HSCMS] DB Error (threat): " + e.getMessage());
            // Still show advisory even if DB fails
            req.setAttribute("result",      "⚠ DB Error: " + e.getMessage() + " | Advisory: " + advisory.getMessage());
            req.setAttribute("resultClass", "alert-warning");
            req.getRequestDispatcher("threatForm.jsp").forward(req, resp);
        } finally {
            DBConnection.close(conn);
        }
    }

    // ── SENSOR FEED HANDLER ───────────────────────────────────
    private void handleSensor(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String sensorId    = sanitize(req.getParameter("sensorId"));
        String zone        = sanitize(req.getParameter("zone"));
        String readingStr  = req.getParameter("readingValue");
        String unit        = sanitize(req.getParameter("unit"));

        double readingValue;
        try {
            readingValue = Double.parseDouble(readingStr);
            if (readingValue < 0 || readingValue > 100) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.setAttribute("result",      "✖ Invalid reading value. Must be 0–100.");
            req.setAttribute("resultClass", "alert-warning");
            req.getRequestDispatcher("threatForm.jsp").forward(req, resp);
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(INSERT_SENSOR);
            ps.setString(1, sensorId);
            ps.setString(2, zone);
            ps.setDouble(3, readingValue);
            ps.setString(4, unit);
            ps.executeUpdate();
            ps.close();

            req.setAttribute("result",      "✔ Sensor feed logged: " + sensorId + " [" + readingValue + unit + "]");
            req.setAttribute("resultClass", "alert-safe");

        } catch (SQLException e) {
            System.err.println("[HSCMS] DB Error (sensor): " + e.getMessage());
            req.setAttribute("result",      "⚠ DB Error: " + e.getMessage());
            req.setAttribute("resultClass", "alert-warning");
        } finally {
            DBConnection.close(conn);
        }
        req.getRequestDispatcher("threatForm.jsp").forward(req, resp);
    }

    // ── NETWORK EVENT HANDLER ─────────────────────────────────
    private void handleNetwork(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String sourceIp    = sanitize(req.getParameter("sourceIp"));
        String eventType   = sanitize(req.getParameter("eventType"));
        String packetStr   = req.getParameter("packetCount");
        String severity    = sanitize(req.getParameter("severity"));

        int packetCount;
        try {
            packetCount = Integer.parseInt(packetStr);
            if (packetCount < 1) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.setAttribute("result",      "✖ Invalid packet count.");
            req.setAttribute("resultClass", "alert-warning");
            req.getRequestDispatcher("threatForm.jsp").forward(req, resp);
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(INSERT_NETWORK);
            ps.setString(1, sourceIp);
            ps.setString(2, eventType);
            ps.setInt(3, packetCount);
            ps.setString(4, severity);
            ps.executeUpdate();
            ps.close();

            req.setAttribute("result",      "✔ Network event logged: " + eventType + " from " + sourceIp);
            req.setAttribute("resultClass", "alert-safe");

        } catch (SQLException e) {
            System.err.println("[HSCMS] DB Error (network): " + e.getMessage());
            req.setAttribute("result",      "⚠ DB Error: " + e.getMessage());
            req.setAttribute("resultClass", "alert-warning");
        } finally {
            DBConnection.close(conn);
        }
        req.getRequestDispatcher("threatForm.jsp").forward(req, resp);
    }

    // ── HELPERS ───────────────────────────────────────────────
    private String sanitize(String input) {
        if (input == null) return "";
        return input.trim().replaceAll("[<>\"'%;()&+]", "");
    }

    private void forwardWithMessage(HttpServletRequest req, HttpServletResponse resp,
                                    String msg, String cls)
            throws ServletException, IOException {
        req.setAttribute("result", msg);
        req.setAttribute("resultClass", cls);
        req.getRequestDispatcher("threatForm.jsp").forward(req, resp);
    }
}
