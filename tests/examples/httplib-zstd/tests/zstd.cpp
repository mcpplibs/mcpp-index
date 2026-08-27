#ifndef CPPHTTPLIB_ZSTD_SUPPORT
#error "compat.httplib[zstd] must define CPPHTTPLIB_ZSTD_SUPPORT in consumers"
#endif

#define MCPP_HTTPLIB_FEATURE_NAME "zstd"
#define MCPP_HTTPLIB_ENCODING "zstd"
#include "../../../fixtures/httplib_compression_case.hpp"
