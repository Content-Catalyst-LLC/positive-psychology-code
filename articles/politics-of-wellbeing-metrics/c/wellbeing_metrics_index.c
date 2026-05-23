#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double health;
    double trust;
    double income_security;
    double housing_quality;
    double education_access;
    double democratic_quality;
    double environmental_quality;
    double inequality;
} Indicators;

double public_wellbeing_index(Indicators x) {
    return 0.16 * x.life_satisfaction
         + 0.14 * x.health
         + 0.14 * x.trust
         + 0.14 * x.income_security
         + 0.10 * x.housing_quality
         + 0.10 * x.education_access
         + 0.10 * x.democratic_quality
         + 0.08 * x.environmental_quality
         - 0.08 * x.inequality;
}

int main(void) {
    Indicators example = {7.4, 7.3, 6.9, 7.0, 6.8, 7.2, 7.5, 6.9, 3.0};
    printf("Public well-being index: %.3f\n", public_wellbeing_index(example));
    return 0;
}
