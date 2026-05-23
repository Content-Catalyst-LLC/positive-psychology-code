#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double meaning;
    double social_trust;
    double institutional_quality;
    double environmental_quality;
    double health_index;
    double resilience_score;
    double material_security;
    double civic_voice;
    double stress_load;
} WellbeingIndicators;

double future_wellbeing_index(WellbeingIndicators x) {
    return 0.13 * x.life_satisfaction
         + 0.13 * x.meaning
         + 0.12 * x.social_trust
         + 0.12 * x.institutional_quality
         + 0.12 * x.environmental_quality
         + 0.13 * x.health_index
         + 0.10 * x.resilience_score
         + 0.10 * x.material_security
         + 0.10 * x.civic_voice
         - 0.05 * x.stress_load;
}

int main(void) {
    WellbeingIndicators example = {7.4, 7.6, 7.0, 7.2, 6.9, 7.3, 7.1, 7.0, 6.9, 3.2};
    printf("Future well-being index: %.3f\n", future_wellbeing_index(example));
    return 0;
}
