-- Professional relational schema for gratitude and well-being research scaffolds.
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

CREATE TABLE IF NOT EXISTS gratitude_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    condition_id TEXT NOT NULL,
    gratitude_score REAL,
    life_satisfaction REAL,
    perceived_support REAL,
    resilience_score REAL,
    stress_load REAL,
    depressive_symptoms REAL,
    reflection_depth REAL,
    gratitude_expression REAL,
    intervention_fit REAL,
    relationship_quality REAL,
    social_trust REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (condition_id) REFERENCES study_conditions(condition_id)
);

CREATE TABLE IF NOT EXISTS gratitude_entries (
    entry_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    practice_variant TEXT,
    entry_text TEXT,
    coded_benefit_noticing REAL,
    coded_support_recognition REAL,
    coded_reflection_depth REAL,
    coded_expression REAL,
    coded_relational_safety REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE TABLE IF NOT EXISTS practice_quality_audit (
    audit_id INTEGER PRIMARY KEY,
    practice_variant TEXT NOT NULL,
    reflection_design REAL,
    mechanism_clarity REAL,
    acceptability REAL,
    context_fit REAL,
    privacy_safeguards REAL,
    trauma_sensitive_language REAL,
    relational_safety REAL,
    measurement_quality REAL,
    overall_practice_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gratitude_observations_participant_wave
ON gratitude_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_gratitude_observations_condition_wave
ON gratitude_observations(condition_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_gratitude_entries_participant_wave
ON gratitude_entries(participant_id, wave_id);

CREATE VIEW IF NOT EXISTS gratitude_mechanism_composite AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    condition_id,
    (
        gratitude_score +
        perceived_support +
        reflection_depth +
        gratitude_expression +
        relationship_quality +
        social_trust +
        intervention_fit -
        stress_load
    ) / 8.0 AS appreciative_orientation_index,
    (
        perceived_support +
        relationship_quality +
        social_trust +
        gratitude_expression
    ) / 4.0 AS relational_support_index,
    (
        life_satisfaction +
        gratitude_score +
        perceived_support +
        resilience_score +
        reflection_depth +
        gratitude_expression +
        relationship_quality +
        social_trust -
        depressive_symptoms -
        stress_load
    ) AS net_wellbeing_index
FROM gratitude_observations;

CREATE VIEW IF NOT EXISTS practice_quality_summary AS
SELECT
    audit_id,
    practice_variant,
    (
        reflection_design +
        mechanism_clarity +
        acceptability +
        context_fit +
        privacy_safeguards +
        trauma_sensitive_language +
        relational_safety +
        measurement_quality
    ) / 8.0 AS computed_quality_mean,
    overall_practice_quality
FROM practice_quality_audit;
