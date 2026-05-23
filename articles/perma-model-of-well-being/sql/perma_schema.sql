-- Professional relational schema for PERMA and multidimensional flourishing research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- employment, school disciplinary, benefits eligibility, ranking, or individual assessment use.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS settings (
    setting_id TEXT PRIMARY KEY,
    setting_label TEXT NOT NULL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS waves (
    wave_id INTEGER PRIMARY KEY,
    wave_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS perma_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    setting_id TEXT NOT NULL,
    positive_emotion REAL,
    engagement REAL,
    relationships REAL,
    meaning REAL,
    accomplishment REAL,
    flourishing_score REAL,
    life_satisfaction REAL,
    institutional_support REAL,
    institutional_barriers REAL,
    autonomy_support REAL,
    fairness_score REAL,
    psychological_safety REAL,
    access_score REAL,
    workload_strain REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (setting_id) REFERENCES settings(setting_id)
);

CREATE TABLE IF NOT EXISTS perma_context_audit (
    audit_id INTEGER PRIMARY KEY,
    setting TEXT NOT NULL,
    positive_emotion_support REAL,
    engagement_support REAL,
    relationship_support REAL,
    meaning_support REAL,
    accomplishment_support REAL,
    autonomy_support REAL,
    fairness_support REAL,
    psychological_safety REAL,
    access_support REAL,
    anti_coercion_review REAL,
    privacy_safeguards REAL,
    cultural_adaptation REAL,
    measurement_quality REAL,
    overall_context_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS perma_item_bank (
    item_response_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    setting_id TEXT NOT NULL,
    item_code TEXT NOT NULL,
    construct_family TEXT NOT NULL,
    response_value REAL,
    scale_direction TEXT DEFAULT 'higher_is_better',
    source_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (setting_id) REFERENCES settings(setting_id)
);

CREATE INDEX IF NOT EXISTS idx_perma_observations_participant_wave
ON perma_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_perma_observations_setting_wave
ON perma_observations(setting_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_perma_item_bank_construct
ON perma_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS perma_indices AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    setting_id,
    (
        positive_emotion +
        engagement +
        relationships +
        meaning +
        accomplishment
    ) / 5.0 AS perma_index,
    (
        institutional_support +
        autonomy_support +
        fairness_score +
        psychological_safety +
        access_score -
        institutional_barriers -
        workload_strain
    ) AS institutional_quality,
    (
        flourishing_score +
        life_satisfaction +
        ((positive_emotion + engagement + relationships + meaning + accomplishment) / 5.0) +
        institutional_support +
        autonomy_support +
        fairness_score +
        psychological_safety +
        access_score -
        institutional_barriers -
        workload_strain
    ) AS context_adjusted_flourishing
FROM perma_observations;

CREATE VIEW IF NOT EXISTS perma_context_quality_summary AS
SELECT
    audit_id,
    setting,
    (
        positive_emotion_support +
        engagement_support +
        relationship_support +
        meaning_support +
        accomplishment_support +
        autonomy_support +
        fairness_support +
        psychological_safety +
        access_support +
        anti_coercion_review +
        privacy_safeguards +
        cultural_adaptation +
        measurement_quality
    ) / 13.0 AS computed_context_quality,
    overall_context_quality
FROM perma_context_audit;
