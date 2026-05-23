#include <iostream>

struct MeaningIndicators {
    double meaning_presence;
    double meaning_search;
    double purpose_score;
    double coherence_score;
    double significance_score;
    double belonging_score;
    double value_alignment;
    double institutional_support;
    double wellbeing_score;
    double goal_persistence;
    double stress_load;
    double alienation_score;
    double identity_integration;
    double context_quality;
};

double meaning_system_index(const MeaningIndicators& x) {
    return (
        x.meaning_presence +
        x.purpose_score +
        x.coherence_score +
        x.significance_score +
        x.belonging_score +
        x.value_alignment +
        x.identity_integration
    ) / 7.0;
}

double context_adjusted_meaning(const MeaningIndicators& x) {
    return meaning_system_index(x) + x.institutional_support + x.context_quality - x.stress_load - x.alienation_score;
}

double directed_life_index(const MeaningIndicators& x) {
    return x.purpose_score + x.goal_persistence + x.value_alignment + x.institutional_support - x.stress_load;
}

double search_context_index(const MeaningIndicators& x) {
    return x.meaning_search + x.stress_load + x.alienation_score - x.meaning_presence - x.coherence_score;
}

int main() {
    MeaningIndicators example{7.1, 4.9, 7.2, 6.9, 7.1, 7.2, 7.0, 6.8, 7.1, 7.2, 3.7, 3.1, 6.9, 7.0};

    std::cout << "Meaning system index: " << meaning_system_index(example) << "\n";
    std::cout << "Context-adjusted meaning: " << context_adjusted_meaning(example) << "\n";
    std::cout << "Directed-life index: " << directed_life_index(example) << "\n";
    std::cout << "Search-context index: " << search_context_index(example) << "\n";

    return 0;
}
