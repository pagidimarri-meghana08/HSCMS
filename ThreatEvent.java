package com.hscms.model;

import java.sql.Timestamp;

/**
 * HSCMS — ThreatEvent.java
 * Maps to: THREAT_EVENTS table in Oracle DB
 */
public class ThreatEvent {

    private int       eventId;
    private String    cameraId;
    private String    zone;
    private String    sensorType;
    private String    threatLevel;
    private String    description;
    private String    networkAnomaly; // "YES" or "NO"
    private Timestamp createdAt;

    // ── Constructors ─────────────────────────────────────────
    public ThreatEvent() {}

    public ThreatEvent(String cameraId, String zone, String sensorType,
                       String threatLevel, String description, String networkAnomaly) {
        this.cameraId      = cameraId;
        this.zone          = zone;
        this.sensorType    = sensorType;
        this.threatLevel   = threatLevel;
        this.description   = description;
        this.networkAnomaly = networkAnomaly;
    }

    // ── Getters & Setters ────────────────────────────────────
    public int       getEventId()       { return eventId; }
    public void      setEventId(int id) { this.eventId = id; }

    public String    getCameraId()           { return cameraId; }
    public void      setCameraId(String v)   { this.cameraId = v; }

    public String    getZone()               { return zone; }
    public void      setZone(String v)       { this.zone = v; }

    public String    getSensorType()         { return sensorType; }
    public void      setSensorType(String v) { this.sensorType = v; }

    public String    getThreatLevel()        { return threatLevel; }
    public void      setThreatLevel(String v){ this.threatLevel = v; }

    public String    getDescription()        { return description; }
    public void      setDescription(String v){ this.description = v; }

    public String    getNetworkAnomaly()         { return networkAnomaly; }
    public void      setNetworkAnomaly(String v) { this.networkAnomaly = v; }

    public Timestamp getCreatedAt()          { return createdAt; }
    public void      setCreatedAt(Timestamp t){ this.createdAt = t; }

    @Override
    public String toString() {
        return "[ThreatEvent id=" + eventId + " cam=" + cameraId +
               " zone=" + zone + " level=" + threatLevel + "]";
    }
}
