#include <array>
#include <iostream>
#include <stdexcept>

double dot_checked(const std::array<double, 10>& values, const std::array<double, 10>& weights) {
    double score = 0.0;
    for (std::size_t i = 0; i < values.size(); ++i) {
        score += values[i] * weights[i];
    }
    return score;
}

int main() {
    const std::array<double, 10> values = {7.4, 7.6, 7.0, 7.2, 6.9, 7.3, 7.1, 7.0, 6.9, 3.2};
    const std::array<double, 10> weights = {0.13, 0.13, 0.12, 0.12, 0.12, 0.13, 0.10, 0.10, 0.10, -0.05};

    std::cout << "Future well-being index: " << dot_checked(values, weights) << "\n";
    return 0;
}
