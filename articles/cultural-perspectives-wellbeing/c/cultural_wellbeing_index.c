#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double social_support;
    double relational_harmony;
    double institutional_trust;
    double income_security;
    double civic_voice;
    double cultural_continuity;
    double place_attachment;
    double autonomy_value;
    double harmony_value;
} CulturalWellbeingIndicators;

double cultural_wellbeing_index(CulturalWellbeingIndicators x) {
    return 0.12 * x.life_satisfaction
         + 0.11 * x.social_support
         + 0.12 * x.relational_harmony
         + 0.10 * x.institutional_trust
         + 0.10 * x.income_security
         + 0.09 * x.civic_voice
         + 0.12 * x.cultural_continuity
         + 0.12 * x.place_attachment
         + 0.06 * x.autonomy_value
         + 0.06 * x.harmony_value;
}

int main(void) {
    CulturalWellbeingIndicators example = {6.9, 7.0, 7.4, 6.7, 6.5, 6.4, 7.4, 7.0, 6.0, 7.8};
    printf("Cultural well-being index: %.3f\n", cultural_wellbeing_index(example));
    return 0;
}
