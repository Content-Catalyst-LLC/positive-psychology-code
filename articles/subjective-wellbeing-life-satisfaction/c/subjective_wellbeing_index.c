#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double positive_affect;
    double negative_affect;
    double social_support;
    double income_security;
    double meaning_alignment;
    double stress_load;
} SWBIndicators;

double subjective_wellbeing_index(SWBIndicators x) {
    return 0.30 * x.life_satisfaction
         + 0.25 * x.positive_affect
         - 0.25 * x.negative_affect
         + 0.10 * x.social_support
         + 0.08 * x.income_security
         + 0.10 * x.meaning_alignment
         - 0.08 * x.stress_load;
}

int main(void) {
    SWBIndicators example = {7.4, 7.2, 2.9, 7.0, 6.9, 7.6, 3.4};
    printf("Subjective well-being index: %.3f\n", subjective_wellbeing_index(example));
    return 0;
}
