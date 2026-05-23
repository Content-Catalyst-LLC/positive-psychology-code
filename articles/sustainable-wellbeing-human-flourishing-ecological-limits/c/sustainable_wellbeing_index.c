#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double meaning;
    double health;
    double social_trust;
    double institutional_quality;
    double ecological_integrity;
    double carbon_pressure;
    double inequality_index;
    double civic_participation;
} Indicators;

double sustainable_wellbeing_index(Indicators x) {
    return 0.16 * x.life_satisfaction
         + 0.14 * x.meaning
         + 0.12 * x.health
         + 0.12 * x.social_trust
         + 0.14 * x.institutional_quality
         + 0.14 * x.ecological_integrity
         + 0.10 * x.civic_participation
         - 0.04 * x.carbon_pressure
         - 0.04 * x.inequality_index;
}

int main(void) {
    Indicators example = {7.4, 7.8, 7.0, 6.9, 7.2, 7.1, 4.0, 3.0, 6.8};
    printf("Sustainable well-being index: %.3f\n", sustainable_wellbeing_index(example));
    return 0;
}
