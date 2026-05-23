struct PermaIndicators {
    positive_emotion: f64,
    engagement: f64,
    relationships: f64,
    meaning: f64,
    accomplishment: f64,
    flourishing_score: f64,
    life_satisfaction: f64,
    institutional_support: f64,
    institutional_barriers: f64,
    autonomy_support: f64,
    fairness_score: f64,
    psychological_safety: f64,
    access_score: f64,
    workload_strain: f64,
}

fn perma_index(x: &PermaIndicators) -> f64 {
    (x.positive_emotion + x.engagement + x.relationships + x.meaning + x.accomplishment) / 5.0
}

fn institutional_quality(x: &PermaIndicators) -> f64 {
    x.institutional_support
        + x.autonomy_support
        + x.fairness_score
        + x.psychological_safety
        + x.access_score
        - x.institutional_barriers
        - x.workload_strain
}

fn context_adjusted_flourishing(x: &PermaIndicators) -> f64 {
    x.flourishing_score + x.life_satisfaction + perma_index(x) + institutional_quality(x)
}

fn main() {
    let example = PermaIndicators {
        positive_emotion: 6.9,
        engagement: 7.1,
        relationships: 7.2,
        meaning: 7.0,
        accomplishment: 7.1,
        flourishing_score: 7.1,
        life_satisfaction: 7.0,
        institutional_support: 7.2,
        institutional_barriers: 3.1,
        autonomy_support: 7.1,
        fairness_score: 7.0,
        psychological_safety: 7.2,
        access_score: 7.1,
        workload_strain: 3.4,
    };

    println!("PERMA index: {:.3}", perma_index(&example));
    println!("Institutional quality: {:.3}", institutional_quality(&example));
    println!("Context-adjusted flourishing: {:.3}", context_adjusted_flourishing(&example));
}
