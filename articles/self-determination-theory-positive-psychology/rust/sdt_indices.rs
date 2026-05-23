struct SDTIndicators {
    autonomy_support: f64,
    competence_support: f64,
    relatedness_support: f64,
    need_frustration: f64,
    controlling_pressure: f64,
    autonomous_motivation: f64,
    controlled_motivation: f64,
    internalization: f64,
    wellbeing_score: f64,
    vitality: f64,
    stress_load: f64,
    climate_quality: f64,
}

fn need_support_index(x: &SDTIndicators) -> f64 {
    (x.autonomy_support + x.competence_support + x.relatedness_support) / 3.0
}

fn need_balance_index(x: &SDTIndicators) -> f64 {
    need_support_index(x) - x.need_frustration - x.controlling_pressure
}

fn motivational_quality_index(x: &SDTIndicators) -> f64 {
    x.autonomous_motivation + x.internalization - x.controlled_motivation
}

fn net_sdt_wellbeing_index(x: &SDTIndicators) -> f64 {
    x.wellbeing_score
        + x.vitality
        + x.autonomous_motivation
        + x.internalization
        + need_support_index(x)
        - x.controlled_motivation
        - x.stress_load
        - x.need_frustration
        - x.controlling_pressure
}

fn main() {
    let example = SDTIndicators {
        autonomy_support: 7.4,
        competence_support: 7.3,
        relatedness_support: 7.5,
        need_frustration: 2.0,
        controlling_pressure: 2.4,
        autonomous_motivation: 7.3,
        controlled_motivation: 2.8,
        internalization: 6.9,
        wellbeing_score: 7.4,
        vitality: 7.3,
        stress_load: 2.9,
        climate_quality: 7.6,
    };

    println!("Need support index: {:.3}", need_support_index(&example));
    println!("Need balance index: {:.3}", need_balance_index(&example));
    println!("Motivational quality index: {:.3}", motivational_quality_index(&example));
    println!("Net SDT wellbeing index: {:.3}", net_sdt_wellbeing_index(&example));
}
