#include <omp.h>

int main() {
    int values[] = {1, 2, 3, 4};
#pragma omp simd
    for (int i = 0; i < 4; ++i) values[i] *= 2;

    return values[0] == 2 && values[3] == 8 && _OPENMP > 0 ? 0 : 1;
}
