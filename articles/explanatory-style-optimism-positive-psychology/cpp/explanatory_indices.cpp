#include <iostream>

struct ExplanatoryIndicators {
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
};

double explanatory_burden(const ExplanatoryIndicators& x) {
    return (x.neg_stability + x.neg_globality + x.neg_personalization) / 3.0;
}

double positive_event_integration(const ExplanatoryIndicators& x) {
    return (x.pos_stability + x.pos_globality + x.pos_internal_effort) / 3.0;
}

double context_adjusted_agency(const ExplanatoryIndicators& x) {
    return x.agency_score + x.support_score + x.controllability_score -
           x.setback_intensity - explanatory_burden(x);
}

double resilient_persistence_index(const ExplanatoryIndicators& x) {
    return x.persistence_score + x.hope_score + x.agency_score + x.support_score +
           positive_event_integration(x) - x.setback_intensity -
           explanatory_burden(x) - x.distress_score;
}

int main() {
    ExplanatoryIndicators example{3.8, 3.6, 3.7, 6.6, 6.4, 6.5, 4.3, 6.5, 6.6, 6.7, 6.6, 6.7, 6.6, 4.0};

    std::cout << "Explanatory burden: " << explanatory_burden(example) << "\n";
    std::cout << "Positive-event integration: " << positive_event_integration(example) << "\n";
    std::cout << "Context-adjusted agency: " << context_adjusted_agency(example) << "\n";
    std::cout << "Resilient persistence index: " << resilient_persistence_index(example) << "\n";

    return 0;
}
