#include <stdio.h>

typedef struct {
    double positive_emotion;
    double engagement;
    double relationships;
    double meaning;
    double accomplishment;
    double flourishing_score;
    double life_satisfaction;
    double institutional_support;
    double institutional_barriers;
    double autonomy_support;
    double fairness_score;
    double psychological_safety;
    double access_score;
    double workload_strain;
} PermaIndicators;

double perma_index(PermaIndicators x) {
    return (x.positive_emotion + x.engagement + x.relationships + x.meaning + x.accomplishment) / 5.0;
}

double institutional_quality(PermaIndicators x) {
    return x.institutional_support + x.autonomy_support + x.fairness_score +
           x.psychological_safety + x.access_score -
           x.institutional_barriers - x.workload_strain;
}

double context_adjusted_flourishing(PermaIndicators x) {
    return x.flourishing_score + x.life_satisfaction + perma_index(x) + institutional_quality(x);
}

int main(void) {
    PermaIndicators example = {6.9, 7.1, 7.2, 7.0, 7.1, 7.1, 7.0, 7.2, 3.1, 7.1, 7.0, 7.2, 7.1, 3.4};

    printf("PERMA index: %.3f\n", perma_index(example));
    printf("Institutional quality: %.3f\n", institutional_quality(example));
    printf("Context-adjusted flourishing: %.3f\n", context_adjusted_flourishing(example));

    return 0;
}
