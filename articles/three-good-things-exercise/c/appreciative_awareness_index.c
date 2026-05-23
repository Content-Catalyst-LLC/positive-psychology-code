#include <stdio.h>

typedef struct {
    double life_satisfaction;
    double depressive_symptoms;
    double gratitude_score;
    double positive_event_salience;
    double perceived_support;
    double reflection_depth;
    double stress_load;
    double acceptability;
    double context_fit;
} ThreeGoodThingsIndicators;

double appreciative_awareness_index(ThreeGoodThingsIndicators x) {
    return (
        x.gratitude_score +
        x.positive_event_salience +
        x.perceived_support +
        x.reflection_depth +
        x.acceptability +
        x.context_fit -
        x.stress_load
    ) / 7.0;
}

double net_wellbeing_index(ThreeGoodThingsIndicators x) {
    return x.life_satisfaction
         + x.gratitude_score
         + x.positive_event_salience
         + x.perceived_support
         + x.reflection_depth
         - x.depressive_symptoms
         - x.stress_load;
}

int main(void) {
    ThreeGoodThingsIndicators example = {7.4, 3.6, 7.2, 7.1, 7.3, 7.1, 3.2, 7.7, 7.6};
    printf("Appreciative awareness index: %.3f\n", appreciative_awareness_index(example));
    printf("Net wellbeing index: %.3f\n", net_wellbeing_index(example));
    return 0;
}
