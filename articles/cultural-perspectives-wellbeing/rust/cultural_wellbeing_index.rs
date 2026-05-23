fn dot(values: &[f64], weights: &[f64]) -> Result<f64, String> {
    if values.len() != weights.len() {
        return Err("values and weights must have the same length".to_string());
    }

    Ok(values.iter().zip(weights.iter()).map(|(v, w)| v * w).sum())
}

fn main() {
    let values = [6.9, 7.0, 7.4, 6.7, 6.5, 6.4, 7.4, 7.0, 6.0, 7.8];
    let weights = [0.12, 0.11, 0.12, 0.10, 0.10, 0.09, 0.12, 0.12, 0.06, 0.06];

    match dot(&values, &weights) {
        Ok(score) => println!("Cultural well-being index: {:.3}", score),
        Err(message) => eprintln!("Error: {}", message),
    }
}
