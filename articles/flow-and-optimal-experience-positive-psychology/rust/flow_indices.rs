struct FlowIndicators {
    challenge_level: f64,
    skill_level: f64,
    attention_focus: f64,
    feedback_quality: f64,
    goal_clarity: f64,
    task_meaning: f64,
    autonomy_support: f64,
    distraction_load: f64,
    interruption_count: f64,
    flow_score: f64,
    performance_score: f64,
    learning_gain: f64,
    fatigue_score: f64,
    recovery_quality: f64,
    wellbeing_score: f64,
}

fn balance_index(x: &FlowIndicators) -> f64 {
    -(x.challenge_level - x.skill_level).abs()
}

fn attentional_ecology(x: &FlowIndicators) -> f64 {
    x.attention_focus + x.feedback_quality + x.goal_clarity - x.distraction_load - x.interruption_count
}

fn deep_engagement_context(x: &FlowIndicators) -> f64 {
    balance_index(x)
        + x.attention_focus
        + x.feedback_quality
        + x.goal_clarity
        + x.task_meaning
        + x.autonomy_support
        - x.distraction_load
        - x.interruption_count
}

fn sustainable_flow_index(x: &FlowIndicators) -> f64 {
    x.flow_score + x.task_meaning + x.autonomy_support + x.recovery_quality
        - x.fatigue_score
        - x.distraction_load
}

fn main() {
    let example = FlowIndicators {
        challenge_level: 7.1,
        skill_level: 7.0,
        attention_focus: 7.3,
        feedback_quality: 7.1,
        goal_clarity: 7.4,
        task_meaning: 7.4,
        autonomy_support: 7.2,
        distraction_load: 3.0,
        interruption_count: 1.0,
        flow_score: 7.2,
        performance_score: 7.3,
        learning_gain: 0.39,
        fatigue_score: 3.2,
        recovery_quality: 7.0,
        wellbeing_score: 7.2,
    };

    println!("Challenge-skill balance: {:.3}", balance_index(&example));
    println!("Attentional ecology: {:.3}", attentional_ecology(&example));
    println!("Deep engagement context: {:.3}", deep_engagement_context(&example));
    println!("Sustainable flow index: {:.3}", sustainable_flow_index(&example));
}
