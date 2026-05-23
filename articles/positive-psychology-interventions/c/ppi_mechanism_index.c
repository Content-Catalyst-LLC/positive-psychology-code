#include <stdio.h>

typedef struct {
    double wellbeing_score;
    double depressive_symptoms;
    double gratitude_score;
    double strengths_use;
    double hope_score;
    double meaning_score;
    double social_support;
    double adherence_rate;
    double intervention_fit;
    double stress_load;
    double acceptability;
    double context_fit;
} PPIIndicators;

double mechanism_index(PPIIndicators x) {
    return (x.gratitude_score + x.strengths_use + x.hope_score + x.meaning_score + x.social_support) / 5.0;
}

double practice_quality_proxy(PPIIndicators x) {
    return (x.adherence_rate + x.intervention_fit + x.acceptability + x.context_fit) / 4.0;
}

double net_wellbeing_index(PPIIndicators x) {
    return x.wellbeing_score + x.gratitude_score + x.strengths_use + x.hope_score + x.meaning_score + x.social_support + x.intervention_fit - x.stress_load - x.depressive_symptoms;
}

int main(void) {
    PPIIndicators example = {7.2, 3.8, 7.3, 6.5, 6.6, 6.7, 7.0, 0.88, 7.4, 3.4, 7.5, 7.4};
    printf("Mechanism index: %.3f\n", mechanism_index(example));
    printf("Practice quality proxy: %.3f\n", practice_quality_proxy(example));
    printf("Net wellbeing index: %.3f\n", net_wellbeing_index(example));
    return 0;
}
