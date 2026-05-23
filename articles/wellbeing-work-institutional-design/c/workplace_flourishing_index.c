#include <stdio.h>

typedef struct {
    double autonomy;
    double competence;
    double relatedness;
    double meaning;
    double safety;
    double supervisor_support;
    double recovery;
    double overload;
    double insecurity;
} WorkplaceIndicators;

double workplace_flourishing_index(WorkplaceIndicators x) {
    return 0.15 * x.autonomy
         + 0.14 * x.competence
         + 0.14 * x.relatedness
         + 0.14 * x.meaning
         + 0.14 * x.safety
         + 0.10 * x.supervisor_support
         + 0.09 * x.recovery
         - 0.05 * x.overload
         - 0.05 * x.insecurity;
}

int main(void) {
    WorkplaceIndicators example = {7.4, 7.2, 7.0, 7.6, 7.1, 7.3, 6.8, 3.5, 2.8};
    printf("Workplace flourishing index: %.3f\n", workplace_flourishing_index(example));
    return 0;
}
