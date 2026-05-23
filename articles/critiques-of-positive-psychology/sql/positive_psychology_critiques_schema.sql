-- Professional relational schema for critiques of positive psychology research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, employment, public-benefits, or individual assessment use.

CREATE TABLE IF NOT EXISTS participant_groups (
    group_id TEXT PRIMARY KEY,
    group_label TEXT NOT NULL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES participant_groups(group_id)
);

CREATE TABLE IF NOT EXISTS waves (
    wave_id INTEGER PRIMARY KEY,
    wave_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS critique_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    meaning REAL,
    relationships REAL,
    optimism REAL,
    resilience REAL,
    income_security REAL,
    institutional_trust REAL,
    inequality_exposure REAL,
    stress_load REAL,
    cultural_fit REAL,
    environmental_quality REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE TABLE IF NOT EXISTS construct_distortion_tracking (
    tracking_id INTEGER PRIMARY KEY,
    source_context TEXT NOT NULL,
    construct TEXT NOT NULL,
    applied_uptake REAL,
    retained_nuance REAL,
    institutional_accountability REAL,
    commercial_pressure REAL,
    privacy_safeguards REAL,
    distortion_risk REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS indicator_bank (
    indicator_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    indicator_code TEXT NOT NULL,
    indicator_family TEXT NOT NULL,
    response_value REAL,
    scale_direction TEXT DEFAULT 'higher_is_better',
    source_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE INDEX IF NOT EXISTS idx_critique_observations_participant_wave
ON critique_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_indicator_bank_family
ON indicator_bank(indicator_family);

CREATE VIEW IF NOT EXISTS critique_sensitive_flourishing_composite AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    (
        0.13 * meaning +
        0.13 * relationships +
        0.10 * optimism +
        0.11 * resilience +
        0.11 * income_security +
        0.11 * institutional_trust +
        0.09 * cultural_fit +
        0.09 * environmental_quality -
        0.08 * inequality_exposure -
        0.08 * stress_load
    ) AS critique_sensitive_flourishing_index
FROM critique_observations;
