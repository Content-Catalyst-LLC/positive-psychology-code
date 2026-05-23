struct PositiveEducationIndicators {
    academic_score: f64,
    engagement: f64,
    belonging: f64,
    resilience: f64,
    life_satisfaction: f64,
    school_climate: f64,
    teacher_support: f64,
    purpose_learning: f64,
    stress_load: f64,
    exclusion_exposure: f64,
    access_support: f64,
    student_voice: f64,
}

fn school_flourishing_index(x: &PositiveEducationIndicators) -> f64 {
    0.20 * x.academic_score
        + 0.18 * x.engagement
        + 0.18 * ((x.belonging + x.teacher_support) / 2.0)
        + 0.18 * ((x.resilience + x.life_satisfaction + x.purpose_learning) / 3.0)
        + 0.20 * ((x.school_climate + x.access_support + x.student_voice) / 3.0)
        - 0.14 * x.stress_load
        - 0.16 * x.exclusion_exposure
}

fn main() {
    let example = PositiveEducationIndicators {
        academic_score: 82.0,
        engagement: 7.3,
        belonging: 7.5,
        resilience: 7.2,
        life_satisfaction: 7.4,
        school_climate: 7.6,
        teacher_support: 7.7,
        purpose_learning: 7.3,
        stress_load: 2.9,
        exclusion_exposure: 2.0,
        access_support: 7.5,
        student_voice: 7.2,
    };

    println!("School flourishing index: {:.3}", school_flourishing_index(&example));
}
