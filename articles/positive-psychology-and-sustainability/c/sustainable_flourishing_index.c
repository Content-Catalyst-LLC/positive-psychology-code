#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double meaning;
    double purpose;
    double autonomy;
    double social_trust;
    double belonging;
    double institutional_quality;
    double public_service_access;
    double ecological_stability;
    double health_index;
    double mental_health_index;
    double adaptive_capacity;
    double environmental_exposure;
    double insecurity_load;
    double inequality_index;
} SustainableFlourishingIndicators;

double sustainable_flourishing_index(SustainableFlourishingIndicators x) {
    return 0.09 * x.life_satisfaction
         + 0.09 * x.meaning
         + 0.08 * x.purpose
         + 0.08 * x.autonomy
         + 0.08 * x.social_trust
         + 0.07 * x.belonging
         + 0.09 * x.institutional_quality
         + 0.08 * x.public_service_access
         + 0.09 * x.ecological_stability
         + 0.08 * x.health_index
         + 0.08 * x.mental_health_index
         + 0.08 * x.adaptive_capacity
         - 0.06 * x.environmental_exposure
         - 0.06 * x.insecurity_load
         - 0.06 * x.inequality_index;
}

int main(void) {
    SustainableFlourishingIndicators example = {
        7.4, 7.3, 7.2, 7.3, 7.4, 7.3, 7.5, 7.4,
        7.1, 7.5, 7.2, 7.3, 2.9, 3.0, 2.7
    };

    printf("Sustainable flourishing index: %.3f\n", sustainable_flourishing_index(example));
    return 0;
}
