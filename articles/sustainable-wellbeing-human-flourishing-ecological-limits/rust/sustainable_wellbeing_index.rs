fn dot(values: &[f64], weights: &[f64]) -> Result<f64, String> {
    if values.len() != weights.len() {
        return Err("values and weights must have the same length".to_string());
    }

    Ok(values.iter().zip(weights.iter()).map(|(v, w)| v * w).sum())
}

fn main() {
    let values = [7.4, 7.8, 7.0, 6.9, 7.2, 7.1, 4.0, 3.0, 6.8];
    let weights = [0.16, 0.14, 0.12, 0.12, 0.14, 0.14, -0.04, -0.04, 0.10];

    match dot(&values, &weights) {
        Ok(score) => println!("Sustainable well-being index: {:.3}", score),
        Err(message) => eprintln!("Error: {}", message),
    }
}
