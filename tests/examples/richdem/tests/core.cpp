#include <richdem/common/constants.hpp>
#include <richdem/common/random.hpp>

int main() {
    richdem::seed_rand(1);
    const auto value = richdem::uniform_rand_int(1, 10);
    return value >= 1 && value <= 10 ? 0 : 1;
}
