-- Professional relational schema for cross-cultural well-being research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, employment, ranking, or individual assessment use.

CREATE TABLE IF NOT EXISTS cultural_groups (
    group_id TEXT PRIMARY KEY,
    group_label TEXT NOT NULL,
    region TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL,
    cohort TEXT,
    language_context TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES cultural_groups(group_id)
);

CREATE TABLE IF NOT EXISTS waves (
    wave_id INTEGER PRIMARY KEY,
    wave_label TEXT,
    collection_year INTEGER,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS cultural_wellbeing_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    life_satisfaction REAL,
    social_support REAL,
    income_security REAL,
    relational_harmony REAL,
    institutional_trust REAL,
    cultural_orientation REAL,
    autonomy_value REAL,
    harmony_value REAL,
    civic_voice REAL,
    cultural_continuity REAL,
    place_attachment REAL,
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
    translated INTEGER DEFAULT 0,
    adaptation_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE INDEX IF NOT EXISTS idx_cwo_participant_wave
ON cultural_wellbeing_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_item_responses_family
ON item_responses(item_family);

CREATE VIEW IF NOT EXISTS cultural_wellbeing_composite AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    (
        0.12 * life_satisfaction +
        0.11 * social_support +
        0.12 * relational_harmony +
        0.10 * institutional_trust +
        0.10 * income_security +
        0.09 * civic_voice +
        0.12 * cultural_continuity +
        0.12 * place_attachment +
        0.06 * autonomy_value +
        0.06 * harmony_value
    ) AS cultural_wellbeing_index
FROM cultural_wellbeing_observations;
