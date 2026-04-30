#include <stdio.h>

// Toy motivation function.
// Compile with: cc c/motivation_function.c -o outputs/motivation_function

double motivation(double expectancy, double value, double pathways) {
    return expectancy * value * pathways;
}

int main(void) {
    double score = motivation(0.75, 0.90, 0.65);
    printf("Motivation score: %.3f\n", score);
    return 0;
}
