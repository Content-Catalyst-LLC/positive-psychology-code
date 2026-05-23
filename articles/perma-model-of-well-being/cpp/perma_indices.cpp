#include <iostream>

struct PermaIndicators {
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
};

double perma_index(const PermaIndicators& x) {
    return (x.positive_emotion + x.engagement + x.relationships + x.meaning + x.accomplishment) / 5.0;
}

double institutional_quality(const PermaIndicators& x) {
    return x.institutional_support + x.autonomy_support + x.fairness_score +
           x.psychological_safety + x.access_score -
           x.institutional_barriers - x.workload_strain;
}

double context_adjusted_flourishing(const PermaIndicators& x) {
    return x.flourishing_score + x.life_satisfaction + perma_index(x) + institutional_quality(x);
}

int main() {
    PermaIndicators example{6.9, 7.1, 7.2, 7.0, 7.1, 7.1, 7.0, 7.2, 3.1, 7.1, 7.0, 7.2, 7.1, 3.4};

    std::cout << "PERMA index: " << perma_index(example) << "\n";
    std::cout << "Institutional quality: " << institutional_quality(example) << "\n";
    std::cout << "Context-adjusted flourishing: " << context_adjusted_flourishing(example) << "\n";

    return 0;
}
