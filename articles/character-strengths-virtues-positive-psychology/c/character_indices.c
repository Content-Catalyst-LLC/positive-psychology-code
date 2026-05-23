#include <stdio.h>

typedef struct {
    double wisdom;
    double courage;
    double humanity;
    double justice;
    double temperance;
    double transcendence;
    double signature_strength_use;
    double authenticity_score;
    double contextual_support;
    double institutional_suppression;
    double strength_overuse_risk;
    double flourishing_score;
} CharacterIndicators;

double virtue_profile_mean(CharacterIndicators x) {
    return (x.wisdom + x.courage + x.humanity + x.justice + x.temperance + x.transcendence) / 6.0;
}

double strength_expression_index(CharacterIndicators x) {
    return x.signature_strength_use + x.authenticity_score + x.contextual_support -
           x.institutional_suppression - x.strength_overuse_risk;
}

double context_adjusted_flourishing(CharacterIndicators x) {
    return x.flourishing_score + strength_expression_index(x) + x.contextual_support -
           x.institutional_suppression - x.strength_overuse_risk;
}

int main(void) {
    CharacterIndicators example = {7.2, 7.0, 7.5, 7.2, 7.0, 7.4, 7.3, 7.4, 7.2, 2.9, 2.6, 7.3};

    printf("Virtue profile mean: %.3f\n", virtue_profile_mean(example));
    printf("Strength-expression index: %.3f\n", strength_expression_index(example));
    printf("Context-adjusted flourishing: %.3f\n", context_adjusted_flourishing(example));

    return 0;
}
