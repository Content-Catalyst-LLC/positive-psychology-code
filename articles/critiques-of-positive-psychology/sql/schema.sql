-- Article-level synthetic positive psychology schema.

CREATE TABLE IF NOT EXISTS flourishing_observations (
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
    flourishing_index REAL
);

CREATE INDEX IF NOT EXISTS idx_flourishing_participant
ON flourishing_observations(participant_id);

CREATE INDEX IF NOT EXISTS idx_flourishing_wave
ON flourishing_observations(wave);

CREATE INDEX IF NOT EXISTS idx_flourishing_index
ON flourishing_observations(flourishing_index);
