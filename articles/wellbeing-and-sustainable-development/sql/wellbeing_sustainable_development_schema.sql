-- Professional relational schema for well-being and sustainable development research scaffolds.
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

CREATE TABLE IF NOT EXISTS sustainable_wellbeing_observations (
    observation_id INTEGER PRIMARY KEY,
    country_id TEXT NOT NULL,
    year_id INTEGER NOT NULL,
    life_expectancy REAL,
    education_index REAL,
    income_index REAL,
    life_satisfaction REAL,
    institutional_quality REAL,
    ecological_stability REAL,
    social_trust REAL,
    inequality_index REAL,
    resilience_capacity REAL,
    basic_services REAL,
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

CREATE INDEX IF NOT EXISTS idx_swo_country_year
ON sustainable_wellbeing_observations(country_id, year_id);

CREATE INDEX IF NOT EXISTS idx_indicator_bank_family
ON indicator_bank(indicator_family);

CREATE VIEW IF NOT EXISTS sustainable_flourishing_composite AS
SELECT
    observation_id,
    country_id,
    year_id,
    (
        0.11 * life_expectancy +
        0.11 * education_index +
        0.10 * income_index +
        0.11 * life_satisfaction +
        0.12 * institutional_quality +
        0.12 * ecological_stability +
        0.11 * social_trust +
        0.10 * resilience_capacity +
        0.10 * basic_services -
        0.08 * inequality_index
    ) AS sustainable_flourishing_index
FROM sustainable_wellbeing_observations;
