#include <iostream>

// Toy flourishing composite score.
// Compile with: g++ cpp/flourishing_score.cpp -o outputs/flourishing_score

int main() {
    double engagement = 0.72;
    double relationships = 0.80;
    double meaning = 0.76;
    double accomplishment = 0.65;
    double health = 0.70;
    double positive_affect = 0.68;
    double stress_load = 0.25;

    double score =
        0.15 * engagement +
        0.20 * relationships +
        0.20 * meaning +
        0.12 * accomplishment +
        0.15 * health +
        0.10 * positive_affect -
        0.12 * stress_load;

    std::cout << "Flourishing score: " << score << "\n";
    return 0;
}
