-- Professional relational schema for learned helplessness and agency-recovery research scaffolds.
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

CREATE TABLE IF NOT EXISTS learned_helplessness_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    domain_id TEXT NOT NULL,
    perceived_control REAL,
    uncontrollable_events REAL,
    stability_score REAL,
    globality_score REAL,
    internality_score REAL,
    motivation_score REAL,
    depressive_symptoms REAL,
    agency_score REAL,
    support_score REAL,
    mastery_experience REAL,
    recovery_opportunity REAL,
    feedback_quality REAL,
    institutional_fairness REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE TABLE IF NOT EXISTS learned_helplessness_context_audit (
    audit_id INTEGER PRIMARY KEY,
    setting TEXT NOT NULL,
    control_opportunities REAL,
    revision_pathways REAL,
    feedback_specificity REAL,
    institutional_fairness REAL,
    psychological_safety REAL,
    support_availability REAL,
    mastery_scaffolding REAL,
    recovery_opportunities REAL,
    anti_blame_review REAL,
    privacy_safeguards REAL,
    clinical_escalation_protocol REAL,
    measurement_quality REAL,
    overall_context_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS learned_helplessness_item_bank (
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

CREATE INDEX IF NOT EXISTS idx_helplessness_observations_participant_wave
ON learned_helplessness_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_helplessness_observations_domain_wave
ON learned_helplessness_observations(domain_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_helplessness_item_bank_construct
ON learned_helplessness_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS learned_helplessness_indices AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    domain_id,
    (
        stability_score +
        globality_score +
        internality_score
    ) / 3.0 AS helplessness_index,
    (
        perceived_control -
        uncontrollable_events
    ) AS control_gap,
    (
        agency_score +
        support_score +
        mastery_experience +
        recovery_opportunity +
        feedback_quality +
        institutional_fairness -
        uncontrollable_events -
        ((stability_score + globality_score + internality_score) / 3.0)
    ) AS agency_recovery_index,
    (
        motivation_score +
        perceived_control +
        agency_score +
        support_score +
        mastery_experience +
        feedback_quality +
        institutional_fairness -
        uncontrollable_events -
        ((stability_score + globality_score + internality_score) / 3.0) -
        depressive_symptoms
    ) AS motivation_protection_index
FROM learned_helplessness_observations;

CREATE VIEW IF NOT EXISTS learned_helplessness_context_quality_summary AS
SELECT
    audit_id,
    setting,
    (
        control_opportunities +
        revision_pathways +
        feedback_specificity +
        institutional_fairness +
        psychological_safety +
        support_availability +
        mastery_scaffolding +
        recovery_opportunities +
        anti_blame_review +
        privacy_safeguards +
        clinical_escalation_protocol +
        measurement_quality
    ) / 12.0 AS computed_context_quality,
    overall_context_quality
FROM learned_helplessness_context_audit;
