#include <array>
#include <iostream>

int main() {
    const std::array<double, 9> values = {7.4, 7.2, 7.0, 7.6, 7.1, 7.3, 6.8, 3.5, 2.8};
    const std::array<double, 9> weights = {0.15, 0.14, 0.14, 0.14, 0.14, 0.10, 0.09, -0.05, -0.05};

    double score = 0.0;
    for (std::size_t i = 0; i < values.size(); ++i) {
        score += values[i] * weights[i];
    }

    std::cout << "Workplace flourishing index: " << score << "\n";
    return 0;
}
