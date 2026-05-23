#include <array>
#include <iostream>

int main() {
    const std::array<double, 7> values = {7.4, 7.2, 2.9, 7.0, 6.9, 7.6, 3.4};
    const std::array<double, 7> weights = {0.30, 0.25, -0.25, 0.10, 0.08, 0.10, -0.08};

    double score = 0.0;
    for (std::size_t i = 0; i < values.size(); ++i) {
        score += values[i] * weights[i];
    }

    std::cout << "Subjective well-being index: " << score << "\n";
    return 0;
}
