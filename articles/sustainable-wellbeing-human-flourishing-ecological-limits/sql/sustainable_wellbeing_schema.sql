-- Sustainable well-being indicator schema
-- Designed for analytical staging before modeling in R or Python.

CREATE TABLE IF NOT EXISTS sustainable_wellbeing_observations (
    observation_id INTEGER PRIMARY KEY,
    entity_id TEXT NOT NULL,
    entity_name TEXT,
    region TEXT,
    year INTEGER NOT NULL,
    life_satisfaction REAL,
    meaning REAL,
    health REAL,
    social_trust REAL,
    institutional_quality REAL,
    ecological_integrity REAL,
    carbon_pressure REAL,
    inequality_index REAL,
    income_security REAL,
    civic_participation REAL,
    data_source TEXT,
    source_url TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_swo_entity_year
ON sustainable_wellbeing_observations(entity_id, year);

CREATE INDEX IF NOT EXISTS idx_swo_region_year
ON sustainable_wellbeing_observations(region, year);

-- Example analytical view with a transparent composite score.
CREATE VIEW IF NOT EXISTS sustainable_wellbeing_composite AS
SELECT
    observation_id,
    entity_id,
    entity_name,
    region,
    year,
    (
        0.16 * life_satisfaction +
        0.14 * meaning +
        0.12 * health +
        0.12 * social_trust +
        0.14 * institutional_quality +
        0.14 * ecological_integrity +
        0.10 * civic_participation -
        0.04 * carbon_pressure -
        0.04 * inequality_index
    ) AS sustainable_wellbeing_index
FROM sustainable_wellbeing_observations;
