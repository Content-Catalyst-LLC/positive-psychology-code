struct PPIIndicators {
    wellbeing_score: f64,
    depressive_symptoms: f64,
    gratitude_score: f64,
    strengths_use: f64,
    hope_score: f64,
    meaning_score: f64,
    social_support: f64,
    adherence_rate: f64,
    intervention_fit: f64,
    stress_load: f64,
    acceptability: f64,
    context_fit: f64,
}

fn mechanism_index(x: &PPIIndicators) -> f64 {
    (x.gratitude_score + x.strengths_use + x.hope_score + x.meaning_score + x.social_support) / 5.0
}

fn practice_quality_proxy(x: &PPIIndicators) -> f64 {
    (x.adherence_rate + x.intervention_fit + x.acceptability + x.context_fit) / 4.0
}

fn net_wellbeing_index(x: &PPIIndicators) -> f64 {
    x.wellbeing_score + x.gratitude_score + x.strengths_use + x.hope_score + x.meaning_score + x.social_support + x.intervention_fit - x.stress_load - x.depressive_symptoms
}

fn main() {
    let example = PPIIndicators {
        wellbeing_score: 7.2,
        depressive_symptoms: 3.8,
        gratitude_score: 7.3,
        strengths_use: 6.5,
        hope_score: 6.6,
        meaning_score: 6.7,
        social_support: 7.0,
        adherence_rate: 0.88,
        intervention_fit: 7.4,
        stress_load: 3.4,
        acceptability: 7.5,
        context_fit: 7.4,
    };

    println!("Mechanism index: {:.3}", mechanism_index(&example));
    println!("Practice quality proxy: {:.3}", practice_quality_proxy(&example));
    println!("Net wellbeing index: {:.3}", net_wellbeing_index(&example));
}
