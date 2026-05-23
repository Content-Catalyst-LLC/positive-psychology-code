-- Professional relational schema for explanatory style and optimism research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- employment, school disciplinary, benefits eligibility, ranking, or individual assessment use.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS domains (
    domain_id TEXT PRIMARY KEY,
    domain_label TEXT NOT NULL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS waves (
    wave_id INTEGER PRIMARY KEY,
    wave_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS explanatory_style_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    domain_id TEXT NOT NULL,
    neg_stability REAL,
    neg_globality REAL,
    neg_personalization REAL,
    pos_stability REAL,
    pos_globality REAL,
    pos_internal_effort REAL,
    setback_intensity REAL,
    controllability_score REAL,
    agency_score REAL,
    support_score REAL,
    persistence_score REAL,
    hope_score REAL,
    wellbeing_score REAL,
    distress_score REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE TABLE IF NOT EXISTS explanatory_style_context_audit (
    audit_id INTEGER PRIMARY KEY,
    setting TEXT NOT NULL,
    feedback_specificity REAL,
    revision_pathways REAL,
    fairness_of_evaluation REAL,
    agency_support REAL,
    controllability_support REAL,
    psychological_safety REAL,
    support_availability REAL,
    anti_blame_review REAL,
    privacy_safeguards REAL,
    cultural_adaptation REAL,
    measurement_quality REAL,
    overall_context_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS explanatory_style_item_bank (
    item_response_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    domain_id TEXT NOT NULL,
    item_code TEXT NOT NULL,
    construct_family TEXT NOT NULL,
    response_value REAL,
    scale_direction TEXT DEFAULT 'higher_is_better',
    source_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE INDEX IF NOT EXISTS idx_explanatory_observations_participant_wave
ON explanatory_style_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_explanatory_observations_domain_wave
ON explanatory_style_observations(domain_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_explanatory_item_bank_construct
ON explanatory_style_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS explanatory_style_indices AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    domain_id,
    (
        neg_stability +
        neg_globality +
        neg_personalization
    ) / 3.0 AS explanatory_burden,
    (
        pos_stability +
        pos_globality +
        pos_internal_effort
    ) / 3.0 AS positive_event_integration,
    (
        agency_score +
        support_score +
        controllability_score -
        setback_intensity -
        ((neg_stability + neg_globality + neg_personalization) / 3.0)
    ) AS context_adjusted_agency,
    (
        persistence_score +
        hope_score +
        agency_score +
        support_score +
        ((pos_stability + pos_globality + pos_internal_effort) / 3.0) -
        setback_intensity -
        ((neg_stability + neg_globality + neg_personalization) / 3.0) -
        distress_score
    ) AS resilient_persistence_index
FROM explanatory_style_observations;

CREATE VIEW IF NOT EXISTS explanatory_style_context_quality_summary AS
SELECT
    audit_id,
    setting,
    (
        feedback_specificity +
        revision_pathways +
        fairness_of_evaluation +
        agency_support +
        controllability_support +
        psychological_safety +
        support_availability +
        anti_blame_review +
        privacy_safeguards +
        cultural_adaptation +
        measurement_quality
    ) / 11.0 AS computed_context_quality,
    overall_context_quality
FROM explanatory_style_context_audit;
