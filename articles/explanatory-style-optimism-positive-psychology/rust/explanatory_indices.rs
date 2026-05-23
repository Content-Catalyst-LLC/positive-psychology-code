struct ExplanatoryIndicators {
    neg_stability: f64,
    neg_globality: f64,
    neg_personalization: f64,
    pos_stability: f64,
    pos_globality: f64,
    pos_internal_effort: f64,
    setback_intensity: f64,
    controllability_score: f64,
    agency_score: f64,
    support_score: f64,
    persistence_score: f64,
    hope_score: f64,
    wellbeing_score: f64,
    distress_score: f64,
}

fn explanatory_burden(x: &ExplanatoryIndicators) -> f64 {
    (x.neg_stability + x.neg_globality + x.neg_personalization) / 3.0
}

fn positive_event_integration(x: &ExplanatoryIndicators) -> f64 {
    (x.pos_stability + x.pos_globality + x.pos_internal_effort) / 3.0
}

fn context_adjusted_agency(x: &ExplanatoryIndicators) -> f64 {
    x.agency_score + x.support_score + x.controllability_score
        - x.setback_intensity
        - explanatory_burden(x)
}

fn resilient_persistence_index(x: &ExplanatoryIndicators) -> f64 {
    x.persistence_score + x.hope_score + x.agency_score + x.support_score
        + positive_event_integration(x)
        - x.setback_intensity
        - explanatory_burden(x)
        - x.distress_score
}

fn main() {
    let example = ExplanatoryIndicators {
        neg_stability: 3.8,
        neg_globality: 3.6,
        neg_personalization: 3.7,
        pos_stability: 6.6,
        pos_globality: 6.4,
        pos_internal_effort: 6.5,
        setback_intensity: 4.3,
        controllability_score: 6.5,
        agency_score: 6.6,
        support_score: 6.7,
        persistence_score: 6.6,
        hope_score: 6.7,
        wellbeing_score: 6.6,
        distress_score: 4.0,
    };

    println!("Explanatory burden: {:.3}", explanatory_burden(&example));
    println!("Positive-event integration: {:.3}", positive_event_integration(&example));
    println!("Context-adjusted agency: {:.3}", context_adjusted_agency(&example));
    println!("Resilient persistence index: {:.3}", resilient_persistence_index(&example));
}
