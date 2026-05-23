#include <cmath>
#include <iostream>

struct FlowIndicators {
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
};

double balance_index(const FlowIndicators& x) {
    return -std::abs(x.challenge_level - x.skill_level);
}

double attentional_ecology(const FlowIndicators& x) {
    return x.attention_focus + x.feedback_quality + x.goal_clarity - x.distraction_load - x.interruption_count;
}

double deep_engagement_context(const FlowIndicators& x) {
    return balance_index(x) + x.attention_focus + x.feedback_quality + x.goal_clarity +
           x.task_meaning + x.autonomy_support - x.distraction_load - x.interruption_count;
}

double sustainable_flow_index(const FlowIndicators& x) {
    return x.flow_score + x.task_meaning + x.autonomy_support + x.recovery_quality -
           x.fatigue_score - x.distraction_load;
}

int main() {
    FlowIndicators example{7.1, 7.0, 7.3, 7.1, 7.4, 7.4, 7.2, 3.0, 1.0, 7.2, 7.3, 0.39, 3.2, 7.0, 7.2};

    std::cout << "Challenge-skill balance: " << balance_index(example) << "\n";
    std::cout << "Attentional ecology: " << attentional_ecology(example) << "\n";
    std::cout << "Deep engagement context: " << deep_engagement_context(example) << "\n";
    std::cout << "Sustainable flow index: " << sustainable_flow_index(example) << "\n";

    return 0;
}
