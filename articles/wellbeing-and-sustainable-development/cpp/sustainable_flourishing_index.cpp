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
    const std::array<double, 10> values = {7.8, 7.7, 7.6, 7.5, 7.7, 7.3, 7.6, 7.4, 7.8, 2.4};
    const std::array<double, 10> weights = {0.11, 0.11, 0.10, 0.11, 0.12, 0.12, 0.11, 0.10, 0.10, -0.08};

    std::cout << "Sustainable flourishing index: " << dot_checked(values, weights) << "\n";
    return 0;
}
