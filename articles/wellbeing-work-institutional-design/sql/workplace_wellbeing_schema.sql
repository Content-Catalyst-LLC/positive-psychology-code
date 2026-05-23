CREATE TABLE IF NOT EXISTS workplace_wellbeing_observations (
    observation_id INTEGER PRIMARY KEY,
    employee_id TEXT NOT NULL,
    team_id TEXT,
    department TEXT,
    wave INTEGER,
    autonomy_support REAL,
    competence_growth REAL,
    relatedness_trust REAL,
    work_meaning REAL,
    psychological_safety REAL,
    supervisor_support REAL,
    recovery_capacity REAL,
    role_overload REAL,
    job_insecurity REAL,
    burnout_risk REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wwo_employee_wave
ON workplace_wellbeing_observations(employee_id, wave);

CREATE INDEX IF NOT EXISTS idx_wwo_department_wave
ON workplace_wellbeing_observations(department, wave);

CREATE VIEW IF NOT EXISTS workplace_flourishing_composite AS
SELECT
    observation_id,
    employee_id,
    team_id,
    department,
    wave,
    (
        0.15 * autonomy_support +
        0.14 * competence_growth +
        0.14 * relatedness_trust +
        0.14 * work_meaning +
        0.14 * psychological_safety +
        0.10 * supervisor_support +
        0.09 * recovery_capacity -
        0.05 * role_overload -
        0.05 * job_insecurity
    ) AS workplace_flourishing_index
FROM workplace_wellbeing_observations;
