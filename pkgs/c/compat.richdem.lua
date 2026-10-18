-- Form B inline descriptor for RichDEM, a C++ library for high-performance
-- terrain analysis.
--
-- Serial core build: GDAL, Boost serialization and OpenMP are disabled.
-- GDAL needs a define, headers and a runtime dependency, so a sources-only
-- feature cannot enable it correctly. Do not advertise an inert gdal feature.
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
        deps = {},
    },
}
