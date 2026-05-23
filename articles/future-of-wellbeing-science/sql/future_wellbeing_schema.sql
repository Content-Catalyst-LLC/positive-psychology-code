-- Professional relational schema for multidimensional well-being research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, employment, or individual assessment use.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    group_id TEXT,
    region TEXT,
    cohort TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS waves (
    wave_id INTEGER PRIMARY KEY,
    wave_label TEXT,
    collection_year INTEGER,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS wellbeing_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    life_satisfaction REAL,
    meaning REAL,
    social_trust REAL,
    institutional_quality REAL,
    environmental_quality REAL,
    health_index REAL,
    resilience_score REAL,
    stress_load REAL,
    material_security REAL,
    civic_voice REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE TABLE IF NOT EXISTS item_responses (
    response_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    item_code TEXT NOT NULL,
    item_family TEXT NOT NULL,
    response_value REAL,
    reverse_scored INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE INDEX IF NOT EXISTS idx_wellbeing_participant_wave
ON wellbeing_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_item_responses_family
ON item_responses(item_family);

CREATE VIEW IF NOT EXISTS future_wellbeing_composite AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    (
        0.13 * life_satisfaction +
        0.13 * meaning +
        0.12 * social_trust +
        0.12 * institutional_quality +
        0.12 * environmental_quality +
        0.13 * health_index +
        0.10 * resilience_score +
        0.10 * material_security +
        0.10 * civic_voice -
        0.05 * stress_load
    ) AS future_wellbeing_index
FROM wellbeing_observations;
