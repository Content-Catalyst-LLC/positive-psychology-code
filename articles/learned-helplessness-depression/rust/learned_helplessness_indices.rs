struct HelplessnessIndicators {
    perceived_control: f64,
    uncontrollable_events: f64,
    stability_score: f64,
    globality_score: f64,
    internality_score: f64,
    motivation_score: f64,
    depressive_symptoms: f64,
    agency_score: f64,
    support_score: f64,
    mastery_experience: f64,
    recovery_opportunity: f64,
    feedback_quality: f64,
    institutional_fairness: f64,
}

fn helplessness_index(x: &HelplessnessIndicators) -> f64 {
    (x.stability_score + x.globality_score + x.internality_score) / 3.0
}

fn control_gap(x: &HelplessnessIndicators) -> f64 {
    x.perceived_control - x.uncontrollable_events
}

fn agency_recovery_index(x: &HelplessnessIndicators) -> f64 {
    x.agency_score
        + x.support_score
        + x.mastery_experience
        + x.recovery_opportunity
        + x.feedback_quality
        + x.institutional_fairness
        - x.uncontrollable_events
        - helplessness_index(x)
}

fn motivation_protection_index(x: &HelplessnessIndicators) -> f64 {
    x.motivation_score
        + x.perceived_control
        + x.agency_score
        + x.support_score
        + x.mastery_experience
        + x.feedback_quality
        + x.institutional_fairness
        - x.uncontrollable_events
        - helplessness_index(x)
        - x.depressive_symptoms
}

fn main() {
    let example = HelplessnessIndicators {
        perceived_control: 6.7,
        uncontrollable_events: 4.0,
        stability_score: 3.6,
        globality_score: 3.5,
        internality_score: 3.7,
        motivation_score: 6.6,
        depressive_symptoms: 3.9,
        agency_score: 6.7,
        support_score: 6.9,
        mastery_experience: 6.6,
        recovery_opportunity: 6.7,
        feedback_quality: 6.9,
        institutional_fairness: 6.8,
    };

    println!("Helplessness index: {:.3}", helplessness_index(&example));
    println!("Control gap: {:.3}", control_gap(&example));
    println!("Agency-recovery index: {:.3}", agency_recovery_index(&example));
    println!("Motivation-protection index: {:.3}", motivation_protection_index(&example));
}
