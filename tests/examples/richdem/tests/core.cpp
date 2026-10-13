#include <richdem/common/Array2D.hpp>
#include <richdem/common/random.hpp>
#include <richdem/depressions/depressions.hpp>

int main() {
    richdem::Array2D<double> dem(3, 3, 5.0);
    dem(1, 1) = 1.0;
    richdem::FillDepressions<richdem::Topology::D8>(dem);
    if (dem(1, 1) != 5.0 || dem(0, 0) != 5.0) return 1;

    richdem::seed_rand(1);
    const auto state = richdem::SaveRandomState();
    const int first = richdem::uniform_rand_int(1, 10);
    richdem::SetRandomState(state);
    return first >= 1 && first <= 10 &&
           richdem::uniform_rand_int(1, 10) == first ? 0 : 2;
}
