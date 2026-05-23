-- Professional relational schema for Self-Determination Theory research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- employment, school disciplinary, public-benefits, ranking, or individual assessment use.

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

CREATE TABLE IF NOT EXISTS sdt_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    domain_id TEXT NOT NULL,
    autonomy_support REAL,
    competence_support REAL,
    relatedness_support REAL,
    need_frustration REAL,
    controlling_pressure REAL,
    autonomous_motivation REAL,
    controlled_motivation REAL,
    internalization REAL,
    wellbeing_score REAL,
    vitality REAL,
    stress_load REAL,
    climate_quality REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE TABLE IF NOT EXISTS motivational_climate_audit (
    audit_id INTEGER PRIMARY KEY,
    domain_id TEXT NOT NULL,
    autonomy_support_design REAL,
    competence_scaffolding REAL,
    relatedness_climate REAL,
    need_frustration_risk REAL,
    privacy_safeguards REAL,
    power_context_review REAL,
    measurement_quality REAL,
    overall_climate_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (domain_id) REFERENCES domains(domain_id)
);

CREATE TABLE IF NOT EXISTS sdt_item_bank (
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

CREATE INDEX IF NOT EXISTS idx_sdt_observations_participant_wave
ON sdt_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_sdt_observations_domain_wave
ON sdt_observations(domain_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_sdt_item_bank_construct
ON sdt_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS sdt_indices AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    domain_id,
    (
        autonomy_support +
        competence_support +
        relatedness_support
    ) / 3.0 AS need_support_index,
    (
        ((autonomy_support + competence_support + relatedness_support) / 3.0)
        - need_frustration
        - controlling_pressure
    ) AS need_balance_index,
    (
        autonomous_motivation +
        internalization -
        controlled_motivation
    ) AS motivational_quality_index,
    (
        wellbeing_score +
        vitality +
        autonomous_motivation +
        internalization +
        ((autonomy_support + competence_support + relatedness_support) / 3.0)
        - controlled_motivation
        - stress_load
        - need_frustration
        - controlling_pressure
    ) AS net_sdt_wellbeing_index
FROM sdt_observations;

CREATE VIEW IF NOT EXISTS motivational_climate_summary AS
SELECT
    audit_id,
    domain_id,
    (
        autonomy_support_design +
        competence_scaffolding +
        relatedness_climate +
        privacy_safeguards +
        power_context_review +
        measurement_quality
    ) / 6.0 AS support_quality_mean,
    need_frustration_risk,
    (
        (
            autonomy_support_design +
            competence_scaffolding +
            relatedness_climate +
            privacy_safeguards +
            power_context_review +
            measurement_quality
        ) / 6.0
    ) - 0.35 * need_frustration_risk AS risk_adjusted_climate_quality,
    overall_climate_quality
FROM motivational_climate_audit;
