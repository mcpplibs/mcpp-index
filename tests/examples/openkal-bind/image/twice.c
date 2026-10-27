/* libtwice.okso: freestanding C, built for <arch>-openkal by build.mcpp. */
#include "../include/twice.h"
__attribute__((visibility("default"))) int64_t twice(int64_t value) { return 2 * value; }
__attribute__((visibility("default"))) int64_t twice_apply(twice_map map, int64_t value) { return 2 * map(value); }
