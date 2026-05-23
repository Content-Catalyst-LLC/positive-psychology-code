#include <stdio.h>

typedef struct {
    double life_expectancy;
    double education_index;
    double income_index;
    double life_satisfaction;
    double institutional_quality;
    double ecological_stability;
    double social_trust;
    double resilience_capacity;
    double basic_services;
    double inequality_index;
} SustainableIndicators;

double sustainable_flourishing_index(SustainableIndicators x) {
    return 0.11 * x.life_expectancy
         + 0.11 * x.education_index
         + 0.10 * x.income_index
         + 0.11 * x.life_satisfaction
         + 0.12 * x.institutional_quality
         + 0.12 * x.ecological_stability
         + 0.11 * x.social_trust
         + 0.10 * x.resilience_capacity
         + 0.10 * x.basic_services
         - 0.08 * x.inequality_index;
}

int main(void) {
    SustainableIndicators example = {7.8, 7.7, 7.6, 7.5, 7.7, 7.3, 7.6, 7.4, 7.8, 2.4};
    printf("Sustainable flourishing index: %.3f\n", sustainable_flourishing_index(example));
    return 0;
}
