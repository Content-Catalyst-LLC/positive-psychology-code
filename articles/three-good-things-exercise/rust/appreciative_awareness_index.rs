struct ThreeGoodThingsIndicators {
    life_satisfaction: f64,
    depressive_symptoms: f64,
    gratitude_score: f64,
    positive_event_salience: f64,
    perceived_support: f64,
    reflection_depth: f64,
    stress_load: f64,
    acceptability: f64,
    context_fit: f64,
}

fn appreciative_awareness_index(x: &ThreeGoodThingsIndicators) -> f64 {
    (x.gratitude_score
        + x.positive_event_salience
        + x.perceived_support
        + x.reflection_depth
        + x.acceptability
        + x.context_fit
        - x.stress_load)
        / 7.0
}

fn net_wellbeing_index(x: &ThreeGoodThingsIndicators) -> f64 {
    x.life_satisfaction
        + x.gratitude_score
        + x.positive_event_salience
        + x.perceived_support
        + x.reflection_depth
        - x.depressive_symptoms
        - x.stress_load
}

fn main() {
    let example = ThreeGoodThingsIndicators {
        life_satisfaction: 7.4,
        depressive_symptoms: 3.6,
        gratitude_score: 7.2,
        positive_event_salience: 7.1,
        perceived_support: 7.3,
        reflection_depth: 7.1,
        stress_load: 3.2,
        acceptability: 7.7,
        context_fit: 7.6,
    };

    println!("Appreciative awareness index: {:.3}", appreciative_awareness_index(&example));
    println!("Net wellbeing index: {:.3}", net_wellbeing_index(&example));
}
