// Behavioral test: core (header-only) Eigen linear algebra. Returns non-zero on
// any mismatch. (The eigen_blas feature's dgemm_ path is covered separately;
// linking feature-built dependency objects into test binaries is a follow-up.)
#include <Eigen/Dense>
#include <cmath>

int main() {
    Eigen::Matrix2d A; A << 1, 2, 3, 4;
    Eigen::Vector2d x(1.0, 1.0);
    Eigen::Vector2d y = A * x;                              // [3,7]
    double det = A.determinant();                          // -2
    Eigen::Vector2d z = A.colPivHouseholderQr().solve(y);  // [1,1]
    bool ok = y(0) == 3.0 && y(1) == 7.0 && det == -2.0
              && std::abs(z(0) - 1.0) < 1e-9 && std::abs(z(1) - 1.0) < 1e-9;
    return ok ? 0 : 1;
}
