#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double positive_affect;
    double negative_affect;
    double autonomy;
    double personal_growth;
    double purpose_life;
    double positive_relations;
    double environmental_mastery;
    double self_acceptance;
    double contextual_support;
    double stress_load;
} WellbeingIndicators;

double hedonic_index(WellbeingIndicators x) {
    return x.life_satisfaction + x.positive_affect - x.negative_affect;
}

double eudaimonic_index(WellbeingIndicators x) {
    return (
        x.autonomy +
        x.personal_growth +
        x.purpose_life +
        x.positive_relations +
        x.environmental_mastery +
        x.self_acceptance
    ) / 6.0;
}

double integrated_flourishing_index(WellbeingIndicators x) {
    return 0.40 * hedonic_index(x)
         + 0.45 * eudaimonic_index(x)
         + 0.20 * x.contextual_support
         - 0.20 * x.stress_load;
}

int main(void) {
    WellbeingIndicators example = {7.6, 7.4, 2.5, 7.3, 7.4, 7.5, 7.7, 7.4, 7.3, 7.5, 2.8};
    printf("Hedonic index: %.3f\n", hedonic_index(example));
    printf("Eudaimonic index: %.3f\n", eudaimonic_index(example));
    printf("Integrated flourishing index: %.3f\n", integrated_flourishing_index(example));
    return 0;
}
