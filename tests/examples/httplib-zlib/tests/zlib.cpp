#ifndef CPPHTTPLIB_ZLIB_SUPPORT
#error "compat.httplib[zlib] must define CPPHTTPLIB_ZLIB_SUPPORT in consumers"
#endif

#define MCPP_HTTPLIB_FEATURE_NAME "zlib"
#define MCPP_HTTPLIB_ENCODING "gzip"
#include "../../../fixtures/httplib_compression_case.hpp"
