-- Form B inline descriptor for RichDEM, a C++ library for high-performance
-- terrain analysis.
--
-- RichDEM's public headers are under include/richdem and its standalone
-- library sources are under src/. GDAL support is optional upstream: enabling
-- the feature matches CMake's USE_GDAL option by defining USEGDAL and adding
-- the GDAL implementation source. Consumers enabling that feature must also
-- provide GDAL headers and the GDAL library in their environment.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "richdem",
    description = "High-performance terrain analysis library",
    licenses    = {"MIT"},
    repo        = "https://github.com/r-barnes/richdem",
    type        = "package",

    xpm = {
        linux = {
            ["2.2.11"] = {
                url    = "https://github.com/r-barnes/richdem/archive/9a1c97bb2529e386451a7dd54768b8b74bb4d620.tar.gz",
                sha256 = "bfa98d00d1d1f3529b2efc6907c9977e65a3c3071f46e24f468fa0db0dc6118b",
            },
        },
        macosx = {
            ["2.2.11"] = {
                url    = "https://github.com/r-barnes/richdem/archive/9a1c97bb2529e386451a7dd54768b8b74bb4d620.tar.gz",
                sha256 = "bfa98d00d1d1f3529b2efc6907c9977e65a3c3071f46e24f468fa0db0dc6118b",
            },
        },
        windows = {
            ["2.2.11"] = {
                url    = "https://github.com/r-barnes/richdem/archive/9a1c97bb2529e386451a7dd54768b8b74bb4d620.tar.gz",
                sha256 = "bfa98d00d1d1f3529b2efc6907c9977e65a3c3071f46e24f468fa0db0dc6118b",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        sources      = {
            "*/src/richdem.cpp",
            "*/src/random.cpp",
            "*/src/terrain_generation/terrain_generation.cpp",
            "*/src/terrain_generation/PerlinNoise.cpp",
        },
        targets      = { ["richdem"] = { kind = "lib" } },
        features     = {
            ["gdal"] = {
                defines = { "USEGDAL" },
                sources = { "*/src/gdal.cpp" },
            },
        },
        deps = {},
    },
}
