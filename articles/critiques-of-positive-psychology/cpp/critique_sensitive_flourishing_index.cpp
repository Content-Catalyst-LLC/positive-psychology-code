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
    const std::array<double, 10> values = {7.4, 7.6, 7.3, 7.5, 7.6, 7.4, 7.3, 7.2, 2.2, 2.8};
    const std::array<double, 10> weights = {0.13, 0.13, 0.10, 0.11, 0.11, 0.11, 0.09, 0.09, -0.08, -0.08};

    std::cout << "Critique-sensitive flourishing index: " << dot_checked(values, weights) << "\n";
    return 0;
}
