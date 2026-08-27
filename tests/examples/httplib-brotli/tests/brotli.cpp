#ifndef CPPHTTPLIB_BROTLI_SUPPORT
#error "compat.httplib[brotli] must define CPPHTTPLIB_BROTLI_SUPPORT in consumers"
#endif

#define MCPP_HTTPLIB_FEATURE_NAME "brotli"
#define MCPP_HTTPLIB_ENCODING "br"
#include "../../../fixtures/httplib_compression_case.hpp"
