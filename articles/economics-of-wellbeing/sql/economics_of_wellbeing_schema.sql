-- Professional relational schema for economics of well-being research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, employment, or individual assessment use.

CREATE TABLE IF NOT EXISTS countries (
    country_id TEXT PRIMARY KEY,
    country_name TEXT NOT NULL,
    region TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS years (
    year_id INTEGER PRIMARY KEY,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS wellbeing_economy_observations (
    observation_id INTEGER PRIMARY KEY,
    country_id TEXT NOT NULL,
    year_id INTEGER NOT NULL,
    income_security REAL,
    life_satisfaction REAL,
    health_index REAL,
    social_trust REAL,
    institutional_quality REAL,
    environmental_quality REAL,
    inequality_index REAL,
    work_quality REAL,
    care_security REAL,
    time_pressure REAL,
    public_services REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES countries(country_id),
    FOREIGN KEY (year_id) REFERENCES years(year_id)
);

CREATE TABLE IF NOT EXISTS indicator_bank (
    indicator_id INTEGER PRIMARY KEY,
    country_id TEXT NOT NULL,
    year_id INTEGER NOT NULL,
    indicator_code TEXT NOT NULL,
    indicator_family TEXT NOT NULL,
    response_value REAL,
    scale_direction TEXT DEFAULT 'higher_is_better',
    source_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES countries(country_id),
    FOREIGN KEY (year_id) REFERENCES years(year_id)
);

CREATE INDEX IF NOT EXISTS idx_weo_country_year
ON wellbeing_economy_observations(country_id, year_id);

CREATE INDEX IF NOT EXISTS idx_indicator_bank_family
ON indicator_bank(indicator_family);

CREATE VIEW IF NOT EXISTS wellbeing_economy_composite AS
SELECT
    observation_id,
    country_id,
    year_id,
    (
        0.12 * income_security +
        0.12 * life_satisfaction +
        0.12 * health_index +
        0.11 * social_trust +
        0.11 * institutional_quality +
        0.10 * environmental_quality +
        0.10 * work_quality +
        0.10 * care_security +
        0.10 * public_services -
        0.06 * inequality_index -
        0.06 * time_pressure
    ) AS wellbeing_economy_index
FROM wellbeing_economy_observations;
