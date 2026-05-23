#include <stdio.h>

typedef struct {
    double neg_stability;
    double neg_globality;
    double neg_personalization;
    double pos_stability;
    double pos_globality;
    double pos_internal_effort;
    double setback_intensity;
    double controllability_score;
    double agency_score;
    double support_score;
    double persistence_score;
    double hope_score;
    double wellbeing_score;
    double distress_score;
} ExplanatoryIndicators;

double explanatory_burden(ExplanatoryIndicators x) {
    return (x.neg_stability + x.neg_globality + x.neg_personalization) / 3.0;
}

double positive_event_integration(ExplanatoryIndicators x) {
    return (x.pos_stability + x.pos_globality + x.pos_internal_effort) / 3.0;
}

double context_adjusted_agency(ExplanatoryIndicators x) {
    return x.agency_score + x.support_score + x.controllability_score -
           x.setback_intensity - explanatory_burden(x);
}

double resilient_persistence_index(ExplanatoryIndicators x) {
    return x.persistence_score + x.hope_score + x.agency_score + x.support_score +
           positive_event_integration(x) - x.setback_intensity -
           explanatory_burden(x) - x.distress_score;
}

int main(void) {
    ExplanatoryIndicators example = {3.8, 3.6, 3.7, 6.6, 6.4, 6.5, 4.3, 6.5, 6.6, 6.7, 6.6, 6.7, 6.6, 4.0};

    printf("Explanatory burden: %.3f\n", explanatory_burden(example));
    printf("Positive-event integration: %.3f\n", positive_event_integration(example));
    printf("Context-adjusted agency: %.3f\n", context_adjusted_agency(example));
    printf("Resilient persistence index: %.3f\n", resilient_persistence_index(example));

    return 0;
}
