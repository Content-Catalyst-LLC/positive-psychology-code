#include <stdio.h>

typedef struct {
    double academic_score;
    double engagement;
    double belonging;
    double resilience;
    double life_satisfaction;
    double school_climate;
    double teacher_support;
    double purpose_learning;
    double stress_load;
    double exclusion_exposure;
    double access_support;
    double student_voice;
} PositiveEducationIndicators;

double school_flourishing_index(PositiveEducationIndicators x) {
    return 0.20 * x.academic_score
         + 0.18 * x.engagement
         + 0.18 * ((x.belonging + x.teacher_support) / 2.0)
         + 0.18 * ((x.resilience + x.life_satisfaction + x.purpose_learning) / 3.0)
         + 0.20 * ((x.school_climate + x.access_support + x.student_voice) / 3.0)
         - 0.14 * x.stress_load
         - 0.16 * x.exclusion_exposure;
}

int main(void) {
    PositiveEducationIndicators example = {82, 7.3, 7.5, 7.2, 7.4, 7.6, 7.7, 7.3, 2.9, 2.0, 7.5, 7.2};
    printf("School flourishing index: %.3f\n", school_flourishing_index(example));
    return 0;
}
