package com.hscms.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * HSCMS — DBConnection.java
 * Oracle JDBC connection utility using ojdbc6.jar
 * 
 * Place ojdbc6.jar in: WebContent/WEB-INF/lib/
 */
public class DBConnection {

    // ── Oracle DB Configuration ───────────────────────────────
    private static final String DRIVER = "oracle.jdbc.driver.OracleDriver";
    private static final String URL    = "jdbc:oracle:thin:@localhost:1521:XE"; // Change XE to your SID
    private static final String USER   = "system";   // Your Oracle username
    private static final String PASS   = "manager";   // Your Oracle password

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("[HSCMS] Oracle JDBC Driver not found: " + e.getMessage());
        }
    }

    /**
     * Returns a new Oracle DB connection.
     * Always close connection in finally block after use.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    /**
     * Safely close a connection (null-safe).
     */
    public static void close(Connection conn) {
        if (conn != null) {
            try { conn.close(); }
            catch (SQLException e) {
                System.err.println("[HSCMS] Error closing connection: " + e.getMessage());
            }
        }
    }
}
