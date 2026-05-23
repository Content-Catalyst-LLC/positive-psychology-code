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
    const std::array<double, 11> values = {7.4, 7.6, 7.3, 7.2, 7.5, 7.4, 7.6, 7.3, 7.1, 7.3, 3.0};
    const std::array<double, 11> weights = {0.11, 0.12, 0.10, 0.10, 0.11, 0.10, 0.09, 0.10, 0.09, 0.10, -0.10};

    std::cout << "Public health well-being index: " << dot_checked(values, weights) << "\n";
    return 0;
}
