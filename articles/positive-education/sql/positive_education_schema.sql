-- Professional relational schema for positive education research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, disciplinary,
-- ranking, public-benefits, employment, or individual student assessment use.

CREATE TABLE IF NOT EXISTS schools (
    school_id TEXT PRIMARY KEY,
    school_name TEXT,
    school_context TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS students (
    student_id TEXT PRIMARY KEY,
    school_id TEXT NOT NULL,
    grade_band TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(school_id)
);

CREATE TABLE IF NOT EXISTS waves (
    wave_id INTEGER PRIMARY KEY,
    wave_label TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS positive_education_observations (
    observation_id INTEGER PRIMARY KEY,
    student_id TEXT NOT NULL,
    school_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    academic_score REAL,
    engagement REAL,
    belonging REAL,
    resilience REAL,
    life_satisfaction REAL,
    school_climate REAL,
    teacher_support REAL,
    purpose_learning REAL,
    stress_load REAL,
    exclusion_exposure REAL,
    access_support REAL,
    student_voice REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (school_id) REFERENCES schools(school_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE TABLE IF NOT EXISTS implementation_quality_audit (
    audit_id INTEGER PRIMARY KEY,
    school_id TEXT NOT NULL,
    staff_training REAL,
    implementation_fidelity REAL,
    student_voice_in_design REAL,
    family_engagement REAL,
    equity_review REAL,
    privacy_safeguards REAL,
    mental_health_referral_pathway REAL,
    teacher_workload_support REAL,
    whole_school_alignment REAL,
    overall_implementation_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(school_id)
);

CREATE TABLE IF NOT EXISTS indicator_bank (
    indicator_id INTEGER PRIMARY KEY,
    student_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    indicator_code TEXT NOT NULL,
    indicator_family TEXT NOT NULL,
    response_value REAL,
    scale_direction TEXT DEFAULT 'higher_is_better',
    source_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id)
);

CREATE INDEX IF NOT EXISTS idx_pe_observations_student_wave
ON positive_education_observations(student_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_pe_observations_school_wave
ON positive_education_observations(school_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_indicator_bank_family
ON indicator_bank(indicator_family);

CREATE VIEW IF NOT EXISTS school_flourishing_composite AS
SELECT
    observation_id,
    student_id,
    school_id,
    wave_id,
    (
        0.20 * academic_score +
        0.18 * engagement +
        0.18 * ((belonging + teacher_support) / 2.0) +
        0.18 * ((resilience + life_satisfaction + purpose_learning) / 3.0) +
        0.20 * ((school_climate + access_support + student_voice) / 3.0) -
        0.14 * stress_load -
        0.16 * exclusion_exposure
    ) AS school_flourishing_index
FROM positive_education_observations;

CREATE VIEW IF NOT EXISTS implementation_quality_summary AS
SELECT
    audit_id,
    school_id,
    (
        staff_training +
        implementation_fidelity +
        student_voice_in_design +
        family_engagement +
        equity_review +
        privacy_safeguards +
        mental_health_referral_pathway +
        teacher_workload_support +
        whole_school_alignment
    ) / 9.0 AS computed_quality_mean,
    overall_implementation_quality
FROM implementation_quality_audit;
