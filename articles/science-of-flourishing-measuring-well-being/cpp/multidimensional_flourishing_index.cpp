#include <array>
#include <iostream>

double mean(const std::array<double, 3>& values) {
    double total = 0.0;
    for (double value : values) {
        total += value;
    }
    return total / values.size();
}

int main() {
    const double life_satisfaction = 7.6;
    const double positive_affect = 7.4;
    const double negative_affect = 2.5;
    const std::array<double, 3> eudaimonic = {7.5, 7.4, 7.3};
    const double positive_relations = 7.7;
    const double accomplishment = 7.4;
    const double health_index = 7.5;
    const double contextual_support = 7.5;
    const double stress_load = 2.8;

    const double hedonic = life_satisfaction + positive_affect - negative_affect;
    const double eud = mean(eudaimonic);
    const double integrated =
        0.25 * hedonic +
        0.25 * eud +
        0.15 * positive_relations +
        0.15 * accomplishment +
        0.15 * health_index +
        0.15 * contextual_support -
        0.15 * stress_load;

    std::cout << "Hedonic index: " << hedonic << "\n";
    std::cout << "Eudaimonic index: " << eud << "\n";
    std::cout << "Integrated flourishing index: " << integrated << "\n";

    return 0;
}
