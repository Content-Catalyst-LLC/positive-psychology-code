#include <iostream>

struct GratitudeIndicators {
    double gratitude_score;
    double life_satisfaction;
    double perceived_support;
    double resilience_score;
    double stress_load;
    double depressive_symptoms;
    double reflection_depth;
    double gratitude_expression;
    double intervention_fit;
    double relationship_quality;
    double social_trust;
};

double appreciative_orientation_index(const GratitudeIndicators& x) {
    return (
        x.gratitude_score +
        x.perceived_support +
        x.reflection_depth +
        x.gratitude_expression +
        x.relationship_quality +
        x.social_trust +
        x.intervention_fit -
        x.stress_load
    ) / 8.0;
}

double relational_support_index(const GratitudeIndicators& x) {
    return (
        x.perceived_support +
        x.relationship_quality +
        x.social_trust +
        x.gratitude_expression
    ) / 4.0;
}

double net_wellbeing_index(const GratitudeIndicators& x) {
    return x.life_satisfaction
         + x.gratitude_score
         + x.perceived_support
         + x.resilience_score
         + x.reflection_depth
         + x.gratitude_expression
         + x.relationship_quality
         + x.social_trust
         - x.depressive_symptoms
         - x.stress_load;
}

int main() {
    GratitudeIndicators example{7.2, 7.1, 7.3, 6.9, 3.6, 3.8, 7.0, 7.1, 7.2, 7.4, 7.1};
    std::cout << "Appreciative orientation index: " << appreciative_orientation_index(example) << "\n";
    std::cout << "Relational support index: " << relational_support_index(example) << "\n";
    std::cout << "Net wellbeing index: " << net_wellbeing_index(example) << "\n";
    return 0;
}
