-- Professional relational schema for Hope Theory research scaffolds.
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

CREATE TABLE IF NOT EXISTS hope_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    domain_id TEXT NOT NULL,
    agency_score REAL,
    pathways_score REAL,
    goal_clarity REAL,
    goal_progress REAL,
    wellbeing_score REAL,
    meaning_score REAL,
    stress_load REAL,
    obstacle_intensity REAL,
    social_support REAL,
    resource_access REAL,
    goal_revision_quality REAL,
    context_support REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE TABLE IF NOT EXISTS context_support_audit (
    audit_id INTEGER PRIMARY KEY,
    setting TEXT NOT NULL,
    goal_clarity_support REAL,
    agency_support REAL,
    pathways_support REAL,
    resource_access_support REAL,
    obstacle_mapping_quality REAL,
    privacy_safeguards REAL,
    structural_barrier_review REAL,
    responsible_language REAL,
    overall_context_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS hope_item_bank (
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

CREATE INDEX IF NOT EXISTS idx_hope_observations_participant_wave
ON hope_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_hope_observations_domain_wave
ON hope_observations(domain_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_hope_item_bank_construct
ON hope_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS hope_indices AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    domain_id,
    (
        agency_score + pathways_score
    ) / 2.0 AS hope_index,
    (
        social_support + resource_access + context_support
    ) / 3.0 AS context_support_index,
    (
        pathways_score +
        ((social_support + resource_access + context_support) / 3.0) +
        goal_revision_quality -
        obstacle_intensity
    ) AS net_pathway_context,
    (
        agency_score +
        pathways_score +
        goal_clarity +
        goal_progress +
        meaning_score +
        ((social_support + resource_access + context_support) / 3.0) -
        stress_load -
        obstacle_intensity
    ) AS net_future_orientation
FROM hope_observations;

CREATE VIEW IF NOT EXISTS context_support_summary AS
SELECT
    audit_id,
    setting,
    (
        goal_clarity_support +
        agency_support +
        pathways_support +
        resource_access_support +
        obstacle_mapping_quality +
        privacy_safeguards +
        structural_barrier_review +
        responsible_language
    ) / 8.0 AS computed_context_quality,
    overall_context_quality
FROM context_support_audit;
