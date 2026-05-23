#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double health_index;
    double social_trust;
    double income_security;
    double institutional_quality;
    double housing_stability;
    double education_access;
    double care_access;
    double environmental_quality;
    double community_resilience;
    double stress_load;
} PublicHealthIndicators;

double public_wellbeing_index(PublicHealthIndicators x) {
    return 0.11 * x.life_satisfaction
         + 0.12 * x.health_index
         + 0.10 * x.social_trust
         + 0.10 * x.income_security
         + 0.11 * x.institutional_quality
         + 0.10 * x.housing_stability
         + 0.09 * x.education_access
         + 0.10 * x.care_access
         + 0.09 * x.environmental_quality
         + 0.10 * x.community_resilience
         - 0.10 * x.stress_load;
}

int main(void) {
    PublicHealthIndicators example = {7.4, 7.6, 7.3, 7.2, 7.5, 7.4, 7.6, 7.3, 7.1, 7.3, 3.0};
    printf("Public health well-being index: %.3f\n", public_wellbeing_index(example));
    return 0;
}
