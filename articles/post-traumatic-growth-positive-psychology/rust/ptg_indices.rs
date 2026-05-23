struct PTGIndicators {
    ptg_score: f64,
    wellbeing_score: f64,
    distress_score: f64,
    meaning_making: f64,
    restored_agency: f64,
    narrative_integration: f64,
    social_support: f64,
    context_support: f64,
    deliberate_rumination: f64,
    intrusive_rumination: f64,
    ongoing_stress: f64,
    perceived_growth: f64,
    corroborated_growth: f64,
}

fn integration_index(x: &PTGIndicators) -> f64 {
    (x.meaning_making
        + x.restored_agency
        + x.narrative_integration
        + x.social_support
        + x.context_support) / 5.0
}

fn reflection_balance(x: &PTGIndicators) -> f64 {
    x.deliberate_rumination - x.intrusive_rumination
}

fn growth_distress_balance(x: &PTGIndicators) -> f64 {
    x.ptg_score + x.wellbeing_score + integration_index(x) - x.distress_score - x.ongoing_stress
}

fn growth_alignment(x: &PTGIndicators) -> f64 {
    x.perceived_growth + x.corroborated_growth - (x.perceived_growth - x.corroborated_growth).abs()
}

fn main() {
    let example = PTGIndicators {
        ptg_score: 6.88,
        wellbeing_score: 6.8,
        distress_score: 5.6,
        meaning_making: 6.9,
        restored_agency: 6.8,
        narrative_integration: 6.8,
        social_support: 7.1,
        context_support: 6.9,
        deliberate_rumination: 6.7,
        intrusive_rumination: 5.3,
        ongoing_stress: 4.9,
        perceived_growth: 7.1,
        corroborated_growth: 6.6,
    };

    println!("Integration index: {:.3}", integration_index(&example));
    println!("Reflection balance: {:.3}", reflection_balance(&example));
    println!("Growth-distress balance: {:.3}", growth_distress_balance(&example));
    println!("Growth alignment: {:.3}", growth_alignment(&example));
}
