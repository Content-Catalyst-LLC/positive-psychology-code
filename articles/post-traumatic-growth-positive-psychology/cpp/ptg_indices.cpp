#include <cmath>
#include <iostream>

struct PTGIndicators {
    double ptg_score;
    double wellbeing_score;
    double distress_score;
    double meaning_making;
    double restored_agency;
    double narrative_integration;
    double social_support;
    double context_support;
    double deliberate_rumination;
    double intrusive_rumination;
    double ongoing_stress;
    double perceived_growth;
    double corroborated_growth;
};

double integration_index(const PTGIndicators& x) {
    return (
        x.meaning_making +
        x.restored_agency +
        x.narrative_integration +
        x.social_support +
        x.context_support
    ) / 5.0;
}

double reflection_balance(const PTGIndicators& x) {
    return x.deliberate_rumination - x.intrusive_rumination;
}

double growth_distress_balance(const PTGIndicators& x) {
    return x.ptg_score + x.wellbeing_score + integration_index(x) - x.distress_score - x.ongoing_stress;
}

double growth_alignment(const PTGIndicators& x) {
    return x.perceived_growth + x.corroborated_growth - std::abs(x.perceived_growth - x.corroborated_growth);
}

int main() {
    PTGIndicators example{6.88, 6.8, 5.6, 6.9, 6.8, 6.8, 7.1, 6.9, 6.7, 5.3, 4.9, 7.1, 6.6};

    std::cout << "Integration index: " << integration_index(example) << "\n";
    std::cout << "Reflection balance: " << reflection_balance(example) << "\n";
    std::cout << "Growth-distress balance: " << growth_distress_balance(example) << "\n";
    std::cout << "Growth alignment: " << growth_alignment(example) << "\n";

    return 0;
}
