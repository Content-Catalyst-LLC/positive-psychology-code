struct BroadenBuildIndicators {
    positive_emotion: f64,
    negative_emotion: f64,
    cognitive_flexibility: f64,
    exploratory_behavior: f64,
    affiliative_behavior: f64,
    social_support: f64,
    resilience_score: f64,
    stress_arousal: f64,
    contextual_safety: f64,
    resource_stock: f64,
    practice_fit: f64,
}

fn broadening_index(x: &BroadenBuildIndicators) -> f64 {
    (x.positive_emotion
        + x.cognitive_flexibility
        + x.exploratory_behavior
        + x.affiliative_behavior
        + x.contextual_safety
        - x.negative_emotion)
        / 6.0
}

fn resource_index(x: &BroadenBuildIndicators) -> f64 {
    (x.social_support + x.resilience_score + x.contextual_safety + x.resource_stock + x.practice_fit) / 5.0
}

fn recovery_capacity_index(x: &BroadenBuildIndicators) -> f64 {
    (x.positive_emotion
        + x.social_support
        + x.contextual_safety
        + x.resilience_score
        - x.stress_arousal
        - x.negative_emotion)
        / 6.0
}

fn net_adaptation_index(x: &BroadenBuildIndicators) -> f64 {
    x.positive_emotion
        + x.cognitive_flexibility
        + x.exploratory_behavior
        + x.affiliative_behavior
        + x.social_support
        + x.resilience_score
        + x.contextual_safety
        + x.resource_stock
        + x.practice_fit
        - x.negative_emotion
        - x.stress_arousal
}

fn main() {
    let example = BroadenBuildIndicators {
        positive_emotion: 7.2,
        negative_emotion: 3.8,
        cognitive_flexibility: 7.1,
        exploratory_behavior: 7.0,
        affiliative_behavior: 7.2,
        social_support: 7.3,
        resilience_score: 6.9,
        stress_arousal: 3.6,
        contextual_safety: 7.2,
        resource_stock: 7.1,
        practice_fit: 7.3,
    };

    println!("Broadening index: {:.3}", broadening_index(&example));
    println!("Resource index: {:.3}", resource_index(&example));
    println!("Recovery capacity index: {:.3}", recovery_capacity_index(&example));
    println!("Net adaptation index: {:.3}", net_adaptation_index(&example));
}
