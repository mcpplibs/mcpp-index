/* The interface of libtwice.okso, an image this member builds and binds. */
#ifndef TWICE_H
#define TWICE_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef int64_t (*twice_map)(int64_t value);
int64_t twice(int64_t value);
int64_t twice_apply(twice_map map, int64_t value);
#ifdef __cplusplus
}
#endif
#endif
