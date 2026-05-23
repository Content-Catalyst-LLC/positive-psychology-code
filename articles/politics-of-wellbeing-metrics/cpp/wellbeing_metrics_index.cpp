#include <array>
#include <iostream>

int main() {
    const std::array<double, 9> values = {7.4, 7.3, 6.9, 7.0, 6.8, 7.2, 7.5, 6.9, 3.0};
    const std::array<double, 9> weights = {0.16, 0.14, 0.14, 0.14, 0.10, 0.10, 0.10, 0.08, -0.08};

    double score = 0.0;
    for (std::size_t i = 0; i < values.size(); ++i) {
        score += values[i] * weights[i];
    }

    std::cout << "Public well-being index: " << score << "\n";
    return 0;
}
