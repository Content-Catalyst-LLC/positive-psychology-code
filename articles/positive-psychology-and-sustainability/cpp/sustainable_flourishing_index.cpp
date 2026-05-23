#include <array>
#include <iostream>

double dot_checked(const std::array<double, 15>& values, const std::array<double, 15>& weights) {
    double score = 0.0;
    for (std::size_t i = 0; i < values.size(); ++i) {
        score += values[i] * weights[i];
    }
    return score;
}

int main() {
    const std::array<double, 15> values = {
        7.4, 7.3, 7.2, 7.3, 7.4, 7.3, 7.5, 7.4,
        7.1, 7.5, 7.2, 7.3, 2.9, 3.0, 2.7
    };

    const std::array<double, 15> weights = {
        0.09, 0.09, 0.08, 0.08, 0.08, 0.07, 0.09, 0.08,
        0.09, 0.08, 0.08, 0.08, -0.06, -0.06, -0.06
    };

    std::cout << "Sustainable flourishing index: " << dot_checked(values, weights) << "\n";
    return 0;
}
