#include <array>
#include <iostream>

double dot_checked(const std::array<double, 11>& values, const std::array<double, 11>& weights) {
    double score = 0.0;
    for (std::size_t i = 0; i < values.size(); ++i) {
        score += values[i] * weights[i];
    }
    return score;
}

int main() {
    const std::array<double, 11> values = {7.6, 7.5, 7.7, 7.6, 7.8, 7.3, 7.4, 7.5, 7.8, 2.4, 2.9};
    const std::array<double, 11> weights = {0.12, 0.12, 0.12, 0.11, 0.11, 0.10, 0.10, 0.10, 0.10, -0.06, -0.06};

    std::cout << "Well-being economy index: " << dot_checked(values, weights) << "\n";
    return 0;
}
