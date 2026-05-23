#include <stdio.h>

typedef struct {
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
} HelplessnessIndicators;

double helplessness_index(HelplessnessIndicators x) {
    return (x.stability_score + x.globality_score + x.internality_score) / 3.0;
}

double control_gap(HelplessnessIndicators x) {
    return x.perceived_control - x.uncontrollable_events;
}

double agency_recovery_index(HelplessnessIndicators x) {
    return x.agency_score + x.support_score + x.mastery_experience + x.recovery_opportunity +
           x.feedback_quality + x.institutional_fairness -
           x.uncontrollable_events - helplessness_index(x);
}

double motivation_protection_index(HelplessnessIndicators x) {
    return x.motivation_score + x.perceived_control + x.agency_score + x.support_score +
           x.mastery_experience + x.feedback_quality + x.institutional_fairness -
           x.uncontrollable_events - helplessness_index(x) - x.depressive_symptoms;
}

int main(void) {
    HelplessnessIndicators example = {6.7, 4.0, 3.6, 3.5, 3.7, 6.6, 3.9, 6.7, 6.9, 6.6, 6.7, 6.9, 6.8};

    printf("Helplessness index: %.3f\n", helplessness_index(example));
    printf("Control gap: %.3f\n", control_gap(example));
    printf("Agency-recovery index: %.3f\n", agency_recovery_index(example));
    printf("Motivation-protection index: %.3f\n", motivation_protection_index(example));

    return 0;
}
