#include <iostream>

struct HelplessnessIndicators {
    double perceived_control;
    double uncontrollable_events;
    double stability_score;
    double globality_score;
    double internality_score;
    double motivation_score;
    double depressive_symptoms;
    double agency_score;
    double support_score;
    double mastery_experience;
    double recovery_opportunity;
    double feedback_quality;
    double institutional_fairness;
};

double helplessness_index(const HelplessnessIndicators& x) {
    return (x.stability_score + x.globality_score + x.internality_score) / 3.0;
}

double control_gap(const HelplessnessIndicators& x) {
    return x.perceived_control - x.uncontrollable_events;
}

double agency_recovery_index(const HelplessnessIndicators& x) {
    return x.agency_score + x.support_score + x.mastery_experience + x.recovery_opportunity +
           x.feedback_quality + x.institutional_fairness -
           x.uncontrollable_events - helplessness_index(x);
}

double motivation_protection_index(const HelplessnessIndicators& x) {
    return x.motivation_score + x.perceived_control + x.agency_score + x.support_score +
           x.mastery_experience + x.feedback_quality + x.institutional_fairness -
           x.uncontrollable_events - helplessness_index(x) - x.depressive_symptoms;
}

int main() {
    HelplessnessIndicators example{6.7, 4.0, 3.6, 3.5, 3.7, 6.6, 3.9, 6.7, 6.9, 6.6, 6.7, 6.9, 6.8};

    std::cout << "Helplessness index: " << helplessness_index(example) << "\n";
    std::cout << "Control gap: " << control_gap(example) << "\n";
    std::cout << "Agency-recovery index: " << agency_recovery_index(example) << "\n";
    std::cout << "Motivation-protection index: " << motivation_protection_index(example) << "\n";

    return 0;
}
