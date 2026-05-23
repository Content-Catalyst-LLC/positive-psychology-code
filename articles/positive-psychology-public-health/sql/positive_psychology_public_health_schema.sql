-- Professional relational schema for positive psychology and public health research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, employment, public-benefits, or individual assessment use.

CREATE TABLE IF NOT EXISTS regions (
    region_id TEXT PRIMARY KEY,
    region_name TEXT NOT NULL,
    community_type TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS years (
    year_id INTEGER PRIMARY KEY,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS public_health_wellbeing_observations (
    observation_id INTEGER PRIMARY KEY,
    region_id TEXT NOT NULL,
    year_id INTEGER NOT NULL,
    life_satisfaction REAL,
    health_index REAL,
    social_trust REAL,
    income_security REAL,
    institutional_quality REAL,
    housing_stability REAL,
    education_access REAL,
    care_access REAL,
    environmental_quality REAL,
    stress_load REAL,
    community_resilience REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(region_id),
    FOREIGN KEY (year_id) REFERENCES years(year_id)
);

CREATE TABLE IF NOT EXISTS indicator_bank (
    indicator_id INTEGER PRIMARY KEY,
    region_id TEXT NOT NULL,
    year_id INTEGER NOT NULL,
    indicator_code TEXT NOT NULL,
    indicator_family TEXT NOT NULL,
    response_value REAL,
    scale_direction TEXT DEFAULT 'higher_is_better',
    source_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(region_id),
    FOREIGN KEY (year_id) REFERENCES years(year_id)
);

CREATE INDEX IF NOT EXISTS idx_phw_region_year
ON public_health_wellbeing_observations(region_id, year_id);

CREATE INDEX IF NOT EXISTS idx_indicator_bank_family
ON indicator_bank(indicator_family);

CREATE VIEW IF NOT EXISTS public_health_flourishing_composite AS
SELECT
    observation_id,
    region_id,
    year_id,
    (
        0.11 * life_satisfaction +
        0.12 * health_index +
        0.10 * social_trust +
        0.10 * income_security +
        0.11 * institutional_quality +
        0.10 * housing_stability +
        0.09 * education_access +
        0.10 * care_access +
        0.09 * environmental_quality +
        0.10 * community_resilience -
        0.10 * stress_load
    ) AS public_wellbeing_index
FROM public_health_wellbeing_observations;
