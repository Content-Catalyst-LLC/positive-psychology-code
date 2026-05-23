-- Professional relational schema for positive psychology and sustainability research scaffolds.
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

CREATE TABLE IF NOT EXISTS sustainable_flourishing_observations (
    observation_id INTEGER PRIMARY KEY,
    region_id TEXT NOT NULL,
    year_id INTEGER NOT NULL,
    life_satisfaction REAL,
    meaning REAL,
    purpose REAL,
    autonomy REAL,
    social_trust REAL,
    belonging REAL,
    institutional_quality REAL,
    public_service_access REAL,
    ecological_stability REAL,
    environmental_exposure REAL,
    health_index REAL,
    mental_health_index REAL,
    adaptive_capacity REAL,
    insecurity_load REAL,
    inequality_index REAL,
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

CREATE INDEX IF NOT EXISTS idx_sfo_region_year
ON sustainable_flourishing_observations(region_id, year_id);

CREATE INDEX IF NOT EXISTS idx_indicator_bank_family
ON indicator_bank(indicator_family);

CREATE VIEW IF NOT EXISTS sustainable_flourishing_composite AS
SELECT
    observation_id,
    region_id,
    year_id,
    (
        0.09 * life_satisfaction +
        0.09 * meaning +
        0.08 * purpose +
        0.08 * autonomy +
        0.08 * social_trust +
        0.07 * belonging +
        0.09 * institutional_quality +
        0.08 * public_service_access +
        0.09 * ecological_stability +
        0.08 * health_index +
        0.08 * mental_health_index +
        0.08 * adaptive_capacity -
        0.06 * environmental_exposure -
        0.06 * insecurity_load -
        0.06 * inequality_index
    ) AS sustainable_flourishing_index
FROM sustainable_flourishing_observations;
