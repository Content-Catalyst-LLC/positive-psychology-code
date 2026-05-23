fn mean(values: &[f64]) -> f64 {
    values.iter().sum::<f64>() / values.len() as f64
}

fn main() {
    let life_satisfaction = 7.6;
    let positive_affect = 7.4;
    let negative_affect = 2.5;
    let eudaimonic_values = [7.5, 7.4, 7.3];
    let positive_relations = 7.7;
    let accomplishment = 7.4;
    let health_index = 7.5;
    let contextual_support = 7.5;
    let stress_load = 2.8;

    let hedonic = life_satisfaction + positive_affect - negative_affect;
    let eudaimonic = mean(&eudaimonic_values);
    let integrated =
        0.25 * hedonic +
        0.25 * eudaimonic +
        0.15 * positive_relations +
        0.15 * accomplishment +
        0.15 * health_index +
        0.15 * contextual_support -
        0.15 * stress_load;

    println!("Hedonic index: {:.3}", hedonic);
    println!("Eudaimonic index: {:.3}", eudaimonic);
    println!("Integrated flourishing index: {:.3}", integrated);
}
