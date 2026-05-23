#include <stdio.h>
#include <math.h>

typedef struct {
    double challenge_level;
    double skill_level;
    double attention_focus;
    double feedback_quality;
    double goal_clarity;
    double task_meaning;
    double autonomy_support;
    double distraction_load;
    double interruption_count;
    double flow_score;
    double performance_score;
    double learning_gain;
    double fatigue_score;
    double recovery_quality;
    double wellbeing_score;
} FlowIndicators;

double balance_index(FlowIndicators x) {
    return -fabs(x.challenge_level - x.skill_level);
}

double attentional_ecology(FlowIndicators x) {
    return x.attention_focus + x.feedback_quality + x.goal_clarity - x.distraction_load - x.interruption_count;
}

double deep_engagement_context(FlowIndicators x) {
    return balance_index(x) + x.attention_focus + x.feedback_quality + x.goal_clarity +
           x.task_meaning + x.autonomy_support - x.distraction_load - x.interruption_count;
}

double sustainable_flow_index(FlowIndicators x) {
    return x.flow_score + x.task_meaning + x.autonomy_support + x.recovery_quality -
           x.fatigue_score - x.distraction_load;
}

int main(void) {
    FlowIndicators example = {7.1, 7.0, 7.3, 7.1, 7.4, 7.4, 7.2, 3.0, 1.0, 7.2, 7.3, 0.39, 3.2, 7.0, 7.2};

    printf("Challenge-skill balance: %.3f\n", balance_index(example));
    printf("Attentional ecology: %.3f\n", attentional_ecology(example));
    printf("Deep engagement context: %.3f\n", deep_engagement_context(example));
    printf("Sustainable flow index: %.3f\n", sustainable_flow_index(example));

    return 0;
}
