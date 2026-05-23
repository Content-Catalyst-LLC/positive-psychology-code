struct CharacterIndicators {
    wisdom: f64,
    courage: f64,
    humanity: f64,
    justice: f64,
    temperance: f64,
    transcendence: f64,
    signature_strength_use: f64,
    authenticity_score: f64,
    contextual_support: f64,
    institutional_suppression: f64,
    strength_overuse_risk: f64,
    flourishing_score: f64,
}

fn virtue_profile_mean(x: &CharacterIndicators) -> f64 {
    (x.wisdom + x.courage + x.humanity + x.justice + x.temperance + x.transcendence) / 6.0
}

fn strength_expression_index(x: &CharacterIndicators) -> f64 {
    x.signature_strength_use + x.authenticity_score + x.contextual_support
        - x.institutional_suppression
        - x.strength_overuse_risk
}

fn context_adjusted_flourishing(x: &CharacterIndicators) -> f64 {
    x.flourishing_score + strength_expression_index(x) + x.contextual_support
        - x.institutional_suppression
        - x.strength_overuse_risk
}

fn main() {
    let example = CharacterIndicators {
        wisdom: 7.2,
        courage: 7.0,
        humanity: 7.5,
        justice: 7.2,
        temperance: 7.0,
        transcendence: 7.4,
        signature_strength_use: 7.3,
        authenticity_score: 7.4,
        contextual_support: 7.2,
        institutional_suppression: 2.9,
        strength_overuse_risk: 2.6,
        flourishing_score: 7.3,
    };

    println!("Virtue profile mean: {:.3}", virtue_profile_mean(&example));
    println!("Strength-expression index: {:.3}", strength_expression_index(&example));
    println!("Context-adjusted flourishing: {:.3}", context_adjusted_flourishing(&example));
}
