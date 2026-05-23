#include <stdio.h>
#include <math.h>

typedef struct {
    double ptg_score;
    double wellbeing_score;
    double distress_score;
    double meaning_making;
    double restored_agency;
    double narrative_integration;
    double social_support;
    double context_support;
    double deliberate_rumination;
    double intrusive_rumination;
    double ongoing_stress;
    double perceived_growth;
    double corroborated_growth;
} PTGIndicators;

double integration_index(PTGIndicators x) {
    return (
        x.meaning_making +
        x.restored_agency +
        x.narrative_integration +
        x.social_support +
        x.context_support
    ) / 5.0;
}

double reflection_balance(PTGIndicators x) {
    return x.deliberate_rumination - x.intrusive_rumination;
}

double growth_distress_balance(PTGIndicators x) {
    return x.ptg_score + x.wellbeing_score + integration_index(x) - x.distress_score - x.ongoing_stress;
}

double growth_alignment(PTGIndicators x) {
    return x.perceived_growth + x.corroborated_growth - fabs(x.perceived_growth - x.corroborated_growth);
}

int main(void) {
    PTGIndicators example = {6.88, 6.8, 5.6, 6.9, 6.8, 6.8, 7.1, 6.9, 6.7, 5.3, 4.9, 7.1, 6.6};

    printf("Integration index: %.3f\n", integration_index(example));
    printf("Reflection balance: %.3f\n", reflection_balance(example));
    printf("Growth-distress balance: %.3f\n", growth_distress_balance(example));
    printf("Growth alignment: %.3f\n", growth_alignment(example));

    return 0;
}
