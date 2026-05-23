CREATE TABLE IF NOT EXISTS subjective_wellbeing_observations (
    observation_id INTEGER PRIMARY KEY,
    respondent_id TEXT NOT NULL,
    group_id TEXT,
    region TEXT,
    wave INTEGER,
    life_satisfaction REAL,
    positive_affect REAL,
    negative_affect REAL,
    social_support REAL,
    income_security REAL,
    meaning_alignment REAL,
    stress_load REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_swb_respondent_wave
ON subjective_wellbeing_observations(respondent_id, wave);

CREATE INDEX IF NOT EXISTS idx_swb_region_wave
ON subjective_wellbeing_observations(region, wave);

CREATE VIEW IF NOT EXISTS subjective_wellbeing_composite AS
SELECT
    observation_id,
    respondent_id,
    group_id,
    region,
    wave,
    (
        0.40 * life_satisfaction +
        0.35 * positive_affect -
        0.35 * negative_affect
    ) AS swb_index,
    (
        0.30 * life_satisfaction +
        0.25 * positive_affect -
        0.25 * negative_affect +
        0.10 * social_support +
        0.08 * income_security +
        0.10 * meaning_alignment -
        0.08 * stress_load
    ) AS contextual_swb_index
FROM subjective_wellbeing_observations;
