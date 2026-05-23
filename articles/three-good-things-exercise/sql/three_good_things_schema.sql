-- Professional relational schema for Three Good Things intervention research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- crisis-support, employment, public-benefits, or individual assessment use.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    condition TEXT NOT NULL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS days (
    day_id INTEGER PRIMARY KEY,
    day_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS three_good_things_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    day_id INTEGER NOT NULL,
    condition TEXT NOT NULL,
    life_satisfaction REAL,
    depressive_symptoms REAL,
    gratitude_score REAL,
    positive_event_salience REAL,
    perceived_support REAL,
    reflection_depth REAL,
    stress_load REAL,
    acceptability REAL,
    context_fit REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (day_id) REFERENCES days(day_id)
);

CREATE TABLE IF NOT EXISTS good_thing_entries (
    entry_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    day_id INTEGER NOT NULL,
    entry_number INTEGER NOT NULL,
    good_thing_text TEXT,
    why_it_happened_text TEXT,
    coded_effort REAL,
    coded_support REAL,
    coded_opportunity REAL,
    coded_kindness REAL,
    coded_reflection_depth REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (day_id) REFERENCES days(day_id)
);

CREATE TABLE IF NOT EXISTS practice_quality_audit (
    audit_id INTEGER PRIMARY KEY,
    practice_variant TEXT NOT NULL,
    completion_rate REAL,
    reflection_depth REAL,
    acceptability REAL,
    context_fit REAL,
    privacy_safeguards REAL,
    trauma_sensitive_language REAL,
    implementation_support REAL,
    overall_practice_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tgt_observations_participant_day
ON three_good_things_observations(participant_id, day_id);

CREATE INDEX IF NOT EXISTS idx_tgt_entries_participant_day
ON good_thing_entries(participant_id, day_id);

CREATE VIEW IF NOT EXISTS appreciative_awareness_composite AS
SELECT
    observation_id,
    participant_id,
    day_id,
    condition,
    (
        gratitude_score +
        positive_event_salience +
        perceived_support +
        reflection_depth +
        acceptability +
        context_fit -
        stress_load
    ) / 7.0 AS appreciative_awareness_index,
    (
        life_satisfaction +
        gratitude_score +
        positive_event_salience +
        perceived_support +
        reflection_depth -
        depressive_symptoms -
        stress_load
    ) AS net_wellbeing_index
FROM three_good_things_observations;

CREATE VIEW IF NOT EXISTS practice_quality_summary AS
SELECT
    audit_id,
    practice_variant,
    (
        completion_rate +
        reflection_depth +
        acceptability +
        context_fit +
        privacy_safeguards +
        trauma_sensitive_language +
        implementation_support
    ) / 7.0 AS computed_quality_mean,
    overall_practice_quality
FROM practice_quality_audit;
