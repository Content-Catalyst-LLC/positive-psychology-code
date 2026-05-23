-- Professional relational schema for meaning and purpose research scaffolds.
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

CREATE TABLE IF NOT EXISTS meaning_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    domain_id TEXT NOT NULL,
    meaning_presence REAL,
    meaning_search REAL,
    purpose_score REAL,
    coherence_score REAL,
    significance_score REAL,
    belonging_score REAL,
    value_alignment REAL,
    institutional_support REAL,
    wellbeing_score REAL,
    goal_persistence REAL,
    stress_load REAL,
    alienation_score REAL,
    identity_integration REAL,
    context_quality REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE TABLE IF NOT EXISTS institutional_context_audit (
    audit_id INTEGER PRIMARY KEY,
    setting TEXT NOT NULL,
    coherence_support REAL,
    purpose_support REAL,
    significance_support REAL,
    belonging_support REAL,
    value_alignment_support REAL,
    agency_support REAL,
    privacy_safeguards REAL,
    cultural_adaptation REAL,
    anti_exploitation_review REAL,
    measurement_quality REAL,
    overall_context_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS meaning_item_bank (
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

CREATE INDEX IF NOT EXISTS idx_meaning_observations_participant_wave
ON meaning_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_meaning_observations_domain_wave
ON meaning_observations(domain_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_meaning_item_bank_construct
ON meaning_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS meaning_indices AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    domain_id,
    (
        meaning_presence +
        purpose_score +
        coherence_score +
        significance_score +
        belonging_score +
        value_alignment +
        identity_integration
    ) / 7.0 AS meaning_system_index,
    (
        (
            meaning_presence +
            purpose_score +
            coherence_score +
            significance_score +
            belonging_score +
            value_alignment +
            identity_integration
        ) / 7.0
        + institutional_support
        + context_quality
        - stress_load
        - alienation_score
    ) AS context_adjusted_meaning,
    (
        purpose_score +
        goal_persistence +
        value_alignment +
        institutional_support -
        stress_load
    ) AS directed_life_index,
    (
        meaning_search +
        stress_load +
        alienation_score -
        meaning_presence -
        coherence_score
    ) AS search_context_index
FROM meaning_observations;

CREATE VIEW IF NOT EXISTS institutional_context_quality_summary AS
SELECT
    audit_id,
    setting,
    (
        coherence_support +
        purpose_support +
        significance_support +
        belonging_support +
        value_alignment_support +
        agency_support +
        privacy_safeguards +
        cultural_adaptation +
        anti_exploitation_review +
        measurement_quality
    ) / 10.0 AS computed_context_quality,
    overall_context_quality
FROM institutional_context_audit;
