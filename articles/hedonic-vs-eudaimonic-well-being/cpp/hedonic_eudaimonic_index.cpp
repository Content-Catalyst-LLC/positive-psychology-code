#include <array>
#include <iostream>

double mean_eudaimonic(const std::array<double, 6>& values) {
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
    const std::array<double, 6> eudaimonic = {7.3, 7.4, 7.5, 7.7, 7.4, 7.3};
    const double contextual_support = 7.5;
    const double stress_load = 2.8;

    const double hedonic = life_satisfaction + positive_affect - negative_affect;
    const double eud = mean_eudaimonic(eudaimonic);
    const double integrated = 0.40 * hedonic + 0.45 * eud + 0.20 * contextual_support - 0.20 * stress_load;

    std::cout << "Hedonic index: " << hedonic << "\n";
    std::cout << "Eudaimonic index: " << eud << "\n";
    std::cout << "Integrated flourishing index: " << integrated << "\n";

    return 0;
}
