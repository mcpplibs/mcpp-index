// Portable: on Windows the cfg-gated openblas dep + HAVE_OPENBLAS are active and
// this calls cblas_dgemm (asserting [19 22; 43 50]); elsewhere it is a no-op.
#ifdef HAVE_OPENBLAS
#include <cblas.h>
int main() {
    const double A[4] = {1, 2, 3, 4};
    const double B[4] = {5, 6, 7, 8};
    double C[4] = {0, 0, 0, 0};
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, 2, 2, 2, 1.0, A, 2, B, 2, 0.0, C, 2);
    const double expected[4] = {19, 22, 43, 50};
    for (int i = 0; i < 4; ++i) if (C[i] != expected[i]) return 10 + i;
    return 0;
}
#else
int main() { return 0; }  // openblas is Windows-only; no-op elsewhere
#endif
