fn flourishing_score(engagement: f64, relationships: f64, meaning: f64, accomplishment: f64, health: f64, affect: f64, stress: f64) -> f64 {
    0.15 * engagement + 0.20 * relationships + 0.20 * meaning + 0.12 * accomplishment + 0.15 * health + 0.10 * affect - 0.12 * stress
}

fn main() {
    let score = flourishing_score(0.72, 0.80, 0.76, 0.65, 0.70, 0.68, 0.25);
    println!("Flourishing score: {:.3}", score);
}
