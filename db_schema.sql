-- ============================================================
--  HSCMS — Oracle Database Schema
--  Run this script as HSCMS_USER in Oracle SQL*Plus / SQL Developer
--  Normalized to 3NF
-- ============================================================

-- ── 1. ZONES lookup (3NF: zone data in one place) ───────────
CREATE TABLE zones (
    zone_id     VARCHAR2(10)  PRIMARY KEY,   -- e.g. ZONE-A
    zone_name   VARCHAR2(50)  NOT NULL,
    description VARCHAR2(200)
);

INSERT INTO zones VALUES ('ZONE-A', 'Zone A — Central',    'City center surveillance zone');
INSERT INTO zones VALUES ('ZONE-B', 'Zone B — North',      'Northern residential zone');
INSERT INTO zones VALUES ('ZONE-C', 'Zone C — Industrial', 'Industrial and port zone');
INSERT INTO zones VALUES ('ZONE-D', 'Zone D — Airport',    'Airport and transit zone');

-- ── 2. CAMERAS ───────────────────────────────────────────────
CREATE TABLE cameras (
    camera_id   VARCHAR2(10)  PRIMARY KEY,   -- e.g. CAM-01
    zone_id     VARCHAR2(10)  NOT NULL,
    location    VARCHAR2(100),
    status      VARCHAR2(10)  DEFAULT 'ONLINE' CHECK (status IN ('ONLINE','OFFLINE','FAULT')),
    installed_at DATE         DEFAULT SYSDATE,
    CONSTRAINT fk_cam_zone FOREIGN KEY (zone_id) REFERENCES zones(zone_id)
);

INSERT INTO cameras VALUES ('CAM-01','ZONE-A','Gate 3 Entrance','ONLINE',SYSDATE);
INSERT INTO cameras VALUES ('CAM-02','ZONE-A','Central Park','ONLINE',SYSDATE);
INSERT INTO cameras VALUES ('CAM-03','ZONE-B','North Bridge','ONLINE',SYSDATE);
INSERT INTO cameras VALUES ('CAM-04','ZONE-B','Bus Terminal','ONLINE',SYSDATE);
INSERT INTO cameras VALUES ('CAM-05','ZONE-C','Warehouse District','ONLINE',SYSDATE);
INSERT INTO cameras VALUES ('CAM-06','ZONE-D','Airport Terminal 1','ONLINE',SYSDATE);

-- ── 3. THREAT EVENTS ─────────────────────────────────────────
CREATE TABLE threat_events (
    event_id       NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    camera_id      VARCHAR2(10)  NOT NULL,
    zone           VARCHAR2(10)  NOT NULL,
    sensor_type    VARCHAR2(20)  NOT NULL
                   CHECK (sensor_type IN ('MOTION','THERMAL','INTRUSION','NETWORK','ACOUSTIC')),
    threat_level   VARCHAR2(10)  NOT NULL
                   CHECK (threat_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    description    VARCHAR2(500),
    network_anomaly VARCHAR2(3)  DEFAULT 'NO' CHECK (network_anomaly IN ('YES','NO')),
    created_at     TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_evt_cam  FOREIGN KEY (camera_id) REFERENCES cameras(camera_id),
    CONSTRAINT fk_evt_zone FOREIGN KEY (zone)      REFERENCES zones(zone_id)
);

-- ── 4. SENSOR FEEDS ──────────────────────────────────────────
CREATE TABLE sensor_feeds (
    feed_id       NUMBER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sensor_id     VARCHAR2(10) NOT NULL,   -- e.g. SEN-01
    zone          VARCHAR2(10) NOT NULL,
    reading_value NUMBER(6,2)  NOT NULL,
    unit          VARCHAR2(10) NOT NULL,   -- °C, dB, %, lux
    logged_at     TIMESTAMP    DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_feed_zone FOREIGN KEY (zone) REFERENCES zones(zone_id)
);

-- ── 5. NETWORK LOGS ──────────────────────────────────────────
CREATE TABLE network_logs (
    log_id        NUMBER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_ip     VARCHAR2(20) NOT NULL,
    event_type    VARCHAR2(30) NOT NULL
                  CHECK (event_type IN ('PORT_SCAN','DDOS','INTRUSION','MALWARE','UNAUTHORIZED')),
    packet_count  NUMBER       NOT NULL,
    severity      VARCHAR2(10) NOT NULL CHECK (severity IN ('LOW','MEDIUM','HIGH')),
    logged_at     TIMESTAMP    DEFAULT SYSTIMESTAMP
);

-- ── 6. RESPONSE ACTIONS ──────────────────────────────────────
CREATE TABLE response_actions (
    action_id     NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id      NUMBER        NOT NULL,
    action_taken  VARCHAR2(200) NOT NULL,
    responder     VARCHAR2(50),
    status        VARCHAR2(20)  DEFAULT 'OPEN'
                  CHECK (status IN ('OPEN','IN_PROGRESS','RESOLVED','CLOSED')),
    created_at    TIMESTAMP     DEFAULT SYSTIMESTAMP,
    resolved_at   TIMESTAMP,
    CONSTRAINT fk_action_event FOREIGN KEY (event_id) REFERENCES threat_events(event_id)
);

-- ── USEFUL VIEWS (used by JSP reports) ──────────────────────

-- KPI: Threat count by zone
CREATE OR REPLACE VIEW vw_threats_by_zone AS
SELECT
    t.zone,
    COUNT(*)                                          AS total_threats,
    SUM(CASE WHEN t.threat_level='CRITICAL' THEN 1 ELSE 0 END) AS critical_count,
    SUM(CASE WHEN t.threat_level='HIGH'     THEN 1 ELSE 0 END) AS high_count,
    SUM(CASE WHEN t.threat_level='MEDIUM'   THEN 1 ELSE 0 END) AS medium_count,
    SUM(CASE WHEN t.threat_level='LOW'      THEN 1 ELSE 0 END) AS low_count
FROM threat_events t
GROUP BY t.zone;

-- KPI: Sensor alert statistics
CREATE OR REPLACE VIEW vw_sensor_stats AS
SELECT
    sensor_type,
    COUNT(*)    AS alert_count,
    MAX(created_at) AS last_seen
FROM threat_events
GROUP BY sensor_type;

-- Full incident report with JOIN
CREATE OR REPLACE VIEW vw_incident_report AS
SELECT
    t.event_id,
    t.created_at,
    t.camera_id,
    t.zone,
    t.sensor_type,
    t.threat_level,
    t.network_anomaly,
    t.description,
    r.action_taken,
    r.status AS response_status
FROM threat_events t
LEFT JOIN response_actions r ON t.event_id = r.event_id
ORDER BY t.created_at DESC;

COMMIT;

-- ── SAMPLE DATA ──────────────────────────────────────────────
INSERT INTO threat_events (camera_id, zone, sensor_type, threat_level, description, network_anomaly)
VALUES ('CAM-01','ZONE-A','MOTION','CRITICAL','Unauthorized entry at Gate 3','YES');
INSERT INTO threat_events (camera_id, zone, sensor_type, threat_level, description, network_anomaly)
VALUES ('CAM-03','ZONE-B','THERMAL','HIGH','Heat signature — unregistered vehicle','NO');
INSERT INTO threat_events (camera_id, zone, sensor_type, threat_level, description, network_anomaly)
VALUES ('CAM-05','ZONE-C','NETWORK','HIGH','Port scan from 10.22.4.8','YES');
INSERT INTO threat_events (camera_id, zone, sensor_type, threat_level, description, network_anomaly)
VALUES ('CAM-06','ZONE-D','INTRUSION','CRITICAL','Perimeter breach — Airport sector','YES');

COMMIT;
