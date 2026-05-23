#include <iostream>
#include <numeric>
#include <vector>

static double mean(const std::vector<double>& values) {
    return std::accumulate(values.begin(), values.end(), 0.0) / values.size();
}

int main() {
    std::vector<double> virtues = {4.2, 3.8, 4.4, 4.1, 3.7, 4.0};
    std::vector<double> flourishing = {4.1, 4.3, 3.9, 4.0};

    std::cout << "Mean virtue-domain score: " << mean(virtues) << std::endl;
    std::cout << "Mean flourishing score: " << mean(flourishing) << std::endl;
    return 0;
}
