#include <stdio.h>

typedef struct {
    double meaning;
    double relationships;
    double optimism;
    double resilience;
    double income_security;
    double institutional_trust;
    double cultural_fit;
    double environmental_quality;
    double inequality_exposure;
    double stress_load;
} CritiqueSensitiveIndicators;

double critique_sensitive_flourishing_index(CritiqueSensitiveIndicators x) {
    return 0.13 * x.meaning
         + 0.13 * x.relationships
         + 0.10 * x.optimism
         + 0.11 * x.resilience
         + 0.11 * x.income_security
         + 0.11 * x.institutional_trust
         + 0.09 * x.cultural_fit
         + 0.09 * x.environmental_quality
         - 0.08 * x.inequality_exposure
         - 0.08 * x.stress_load;
}

int main(void) {
    CritiqueSensitiveIndicators example = {7.4, 7.6, 7.3, 7.5, 7.6, 7.4, 7.3, 7.2, 2.2, 2.8};
    printf("Critique-sensitive flourishing index: %.3f\n", critique_sensitive_flourishing_index(example));
    return 0;
}
