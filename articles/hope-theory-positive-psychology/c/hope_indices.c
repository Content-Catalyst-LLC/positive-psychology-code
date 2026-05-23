#include <stdio.h>

typedef struct {
    double agency_score;
    double pathways_score;
    double goal_clarity;
    double goal_progress;
    double wellbeing_score;
    double meaning_score;
    double stress_load;
    double obstacle_intensity;
    double social_support;
    double resource_access;
    double goal_revision_quality;
    double context_support;
} HopeIndicators;

double hope_index(HopeIndicators x) {
    return (x.agency_score + x.pathways_score) / 2.0;
}

double context_support_index(HopeIndicators x) {
    return (x.social_support + x.resource_access + x.context_support) / 3.0;
}

double net_pathway_context(HopeIndicators x) {
    return x.pathways_score + context_support_index(x) + x.goal_revision_quality - x.obstacle_intensity;
}

double net_future_orientation(HopeIndicators x) {
    return x.agency_score
         + x.pathways_score
         + x.goal_clarity
         + x.goal_progress
         + x.meaning_score
         + context_support_index(x)
         - x.stress_load
         - x.obstacle_intensity;
}

int main(void) {
    HopeIndicators example = {7.1, 7.0, 7.3, 6.8, 7.1, 7.4, 3.5, 3.7, 7.2, 6.8, 6.6, 7.0};
    printf("Hope index: %.3f\n", hope_index(example));
    printf("Context support index: %.3f\n", context_support_index(example));
    printf("Net pathway context: %.3f\n", net_pathway_context(example));
    printf("Net future orientation: %.3f\n", net_future_orientation(example));
    return 0;
}
