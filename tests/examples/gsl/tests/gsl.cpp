#ifdef HAVE_GSL

#include <cmath>
#include <cstdio>

#include <gsl/gsl_blas.h>
#include <gsl/gsl_cblas.h>
#include <gsl/gsl_integration.h>
#include <gsl/gsl_sf_bessel.h>

namespace {

double square(double x, void*) {
    return x * x;
}

} // namespace

int main() {
    if (std::abs(gsl_sf_bessel_J0(0.0) - 1.0) > 1e-12) return 1;

    double result = 0.0;
    double error = 0.0;
    gsl_function function;
    function.function = &square;
    function.params = nullptr;
    gsl_integration_workspace* workspace = gsl_integration_workspace_alloc(100);
    if (!workspace) return 2;
    gsl_integration_qags(&function, 0.0, 1.0, 0.0, 1e-10, 100,
                         workspace, &result, &error);
    gsl_integration_workspace_free(workspace);
    if (std::abs(result - 1.0 / 3.0) > 1e-8 || error > 1e-8) return 2;

    const double left[2] = {1.0, 2.0};
    const double right[2] = {3.0, 4.0};
    const double product = cblas_ddot(2, left, 1, right, 1);
    if (std::abs(product - 11.0) > 1e-12) return 3;

    std::printf("compat.gsl: special functions, integration, and CBLAS ok\n");
    return 0;
}

#else

int main() {
    return 0;
}

#endif
