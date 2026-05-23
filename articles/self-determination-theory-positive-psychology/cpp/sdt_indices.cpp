#include <iostream>

struct SDTIndicators {
    double autonomy_support;
    double competence_support;
    double relatedness_support;
    double need_frustration;
    double controlling_pressure;
    double autonomous_motivation;
    double controlled_motivation;
    double internalization;
    double wellbeing_score;
    double vitality;
    double stress_load;
    double climate_quality;
};

double need_support_index(const SDTIndicators& x) {
    return (x.autonomy_support + x.competence_support + x.relatedness_support) / 3.0;
}

double need_balance_index(const SDTIndicators& x) {
    return need_support_index(x) - x.need_frustration - x.controlling_pressure;
}

double motivational_quality_index(const SDTIndicators& x) {
    return x.autonomous_motivation + x.internalization - x.controlled_motivation;
}

double net_sdt_wellbeing_index(const SDTIndicators& x) {
    return x.wellbeing_score
         + x.vitality
         + x.autonomous_motivation
         + x.internalization
         + need_support_index(x)
         - x.controlled_motivation
         - x.stress_load
         - x.need_frustration
         - x.controlling_pressure;
}

int main() {
    SDTIndicators example{7.4, 7.3, 7.5, 2.0, 2.4, 7.3, 2.8, 6.9, 7.4, 7.3, 2.9, 7.6};

    std::cout << "Need support index: " << need_support_index(example) << "\n";
    std::cout << "Need balance index: " << need_balance_index(example) << "\n";
    std::cout << "Motivational quality index: " << motivational_quality_index(example) << "\n";
    std::cout << "Net SDT wellbeing index: " << net_sdt_wellbeing_index(example) << "\n";

    return 0;
}
