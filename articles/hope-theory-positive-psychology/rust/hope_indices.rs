struct HopeIndicators {
    agency_score: f64,
    pathways_score: f64,
    goal_clarity: f64,
    goal_progress: f64,
    wellbeing_score: f64,
    meaning_score: f64,
    stress_load: f64,
    obstacle_intensity: f64,
    social_support: f64,
    resource_access: f64,
    goal_revision_quality: f64,
    context_support: f64,
}

fn hope_index(x: &HopeIndicators) -> f64 {
    (x.agency_score + x.pathways_score) / 2.0
}

fn context_support_index(x: &HopeIndicators) -> f64 {
    (x.social_support + x.resource_access + x.context_support) / 3.0
}

fn net_pathway_context(x: &HopeIndicators) -> f64 {
    x.pathways_score + context_support_index(x) + x.goal_revision_quality - x.obstacle_intensity
}

fn net_future_orientation(x: &HopeIndicators) -> f64 {
    x.agency_score
        + x.pathways_score
        + x.goal_clarity
        + x.goal_progress
        + x.meaning_score
        + context_support_index(x)
        - x.stress_load
        - x.obstacle_intensity
}

fn main() {
    let example = HopeIndicators {
        agency_score: 7.1,
        pathways_score: 7.0,
        goal_clarity: 7.3,
        goal_progress: 6.8,
        wellbeing_score: 7.1,
        meaning_score: 7.4,
        stress_load: 3.5,
        obstacle_intensity: 3.7,
        social_support: 7.2,
        resource_access: 6.8,
        goal_revision_quality: 6.6,
        context_support: 7.0,
    };

    println!("Hope index: {:.3}", hope_index(&example));
    println!("Context support index: {:.3}", context_support_index(&example));
    println!("Net pathway context: {:.3}", net_pathway_context(&example));
    println!("Net future orientation: {:.3}", net_future_orientation(&example));
}
