#include <iostream>

struct HopeIndicators {
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
};

double hope_index(const HopeIndicators& x) {
    return (x.agency_score + x.pathways_score) / 2.0;
}

double context_support_index(const HopeIndicators& x) {
    return (x.social_support + x.resource_access + x.context_support) / 3.0;
}

double net_pathway_context(const HopeIndicators& x) {
    return x.pathways_score + context_support_index(x) + x.goal_revision_quality - x.obstacle_intensity;
}

double net_future_orientation(const HopeIndicators& x) {
    return x.agency_score
         + x.pathways_score
         + x.goal_clarity
         + x.goal_progress
         + x.meaning_score
         + context_support_index(x)
         - x.stress_load
         - x.obstacle_intensity;
}

int main() {
    HopeIndicators example{7.1, 7.0, 7.3, 6.8, 7.1, 7.4, 3.5, 3.7, 7.2, 6.8, 6.6, 7.0};

    std::cout << "Hope index: " << hope_index(example) << "\n";
    std::cout << "Context support index: " << context_support_index(example) << "\n";
    std::cout << "Net pathway context: " << net_pathway_context(example) << "\n";
    std::cout << "Net future orientation: " << net_future_orientation(example) << "\n";

    return 0;
}
