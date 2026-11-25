-- compat.thorvg — ThorVG 1.1.3 CPU software rasterizer + Lottie loader (static, MIT).
--
-- Form B source-built package targeting ThorVG's CPU engine + raw + Lottie
-- loader subset (40 translation units). Both `src/renderer/cpu_engine/tvgSwRasterSimd.cpp`
-- (architecture-specific AVX2/NEON intrinsics) and `src/loaders/lottie/jerryscript/**`
-- (optional JS expression engine) are explicitly excluded.
--
-- Configuration header (`mcpp_generated/config.h`) defines:
--   THORVG_VERSION_STRING "1.1.3"
--   THORVG_CPU_ENGINE_SUPPORT 1
--   THORVG_LOTTIE_LOADER_SUPPORT 1
--
-- `inc/thorvg.h` decorates public APIs with `__declspec(dllimport)` on Windows
-- unless `TVG_STATIC` is defined, so `TVG_STATIC` must reach both ThorVG's
-- own translation units and every consumer. Base-level `defines` is private
-- to the package's own units, whereas an active feature's `defines` reaches
-- both package units and downstream consumers; `default` implies `staticlib`
-- unconditionally (the `compat.curl` / `compat.xz` / `compat.fribidi` pattern).
--
-- Internal source directories and `mcpp_generated` are declared in BOTH
-- `include_dirs` and `private_include_dirs` inside each platform block
-- (`linux`, `macosx`, `windows`) because base-level `private_include_dirs` is
-- inert; consumers see only `*/inc` (`<thorvg.h>`).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "thorvg",
    description = "ThorVG 1.1.3 — vector graphics and Lottie rendering engine (CPU rasterizer + Lottie loader), MIT",
    licenses    = { "MIT" },
    repo        = "https://github.com/thorvg/thorvg",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/thorvg/thorvg/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.1.3"] = {
                url    = "https://github.com/thorvg/thorvg/archive/refs/tags/v1.1.3.tar.gz",
                sha256 = "ba9957aeeadb4151d4486f11c638ae118c00210fa4906daa7b30143aa341e690",
            },
        },
        macosx = {
            ["1.1.3"] = {
                url    = "https://github.com/thorvg/thorvg/archive/refs/tags/v1.1.3.tar.gz",
                sha256 = "ba9957aeeadb4151d4486f11c638ae118c00210fa4906daa7b30143aa341e690",
            },
        },
        windows = {
            ["1.1.3"] = {
                url    = "https://github.com/thorvg/thorvg/archive/refs/tags/v1.1.3.tar.gz",
                sha256 = "ba9957aeeadb4151d4486f11c638ae118c00210fa4906daa7b30143aa341e690",
            },
        },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        license_files = { "*/LICENSE" },
        include_dirs  = { "*/inc" },
        features      = {
            ["default"]   = { implies = { "staticlib" } },
            ["staticlib"] = { defines = { "TVG_STATIC" } },
        },

        generated_files = {
            ["mcpp_generated/config.h"] = "#pragma once\n\n#define THORVG_VERSION_STRING \"1.1.3\"\n#define THORVG_CPU_ENGINE_SUPPORT 1\n#define THORVG_LOTTIE_LOADER_SUPPORT 1\n",
        },

        sources = {
            -- src/common (3 TUs)
            "*/src/common/tvgCompressor.cpp",
            "*/src/common/tvgMath.cpp",
            "*/src/common/tvgStr.cpp",

            -- src/renderer (14 TUs)
            "*/src/renderer/tvgAccessor.cpp",
            "*/src/renderer/tvgAnimation.cpp",
            "*/src/renderer/tvgCanvas.cpp",
            "*/src/renderer/tvgFill.cpp",
            "*/src/renderer/tvgInitializer.cpp",
            "*/src/renderer/tvgLoaderMgr.cpp",
            "*/src/renderer/tvgPaint.cpp",
            "*/src/renderer/tvgPicture.cpp",
            "*/src/renderer/tvgRender.cpp",
            "*/src/renderer/tvgSaver.cpp",
            "*/src/renderer/tvgScene.cpp",
            "*/src/renderer/tvgShape.cpp",
            "*/src/renderer/tvgTaskScheduler.cpp",
            "*/src/renderer/tvgText.cpp",

            -- src/renderer/cpu_engine (12 TUs; excludes tvgSwRasterSimd.cpp)
            "*/src/renderer/cpu_engine/tvgSwBlendOp.cpp",
            "*/src/renderer/cpu_engine/tvgSwFill.cpp",
            "*/src/renderer/cpu_engine/tvgSwImage.cpp",
            "*/src/renderer/cpu_engine/tvgSwMemPool.cpp",
            "*/src/renderer/cpu_engine/tvgSwPostEffect.cpp",
            "*/src/renderer/cpu_engine/tvgSwRaster.cpp",
            "*/src/renderer/cpu_engine/tvgSwRasterCore.cpp",
            "*/src/renderer/cpu_engine/tvgSwRenderer.cpp",
            "*/src/renderer/cpu_engine/tvgSwRle.cpp",
            "*/src/renderer/cpu_engine/tvgSwShape.cpp",
            "*/src/renderer/cpu_engine/tvgSwStroke.cpp",
            "*/src/renderer/cpu_engine/tvgSwUtil.cpp",

            -- src/loaders/raw (1 TU)
            "*/src/loaders/raw/tvgRawLoader.cpp",

            -- src/loaders/lottie (10 TUs; excludes jerryscript/**)
            "*/src/loaders/lottie/tvgLottieAnimation.cpp",
            "*/src/loaders/lottie/tvgLottieBuilder.cpp",
            "*/src/loaders/lottie/tvgLottieExpressions.cpp",
            "*/src/loaders/lottie/tvgLottieInterpolator.cpp",
            "*/src/loaders/lottie/tvgLottieLoader.cpp",
            "*/src/loaders/lottie/tvgLottieModel.cpp",
            "*/src/loaders/lottie/tvgLottieModifier.cpp",
            "*/src/loaders/lottie/tvgLottieParser.cpp",
            "*/src/loaders/lottie/tvgLottieParserHandler.cpp",
            "*/src/loaders/lottie/tvgLottieProperty.cpp",
        },

        linux = {
            include_dirs = {
                "mcpp_generated",
                "*/src/common",
                "*/src/renderer",
                "*/src/renderer/cpu_engine",
                "*/src/loaders/raw",
                "*/src/loaders/lottie",
            },
            private_include_dirs = {
                "mcpp_generated",
                "*/src/common",
                "*/src/renderer",
                "*/src/renderer/cpu_engine",
                "*/src/loaders/raw",
                "*/src/loaders/lottie",
            },
            cxxflags = { "-fPIC", "-fvisibility=hidden" },
            ldflags  = { "-lm", "-lpthread" },
        },
        macosx = {
            include_dirs = {
                "mcpp_generated",
                "*/src/common",
                "*/src/renderer",
                "*/src/renderer/cpu_engine",
                "*/src/loaders/raw",
                "*/src/loaders/lottie",
            },
            private_include_dirs = {
                "mcpp_generated",
                "*/src/common",
                "*/src/renderer",
                "*/src/renderer/cpu_engine",
                "*/src/loaders/raw",
                "*/src/loaders/lottie",
            },
            cxxflags = { "-fPIC", "-fvisibility=hidden" },
            ldflags  = { "-lm" },
        },
        windows = {
            include_dirs = {
                "mcpp_generated",
                "*/src/common",
                "*/src/renderer",
                "*/src/renderer/cpu_engine",
                "*/src/loaders/raw",
                "*/src/loaders/lottie",
            },
            private_include_dirs = {
                "mcpp_generated",
                "*/src/common",
                "*/src/renderer",
                "*/src/renderer/cpu_engine",
                "*/src/loaders/raw",
                "*/src/loaders/lottie",
            },
            cxxflags = { "-DNOMINMAX", "-DWIN32_LEAN_AND_MEAN" },
        },

        targets = { thorvg = { kind = "lib" } },
        deps    = {},
    },
}
