fn dot(values: &[f64], weights: &[f64]) -> Result<f64, String> {
    if values.len() != weights.len() {
        return Err("values and weights must have the same length".to_string());
    }

    Ok(values.iter().zip(weights.iter()).map(|(v, w)| v * w).sum())
}

fn main() {
    let values = [7.4, 7.3, 7.2, 7.3, 7.4, 7.3, 7.5, 7.4, 7.1, 7.5, 7.2, 7.3, 2.9, 3.0, 2.7];
    let weights = [0.09, 0.09, 0.08, 0.08, 0.08, 0.07, 0.09, 0.08, 0.09, 0.08, 0.08, 0.08, -0.06, -0.06, -0.06];

    match dot(&values, &weights) {
        Ok(score) => println!("Sustainable flourishing index: {:.3}", score),
        Err(message) => eprintln!("Error: {}", message),
    }
}
