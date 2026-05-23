#include <stdio.h>

typedef struct {
    double positive_emotion;
    double negative_emotion;
    double cognitive_flexibility;
    double exploratory_behavior;
    double affiliative_behavior;
    double social_support;
    double resilience_score;
    double stress_arousal;
    double contextual_safety;
    double resource_stock;
    double practice_fit;
} BroadenBuildIndicators;

double broadening_index(BroadenBuildIndicators x) {
    return (
        x.positive_emotion +
        x.cognitive_flexibility +
        x.exploratory_behavior +
        x.affiliative_behavior +
        x.contextual_safety -
        x.negative_emotion
    ) / 6.0;
}

double resource_index(BroadenBuildIndicators x) {
    return (
        x.social_support +
        x.resilience_score +
        x.contextual_safety +
        x.resource_stock +
        x.practice_fit
    ) / 5.0;
}

double recovery_capacity_index(BroadenBuildIndicators x) {
    return (
        x.positive_emotion +
        x.social_support +
        x.contextual_safety +
        x.resilience_score -
        x.stress_arousal -
        x.negative_emotion
    ) / 6.0;
}

double net_adaptation_index(BroadenBuildIndicators x) {
    return x.positive_emotion
         + x.cognitive_flexibility
         + x.exploratory_behavior
         + x.affiliative_behavior
         + x.social_support
         + x.resilience_score
         + x.contextual_safety
         + x.resource_stock
         + x.practice_fit
         - x.negative_emotion
         - x.stress_arousal;
}

int main(void) {
    BroadenBuildIndicators example = {7.2, 3.8, 7.1, 7.0, 7.2, 7.3, 6.9, 3.6, 7.2, 7.1, 7.3};
    printf("Broadening index: %.3f\n", broadening_index(example));
    printf("Resource index: %.3f\n", resource_index(example));
    printf("Recovery capacity index: %.3f\n", recovery_capacity_index(example));
    printf("Net adaptation index: %.3f\n", net_adaptation_index(example));
    return 0;
}
