#include <array>
#include <iostream>
#include <numeric>

int main() {
    const std::array<double, 9> values = {7.4, 7.8, 7.0, 6.9, 7.2, 7.1, 4.0, 3.0, 6.8};
    const std::array<double, 9> weights = {0.16, 0.14, 0.12, 0.12, 0.14, 0.14, -0.04, -0.04, 0.10};

    double score = 0.0;
    for (std::size_t i = 0; i < values.size(); ++i) {
        score += values[i] * weights[i];
    }

    std::cout << "Sustainable well-being index: " << score << "\n";
    return 0;
}
