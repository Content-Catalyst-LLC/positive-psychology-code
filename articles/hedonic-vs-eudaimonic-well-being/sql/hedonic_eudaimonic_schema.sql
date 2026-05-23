-- Professional relational schema for hedonic and eudaimonic well-being research scaffolds.
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

CREATE TABLE IF NOT EXISTS hedonic_eudaimonic_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    life_satisfaction REAL,
    positive_affect REAL,
    negative_affect REAL,
    autonomy REAL,
    personal_growth REAL,
    purpose_life REAL,
    positive_relations REAL,
    environmental_mastery REAL,
    self_acceptance REAL,
    flourishing_outcome REAL,
    stress_load REAL,
    contextual_support REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
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

CREATE INDEX IF NOT EXISTS idx_heo_participant_wave
ON hedonic_eudaimonic_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_indicator_bank_family
ON indicator_bank(indicator_family);

CREATE VIEW IF NOT EXISTS hedonic_eudaimonic_composite AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    (
        life_satisfaction + positive_affect - negative_affect
    ) AS hedonic_index,
    (
        autonomy + personal_growth + purpose_life + positive_relations + environmental_mastery + self_acceptance
    ) / 6.0 AS eudaimonic_index,
    (
        0.40 * (life_satisfaction + positive_affect - negative_affect) +
        0.45 * ((autonomy + personal_growth + purpose_life + positive_relations + environmental_mastery + self_acceptance) / 6.0) +
        0.20 * contextual_support -
        0.20 * stress_load
    ) AS integrated_flourishing_index
FROM hedonic_eudaimonic_observations;
