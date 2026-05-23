fn dot(values: &[f64], weights: &[f64]) -> Result<f64, String> {
    if values.len() != weights.len() {
        return Err("values and weights must have the same length".to_string());
    }

    Ok(values.iter().zip(weights.iter()).map(|(v, w)| v * w).sum())
}

fn main() {
    let values = [7.4, 7.2, 2.9, 7.0, 6.9, 7.6, 3.4];
    let weights = [0.30, 0.25, -0.25, 0.10, 0.08, 0.10, -0.08];

    match dot(&values, &weights) {
        Ok(score) => println!("Subjective well-being index: {:.3}", score),
        Err(message) => eprintln!("Error: {}", message),
    }
}
