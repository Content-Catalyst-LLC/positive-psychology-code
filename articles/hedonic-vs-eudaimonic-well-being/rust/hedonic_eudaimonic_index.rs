fn mean(values: &[f64]) -> f64 {
    values.iter().sum::<f64>() / values.len() as f64
}

fn main() {
    let life_satisfaction = 7.6;
    let positive_affect = 7.4;
    let negative_affect = 2.5;
    let eudaimonic_values = [7.3, 7.4, 7.5, 7.7, 7.4, 7.3];
    let contextual_support = 7.5;
    let stress_load = 2.8;

    let hedonic = life_satisfaction + positive_affect - negative_affect;
    let eudaimonic = mean(&eudaimonic_values);
    let integrated = 0.40 * hedonic + 0.45 * eudaimonic + 0.20 * contextual_support - 0.20 * stress_load;

    println!("Hedonic index: {:.3}", hedonic);
    println!("Eudaimonic index: {:.3}", eudaimonic);
    println!("Integrated flourishing index: {:.3}", integrated);
}
