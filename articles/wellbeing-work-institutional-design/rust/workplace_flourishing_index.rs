fn dot(values: &[f64], weights: &[f64]) -> Result<f64, String> {
    if values.len() != weights.len() {
        return Err("values and weights must have the same length".to_string());
    }

    Ok(values.iter().zip(weights.iter()).map(|(v, w)| v * w).sum())
}

fn main() {
    let values = [7.4, 7.2, 7.0, 7.6, 7.1, 7.3, 6.8, 3.5, 2.8];
    let weights = [0.15, 0.14, 0.14, 0.14, 0.14, 0.10, 0.09, -0.05, -0.05];

    match dot(&values, &weights) {
        Ok(score) => println!("Workplace flourishing index: {:.3}", score),
        Err(message) => eprintln!("Error: {}", message),
    }
}
