struct MeaningIndicators {
    meaning_presence: f64,
    meaning_search: f64,
    purpose_score: f64,
    coherence_score: f64,
    significance_score: f64,
    belonging_score: f64,
    value_alignment: f64,
    institutional_support: f64,
    wellbeing_score: f64,
    goal_persistence: f64,
    stress_load: f64,
    alienation_score: f64,
    identity_integration: f64,
    context_quality: f64,
}

fn meaning_system_index(x: &MeaningIndicators) -> f64 {
    (x.meaning_presence
        + x.purpose_score
        + x.coherence_score
        + x.significance_score
        + x.belonging_score
        + x.value_alignment
        + x.identity_integration) / 7.0
}

fn context_adjusted_meaning(x: &MeaningIndicators) -> f64 {
    meaning_system_index(x) + x.institutional_support + x.context_quality - x.stress_load - x.alienation_score
}

fn directed_life_index(x: &MeaningIndicators) -> f64 {
    x.purpose_score + x.goal_persistence + x.value_alignment + x.institutional_support - x.stress_load
}

fn search_context_index(x: &MeaningIndicators) -> f64 {
    x.meaning_search + x.stress_load + x.alienation_score - x.meaning_presence - x.coherence_score
}

fn main() {
    let example = MeaningIndicators {
        meaning_presence: 7.1,
        meaning_search: 4.9,
        purpose_score: 7.2,
        coherence_score: 6.9,
        significance_score: 7.1,
        belonging_score: 7.2,
        value_alignment: 7.0,
        institutional_support: 6.8,
        wellbeing_score: 7.1,
        goal_persistence: 7.2,
        stress_load: 3.7,
        alienation_score: 3.1,
        identity_integration: 6.9,
        context_quality: 7.0,
    };

    println!("Meaning system index: {:.3}", meaning_system_index(&example));
    println!("Context-adjusted meaning: {:.3}", context_adjusted_meaning(&example));
    println!("Directed-life index: {:.3}", directed_life_index(&example));
    println!("Search-context index: {:.3}", search_context_index(&example));
}
