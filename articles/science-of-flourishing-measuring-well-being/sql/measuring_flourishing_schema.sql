-- Professional relational schema for multidimensional flourishing measurement.
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

CREATE TABLE IF NOT EXISTS flourishing_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    life_satisfaction REAL,
    positive_affect REAL,
    negative_affect REAL,
    purpose_life REAL,
    personal_growth REAL,
    autonomy REAL,
    positive_relations REAL,
    accomplishment REAL,
    health_index REAL,
    contextual_support REAL,
    stress_load REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE TABLE IF NOT EXISTS measurement_quality_audit (
    audit_id INTEGER PRIMARY KEY,
    measure TEXT NOT NULL,
    construct_family TEXT,
    reliability_evidence REAL,
    validity_evidence REAL,
    cultural_comparability REAL,
    temporal_sensitivity REAL,
    use_validity REAL,
    overall_measurement_quality REAL,
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

CREATE INDEX IF NOT EXISTS idx_flourishing_observations_participant_wave
ON flourishing_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_indicator_bank_family
ON indicator_bank(indicator_family);

CREATE VIEW IF NOT EXISTS multidimensional_flourishing_composite AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    (life_satisfaction + positive_affect - negative_affect) AS hedonic_index,
    ((purpose_life + personal_growth + autonomy) / 3.0) AS eudaimonic_index,
    (
        0.25 * (life_satisfaction + positive_affect - negative_affect) +
        0.25 * ((purpose_life + personal_growth + autonomy) / 3.0) +
        0.15 * positive_relations +
        0.15 * accomplishment +
        0.15 * health_index +
        0.15 * contextual_support -
        0.15 * stress_load
    ) AS integrated_flourishing_index
FROM flourishing_observations;

CREATE VIEW IF NOT EXISTS measurement_quality_summary AS
SELECT
    audit_id,
    measure,
    construct_family,
    (
        reliability_evidence +
        validity_evidence +
        cultural_comparability +
        temporal_sensitivity +
        use_validity
    ) / 5.0 AS computed_quality_mean,
    overall_measurement_quality
FROM measurement_quality_audit;
