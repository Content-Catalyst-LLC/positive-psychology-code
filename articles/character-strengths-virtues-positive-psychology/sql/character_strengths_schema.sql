-- Professional relational schema for character strengths and virtues research scaffolds.
-- Synthetic-data scaffold only; not for clinical, diagnostic, therapeutic,
-- employment, school disciplinary, benefits eligibility, moral ranking,
-- or individual assessment use.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contexts (
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

CREATE TABLE IF NOT EXISTS character_strength_observations (
    observation_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    wave_id INTEGER NOT NULL,
    context_id TEXT NOT NULL,
    creativity REAL,
    curiosity REAL,
    judgment REAL,
    love_learning REAL,
    perspective REAL,
    bravery REAL,
    perseverance REAL,
    honesty REAL,
    zest REAL,
    love REAL,
    kindness REAL,
    social_intelligence REAL,
    teamwork REAL,
    fairness REAL,
    leadership REAL,
    forgiveness REAL,
    humility REAL,
    prudence REAL,
    self_regulation REAL,
    appreciation_beauty REAL,
    gratitude REAL,
    hope REAL,
    humor REAL,
    spirituality REAL,
    signature_strength_use REAL,
    authenticity_score REAL,
    contextual_support REAL,
    institutional_suppression REAL,
    strength_overuse_risk REAL,
    flourishing_score REAL,
    wellbeing_score REAL,
    meaning_score REAL,
    relationship_quality REAL,
    engagement_score REAL,
    data_source TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (wave_id) REFERENCES waves(wave_id),
    FOREIGN KEY (context_id) REFERENCES contexts(context_id)
);

CREATE TABLE IF NOT EXISTS character_context_audit (
    audit_id INTEGER PRIMARY KEY,
    setting TEXT NOT NULL,
    truth_telling_support REAL,
    fairness_support REAL,
    humility_support REAL,
    leadership_accountability REAL,
    care_support REAL,
    learning_support REAL,
    autonomy_support REAL,
    anti_coercion_review REAL,
    privacy_safeguards REAL,
    cultural_adaptation REAL,
    measurement_quality REAL,
    overall_context_quality REAL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS character_item_bank (
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
    FOREIGN KEY (context_id) REFERENCES contexts(context_id)
);

CREATE INDEX IF NOT EXISTS idx_character_observations_participant_wave
ON character_strength_observations(participant_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_character_observations_context_wave
ON character_strength_observations(context_id, wave_id);

CREATE INDEX IF NOT EXISTS idx_character_item_bank_construct
ON character_item_bank(construct_family);

CREATE VIEW IF NOT EXISTS virtue_clusters AS
SELECT
    observation_id,
    participant_id,
    wave_id,
    context_id,
    (creativity + curiosity + judgment + love_learning + perspective) / 5.0 AS wisdom,
    (bravery + perseverance + honesty + zest) / 4.0 AS courage,
    (love + kindness + social_intelligence) / 3.0 AS humanity,
    (teamwork + fairness + leadership) / 3.0 AS justice,
    (forgiveness + humility + prudence + self_regulation) / 4.0 AS temperance,
    (appreciation_beauty + gratitude + hope + humor + spirituality) / 5.0 AS transcendence
FROM character_strength_observations;

CREATE VIEW IF NOT EXISTS character_strength_indices AS
SELECT
    c.observation_id,
    c.participant_id,
    c.wave_id,
    c.context_id,
    v.wisdom,
    v.courage,
    v.humanity,
    v.justice,
    v.temperance,
    v.transcendence,
    (v.wisdom + v.courage + v.humanity + v.justice + v.temperance + v.transcendence) / 6.0 AS virtue_profile_mean,
    (
        c.signature_strength_use +
        c.authenticity_score +
        c.contextual_support -
        c.institutional_suppression -
        c.strength_overuse_risk
    ) AS strength_expression_index,
    (
        c.fairness +
        c.leadership +
        c.humility +
        c.honesty +
        c.self_regulation
    ) / 5.0 AS civic_character_index,
    (
        c.kindness +
        c.social_intelligence +
        c.gratitude +
        c.honesty
    ) / 4.0 AS relational_character_index
FROM character_strength_observations c
JOIN virtue_clusters v
ON c.observation_id = v.observation_id;

CREATE VIEW IF NOT EXISTS character_context_quality_summary AS
SELECT
    audit_id,
    setting,
    (
        truth_telling_support +
        fairness_support +
        humility_support +
        leadership_accountability +
        care_support +
        learning_support +
        autonomy_support +
        anti_coercion_review +
        privacy_safeguards +
        cultural_adaptation +
        measurement_quality
    ) / 11.0 AS computed_context_quality,
    overall_context_quality
FROM character_context_audit;
