CREATE TABLE IF NOT EXISTS wellbeing_metric_observations (
    observation_id INTEGER PRIMARY KEY,
    entity_id TEXT NOT NULL,
    entity_name TEXT,
    region TEXT,
    year INTEGER,
    life_satisfaction REAL,
    health_index REAL,
    trust_index REAL,
    income_security REAL,
    housing_quality REAL,
    education_access REAL,
    democratic_quality REAL,
    environmental_quality REAL,
    inequality_index REAL,
    policy_exposure REAL,
    data_source TEXT,
    source_url TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wmo_entity_year
ON wellbeing_metric_observations(entity_id, year);

CREATE INDEX IF NOT EXISTS idx_wmo_region_year
ON wellbeing_metric_observations(region, year);

CREATE VIEW IF NOT EXISTS public_wellbeing_composite AS
SELECT
    observation_id,
    entity_id,
    entity_name,
    region,
    year,
    (
        0.16 * life_satisfaction +
        0.14 * health_index +
        0.14 * trust_index +
        0.14 * income_security +
        0.10 * housing_quality +
        0.10 * education_access +
        0.10 * democratic_quality +
        0.08 * environmental_quality -
        0.08 * inequality_index
    ) AS public_wellbeing_index
FROM wellbeing_metric_observations;
