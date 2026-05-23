struct GratitudeIndicators {
    gratitude_score: f64,
    life_satisfaction: f64,
    perceived_support: f64,
    resilience_score: f64,
    stress_load: f64,
    depressive_symptoms: f64,
    reflection_depth: f64,
    gratitude_expression: f64,
    intervention_fit: f64,
    relationship_quality: f64,
    social_trust: f64,
}

fn appreciative_orientation_index(x: &GratitudeIndicators) -> f64 {
    (x.gratitude_score
        + x.perceived_support
        + x.reflection_depth
        + x.gratitude_expression
        + x.relationship_quality
        + x.social_trust
        + x.intervention_fit
        - x.stress_load)
        / 8.0
}

fn relational_support_index(x: &GratitudeIndicators) -> f64 {
    (x.perceived_support + x.relationship_quality + x.social_trust + x.gratitude_expression) / 4.0
}

fn net_wellbeing_index(x: &GratitudeIndicators) -> f64 {
    x.life_satisfaction
        + x.gratitude_score
        + x.perceived_support
        + x.resilience_score
        + x.reflection_depth
        + x.gratitude_expression
        + x.relationship_quality
        + x.social_trust
        - x.depressive_symptoms
        - x.stress_load
}

fn main() {
    let example = GratitudeIndicators {
        gratitude_score: 7.2,
        life_satisfaction: 7.1,
        perceived_support: 7.3,
        resilience_score: 6.9,
        stress_load: 3.6,
        depressive_symptoms: 3.8,
        reflection_depth: 7.0,
        gratitude_expression: 7.1,
        intervention_fit: 7.2,
        relationship_quality: 7.4,
        social_trust: 7.1,
    };

    println!("Appreciative orientation index: {:.3}", appreciative_orientation_index(&example));
    println!("Relational support index: {:.3}", relational_support_index(&example));
    println!("Net wellbeing index: {:.3}", net_wellbeing_index(&example));
}
