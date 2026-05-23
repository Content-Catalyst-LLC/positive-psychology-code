fn dot(values: &[f64], weights: &[f64]) -> Result<f64, String> {
    if values.len() != weights.len() {
        return Err("values and weights must have the same length".to_string());
    }

    Ok(values.iter().zip(weights.iter()).map(|(v, w)| v * w).sum())
}

fn main() {
    let values = [7.8, 7.7, 7.6, 7.5, 7.7, 7.3, 7.6, 7.4, 7.8, 2.4];
    let weights = [0.11, 0.11, 0.10, 0.11, 0.12, 0.12, 0.11, 0.10, 0.10, -0.08];

    match dot(&values, &weights) {
        Ok(score) => println!("Sustainable flourishing index: {:.3}", score),
        Err(message) => eprintln!("Error: {}", message),
    }
}
