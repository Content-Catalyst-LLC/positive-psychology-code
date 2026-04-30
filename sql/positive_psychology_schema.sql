-- Root schema for positive psychology, flourishing, intervention, and well-being data.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    age_years REAL,
    birth_cohort INTEGER,
    language_background TEXT,
    institutional_context TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS wellbeing_measures (
    measure_id TEXT PRIMARY KEY,
    measure_name TEXT NOT NULL,
    construct_domain TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS wellbeing_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave INTEGER NOT NULL,
    positive_emotion REAL,
    engagement REAL,
    relationships REAL,
    meaning REAL,
    accomplishment REAL,
    health REAL,
    hope REAL,
    resilience REAL,
    social_support REAL,
    stress_load REAL,
    intervention_exposure REAL,
    flourishing_index REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
