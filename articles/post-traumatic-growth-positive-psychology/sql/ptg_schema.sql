-- Professional relational schema for post-traumatic growth research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- crisis-triage, employment, school disciplinary, benefits eligibility,
-- legal, insurance, ranking, or individual assessment use.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS trauma_contexts (
    context_id TEXT PRIMARY KEY,
    context_label TEXT NOT NULL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS waves (
    wave_id INTEGER PRIMARY KEY,
    wave_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS ptg_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    context_id TEXT NOT NULL,
    assumptive_disruption REAL,
    intrusive_rumination REAL,
    deliberate_rumination REAL,
    meaning_making REAL,
    social_support REAL,
    restored_agency REAL,
    narrative_integration REAL,
    context_support REAL,
    ongoing_stress REAL,
    ptg_appreciation REAL,
    ptg_relationships REAL,
    ptg_strength REAL,
    ptg_new_possibilities REAL,
    ptg_existential_change REAL,
    ptg_score REAL,
    distress_score REAL,
    wellbeing_score REAL,
    perceived_growth REAL,
    corroborated_growth REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (context_id) REFERENCES trauma_contexts(context_id)
);

CREATE TABLE IF NOT EXISTS ptg_context_support_audit (
    audit_id INTEGER PRIMARY KEY,
    setting TEXT NOT NULL,
    safety_stabilization REAL,
    meaning_support REAL,
    narrative_support REAL,
    social_support_quality REAL,
    agency_restoration REAL,
    privacy_safeguards REAL,
    trauma_informed_language REAL,
    structural_barrier_review REAL,
    measurement_quality REAL,
    overall_context_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ptg_item_bank (
    item_response_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    context_id TEXT NOT NULL,
    item_code TEXT NOT NULL,
    construct_family TEXT NOT NULL,
    response_value REAL,
    scale_direction TEXT DEFAULT 'higher_is_better',
    source_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (context_id) REFERENCES trauma_contexts(context_id)
);

CREATE INDEX IF NOT EXISTS idx_ptg_observations_participant_wave
ON ptg_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_ptg_observations_context_wave
ON ptg_observations(context_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_ptg_item_bank_construct
ON ptg_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS ptg_indices AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    context_id,
    (
        ptg_appreciation +
        ptg_relationships +
        ptg_strength +
        ptg_new_possibilities +
        ptg_existential_change
    ) / 5.0 AS ptg_domain_mean,
    (
        meaning_making +
        restored_agency +
        narrative_integration +
        social_support +
        context_support
    ) / 5.0 AS integration_index,
    (
        deliberate_rumination - intrusive_rumination
    ) AS reflective_processing_balance,
    (
        ptg_score +
        wellbeing_score +
        ((meaning_making + restored_agency + narrative_integration + social_support + context_support) / 5.0)
        - distress_score
        - ongoing_stress
    ) AS growth_distress_balance,
    (
        perceived_growth +
        corroborated_growth -
        ABS(perceived_growth - corroborated_growth)
    ) AS growth_alignment
FROM ptg_observations;

CREATE VIEW IF NOT EXISTS ptg_context_quality_summary AS
SELECT
    audit_id,
    setting,
    (
        safety_stabilization +
        meaning_support +
        narrative_support +
        social_support_quality +
        agency_restoration +
        privacy_safeguards +
        trauma_informed_language +
        structural_barrier_review +
        measurement_quality
    ) / 9.0 AS computed_context_quality,
    overall_context_quality
FROM ptg_context_support_audit;
