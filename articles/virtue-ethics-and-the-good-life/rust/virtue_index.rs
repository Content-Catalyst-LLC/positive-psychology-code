fn mean(values: &[f64]) -> f64 {
    values.iter().sum::<f64>() / values.len() as f64
}

fn main() {
    let virtues = [4.2, 3.8, 4.4, 4.1, 3.7, 4.0];
    let flourishing = [4.1, 4.3, 3.9, 4.0];

    println!("Mean virtue-domain score: {:.3}", mean(&virtues));
    println!("Mean flourishing score: {:.3}", mean(&flourishing));
}
