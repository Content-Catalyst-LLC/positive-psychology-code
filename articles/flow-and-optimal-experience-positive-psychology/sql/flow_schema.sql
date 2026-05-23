-- Professional relational schema for flow and optimal experience research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- employment, school disciplinary, productivity-surveillance, benefits eligibility,
-- ranking, or individual assessment use.

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

CREATE TABLE IF NOT EXISTS sessions (
    session_id INTEGER PRIMARY KEY,
    session_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS flow_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    session_id INTEGER NOT NULL,
    domain_id TEXT NOT NULL,
    challenge_level REAL,
    skill_level REAL,
    attention_focus REAL,
    feedback_quality REAL,
    goal_clarity REAL,
    task_meaning REAL,
    autonomy_support REAL,
    distraction_load REAL,
    interruption_count REAL,
    flow_score REAL,
    performance_score REAL,
    learning_gain REAL,
    fatigue_score REAL,
    recovery_quality REAL,
    wellbeing_score REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE TABLE IF NOT EXISTS attention_context_audit (
    audit_id INTEGER PRIMARY KEY,
    setting TEXT NOT NULL,
    goal_clarity_support REAL,
    feedback_quality_support REAL,
    challenge_calibration REAL,
    skill_development_support REAL,
    attention_protection REAL,
    autonomy_support_quality REAL,
    distraction_control REAL,
    recovery_support REAL,
    privacy_safeguards REAL,
    anti_surveillance_review REAL,
    overall_context_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS flow_item_bank (
    item_response_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    session_id INTEGER NOT NULL,
    domain_id TEXT NOT NULL,
    item_code TEXT NOT NULL,
    construct_family TEXT NOT NULL,
    response_value REAL,
    scale_direction TEXT DEFAULT 'higher_is_better',
    source_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE INDEX IF NOT EXISTS idx_flow_observations_participant_session
ON flow_observations(participant_id, session_id);

CREATE INDEX IF NOT EXISTS idx_flow_observations_domain_session
ON flow_observations(domain_id, session_id);

CREATE INDEX IF NOT EXISTS idx_flow_item_bank_construct
ON flow_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS flow_indices AS
SELECT
    observation_id,
    participant_id,
    session_id,
    domain_id,
    -ABS(challenge_level - skill_level) AS balance_index,
    (
        attention_focus +
        feedback_quality +
        goal_clarity -
        distraction_load -
        interruption_count
    ) AS attentional_ecology,
    (
        -ABS(challenge_level - skill_level) +
        attention_focus +
        feedback_quality +
        goal_clarity +
        task_meaning +
        autonomy_support -
        distraction_load -
        interruption_count
    ) AS deep_engagement_context,
    (
        flow_score +
        task_meaning +
        autonomy_support +
        recovery_quality -
        fatigue_score -
        distraction_load
    ) AS sustainable_flow_index
FROM flow_observations;

CREATE VIEW IF NOT EXISTS attention_context_quality_summary AS
SELECT
    audit_id,
    setting,
    (
        goal_clarity_support +
        feedback_quality_support +
        challenge_calibration +
        skill_development_support +
        attention_protection +
        autonomy_support_quality +
        distraction_control +
        recovery_support +
        privacy_safeguards +
        anti_surveillance_review
    ) / 10.0 AS computed_context_quality,
    overall_context_quality
FROM attention_context_audit;
