#include <omp.h>

#ifndef _OPENMP
#error "The compiler must enable OpenMP; a header cannot supply _OPENMP."
#endif

int main() {
    omp_set_dynamic(0);
    int sum = 0;
    int threads = 0;
#pragma omp parallel num_threads(2) reduction(+:sum)
    {
#pragma omp single
        threads = omp_get_num_threads();
        sum += omp_get_thread_num() + 1;
    }
    return threads == 2 && sum == 3 ? 0 : 1;
}
