#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double positive_affect;
    double negative_affect;
    double purpose_life;
    double personal_growth;
    double autonomy;
    double positive_relations;
    double accomplishment;
    double health_index;
    double contextual_support;
    double stress_load;
} FlourishingIndicators;

double hedonic_index(FlourishingIndicators x) {
    return x.life_satisfaction + x.positive_affect - x.negative_affect;
}

double eudaimonic_index(FlourishingIndicators x) {
    return (x.purpose_life + x.personal_growth + x.autonomy) / 3.0;
}

double integrated_flourishing_index(FlourishingIndicators x) {
    return 0.25 * hedonic_index(x)
         + 0.25 * eudaimonic_index(x)
         + 0.15 * x.positive_relations
         + 0.15 * x.accomplishment
         + 0.15 * x.health_index
         + 0.15 * x.contextual_support
         - 0.15 * x.stress_load;
}

int main(void) {
    FlourishingIndicators example = {7.6, 7.4, 2.5, 7.5, 7.4, 7.3, 7.7, 7.4, 7.5, 7.5, 2.8};
    printf("Hedonic index: %.3f\n", hedonic_index(example));
    printf("Eudaimonic index: %.3f\n", eudaimonic_index(example));
    printf("Integrated flourishing index: %.3f\n", integrated_flourishing_index(example));
    return 0;
}
