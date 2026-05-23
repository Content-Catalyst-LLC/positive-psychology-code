#include <stdio.h>

typedef struct {
    double income_security;
    double life_satisfaction;
    double health_index;
    double social_trust;
    double institutional_quality;
    double environmental_quality;
    double work_quality;
    double care_security;
    double public_services;
    double inequality_index;
    double time_pressure;
} WellbeingEconomyIndicators;

double wellbeing_economy_index(WellbeingEconomyIndicators x) {
    return 0.12 * x.income_security
         + 0.12 * x.life_satisfaction
         + 0.12 * x.health_index
         + 0.11 * x.social_trust
         + 0.11 * x.institutional_quality
         + 0.10 * x.environmental_quality
         + 0.10 * x.work_quality
         + 0.10 * x.care_security
         + 0.10 * x.public_services
         - 0.06 * x.inequality_index
         - 0.06 * x.time_pressure;
}

int main(void) {
    WellbeingEconomyIndicators example = {7.6, 7.5, 7.7, 7.6, 7.8, 7.3, 7.4, 7.5, 7.8, 2.4, 2.9};
    printf("Well-being economy index: %.3f\n", wellbeing_economy_index(example));
    return 0;
}
