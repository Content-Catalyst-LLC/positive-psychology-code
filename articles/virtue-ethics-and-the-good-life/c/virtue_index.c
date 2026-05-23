#include <stdio.h>

static double mean(const double values[], int n) {
    double total = 0.0;
    for (int i = 0; i < n; i++) total += values[i];
    return total / n;
}

int main(void) {
    double virtues[] = {4.2, 3.8, 4.4, 4.1, 3.7, 4.0};
    double flourishing[] = {4.1, 4.3, 3.9, 4.0};

    printf("Mean virtue-domain score: %.3f\n", mean(virtues, 6));
    printf("Mean flourishing score: %.3f\n", mean(flourishing, 4));
    return 0;
}
