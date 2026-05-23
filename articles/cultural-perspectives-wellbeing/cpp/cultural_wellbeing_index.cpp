#include <array>
#include <iostream>

double dot_checked(const std::array<double, 10>& values, const std::array<double, 10>& weights) {
    double score = 0.0;
    for (std::size_t i = 0; i < values.size(); ++i) {
        score += values[i] * weights[i];
    }
    return score;
}

int main() {
    const std::array<double, 10> values = {6.9, 7.0, 7.4, 6.7, 6.5, 6.4, 7.4, 7.0, 6.0, 7.8};
    const std::array<double, 10> weights = {0.12, 0.11, 0.12, 0.10, 0.10, 0.09, 0.12, 0.12, 0.06, 0.06};

    std::cout << "Cultural well-being index: " << dot_checked(values, weights) << "\n";
    return 0;
}
