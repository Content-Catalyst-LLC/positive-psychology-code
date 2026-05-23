-- Professional relational schema for Broaden-and-Build Theory research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- crisis-support, employment, school disciplinary, public-benefits, or individual assessment use.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS study_conditions (
    condition_id TEXT PRIMARY KEY,
    condition_label TEXT NOT NULL,
    practice_variant TEXT,
    delivery_mode TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS waves (
    wave_id INTEGER PRIMARY KEY,
    wave_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS broaden_build_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    condition_id TEXT NOT NULL,
    positive_emotion REAL,
    negative_emotion REAL,
    cognitive_flexibility REAL,
    exploratory_behavior REAL,
    affiliative_behavior REAL,
    social_support REAL,
    resilience_score REAL,
    stress_arousal REAL,
    contextual_safety REAL,
    resource_stock REAL,
    practice_fit REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (condition_id) REFERENCES study_conditions(condition_id)
);

CREATE TABLE IF NOT EXISTS practice_quality_audit (
    audit_id INTEGER PRIMARY KEY,
    practice_variant TEXT NOT NULL,
    emotion_fit REAL,
    mechanism_clarity REAL,
    acceptability REAL,
    contextual_safety REAL,
    privacy_safeguards REAL,
    trauma_sensitive_language REAL,
    implementation_support REAL,
    measurement_quality REAL,
    overall_practice_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS emotion_episode_notes (
    episode_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    positive_emotion_label TEXT,
    context_note TEXT,
    coded_broadening REAL,
    coded_exploration REAL,
    coded_affiliation REAL,
    coded_resource_building REAL,
    coded_recovery REAL,
    coded_contextual_safety REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE INDEX IF NOT EXISTS idx_bb_observations_participant_wave
ON broaden_build_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_bb_observations_condition_wave
ON broaden_build_observations(condition_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_bb_episode_notes_participant_wave
ON emotion_episode_notes(participant_id, wave_id);

CREATE VIEW IF NOT EXISTS broaden_build_composites AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    condition_id,
    (
        positive_emotion +
        cognitive_flexibility +
        exploratory_behavior +
        affiliative_behavior +
        contextual_safety -
        negative_emotion
    ) / 6.0 AS broadening_index,
    (
        social_support +
        resilience_score +
        contextual_safety +
        resource_stock +
        practice_fit
    ) / 5.0 AS resource_index,
    (
        positive_emotion +
        social_support +
        contextual_safety +
        resilience_score -
        stress_arousal -
        negative_emotion
    ) / 6.0 AS recovery_capacity_index,
    (
        positive_emotion +
        cognitive_flexibility +
        exploratory_behavior +
        affiliative_behavior +
        social_support +
        resilience_score +
        contextual_safety +
        resource_stock +
        practice_fit -
        negative_emotion -
        stress_arousal
    ) AS net_adaptation_index
FROM broaden_build_observations;

CREATE VIEW IF NOT EXISTS practice_quality_summary AS
SELECT
    audit_id,
    practice_variant,
    (
        emotion_fit +
        mechanism_clarity +
        acceptability +
        contextual_safety +
        privacy_safeguards +
        trauma_sensitive_language +
        implementation_support +
        measurement_quality
    ) / 8.0 AS computed_quality_mean,
    overall_practice_quality
FROM practice_quality_audit;
