-- Professional relational schema for positive psychology intervention research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- crisis-support, employment, school disciplinary, public-benefits, or individual assessment use.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS intervention_conditions (
    condition_id TEXT PRIMARY KEY,
    condition_label TEXT NOT NULL,
    ppi_type TEXT,
    delivery_mode TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS weeks (
    week_id INTEGER PRIMARY KEY,
    week_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS ppi_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    week_id INTEGER NOT NULL,
    condition_id TEXT NOT NULL,
    ppi_type TEXT,
    wellbeing_score REAL,
    depressive_symptoms REAL,
    gratitude_score REAL,
    strengths_use REAL,
    hope_score REAL,
    meaning_score REAL,
    social_support REAL,
    adherence_rate REAL,
    intervention_fit REAL,
    stress_load REAL,
    acceptability REAL,
    context_fit REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (week_id) REFERENCES weeks(week_id),
    FOREIGN KEY (condition_id) REFERENCES intervention_conditions(condition_id)
);

CREATE TABLE IF NOT EXISTS practice_quality_audit (
    audit_id INTEGER PRIMARY KEY,
    ppi_type TEXT NOT NULL,
    adherence_design REAL,
    mechanism_clarity REAL,
    acceptability REAL,
    context_fit REAL,
    privacy_safeguards REAL,
    trauma_sensitive_language REAL,
    implementation_support REAL,
    measurement_quality REAL,
    overall_practice_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ppi_observations_participant_week
ON ppi_observations(participant_id, week_id);

CREATE INDEX IF NOT EXISTS idx_ppi_observations_condition_week
ON ppi_observations(condition_id, week_id);

CREATE INDEX IF NOT EXISTS idx_ppi_observations_type
ON ppi_observations(ppi_type);

CREATE VIEW IF NOT EXISTS ppi_mechanism_composite AS
SELECT
    observation_id,
    participant_id,
    week_id,
    condition_id,
    ppi_type,
    (
        gratitude_score +
        strengths_use +
        hope_score +
        meaning_score +
        social_support
    ) / 5.0 AS mechanism_index,
    (
        adherence_rate +
        intervention_fit +
        acceptability +
        context_fit
    ) / 4.0 AS practice_quality_proxy,
    (
        wellbeing_score +
        gratitude_score +
        strengths_use +
        hope_score +
        meaning_score +
        social_support +
        intervention_fit -
        stress_load -
        depressive_symptoms
    ) AS net_wellbeing_index
FROM ppi_observations;
