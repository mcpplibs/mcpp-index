-- Form B inline descriptor for Eigen — a C++ template library for linear
-- algebra (matrices, vectors, numerical solvers, related algorithms). The
-- Eigen *core* is HEADER-ONLY: there is nothing to compile for normal use, so
-- the package exposes the source tree's root on the include path
-- (`#include <Eigen/Dense>` etc.) and carries a tiny anchor translation unit
-- so mcpp always has a buildable `lib` target (same shape as compat.opengl /
-- compat.khrplatform). The optional `blas` feature additionally compiles
-- Eigen's reference BLAS into that lib (see below).
--
-- `include_dirs = {"*"}` points at the tarball root (`eigen-<ver>/`), which is
-- exactly the directory upstream tells you to put on the include path. That
-- makes BOTH the stable modules under `Eigen/` and the experimental modules
-- under `unsupported/Eigen/` (Tensor, AutoDiff, Splines, MatrixFunctions, …)
-- resolvable out of the box.
--
-- Features (Feature System v2, requires mcpp >= 0.0.69). The two BLAS stories
-- run on ORTHOGONAL axes — do not confuse them:
--
--   `eigen_blas` — Eigen AS a BLAS provider.
--     Eigen ships a full BLAS library under `blas/` (the `eigen_blas` target in
--     upstream CMake). It builds from pure C++ (`blas/*.cpp`) + f2c-translated
--     C (`blas/f2c/*.c`) — NO Fortran compiler is needed (the only `.f` files
--     live under `blas/testing/`, not the library). Sources-only gate (excluded
--     by default; compiled into the `eigen` lib when requested). It exposes the
--     standard BLAS symbols (sgemm_/dgemm_/… , Fortran ABI) for code that wants
--     to link a BLAS — so it also `provides = ["blas"]` as a capability. Common.h
--     pulls Eigen via a path RELATIVE to blas/ (`../Eigen/Core`), so the sources
--     compile in place under the unpacked tree.
--
--   `use_blas` / `use_lapacke` — Eigen CONSUMING an external BLAS/LAPACK.
--     These flip Eigen's own kernels to delegate to an external implementation.
--     Each contributes the package-owned define (EIGEN_USE_BLAS / EIGEN_USE_LAPACKE)
--     and `requires` the abstract `blas` / `lapack` capability; the resolver binds
--     one provider from the graph (the `eigen_blas` feature above can satisfy it,
--     or a dedicated provider such as a future compat.openblas). Pick the provider
--     with `[capabilities] blas = "<provider>"` or `--cap blas=<provider>` when
--     more than one is present.
--
--   `mpl2only` — package-owned define EIGEN_MPL2_ONLY (no capability).
--
-- MUTUAL EXCLUSION: `eigen_blas` and `use_blas` are OPPOSITE roles and must NOT
-- be enabled together. `eigen_blas` compiles Eigen's own BLAS implementation;
-- `use_blas` defines EIGEN_USE_BLAS, which flips Eigen's headers into "delegate
-- to an EXTERNAL BLAS" mode. Compiling Eigen's own BLAS sources in that mode is
-- self-contradictory: the `blas/*_impl.h` dispatch tables (functype expects the
-- native `const Scalar&`) no longer match the now-by-value BLAS-backend `run`
-- signatures → `invalid conversion ... [-fpermissive]` on level2/level3_impl.h.
-- Verified on mcpp 0.0.69: a blas TU compiles cleanly WITHOUT -DEIGEN_USE_BLAS
-- and fails WITH it. So:
--   * use `eigen_blas` ALONE to get a BLAS library OUT of Eigen, or
--   * use `use_blas` paired with a SEPARATE `blas` provider (a future
--     compat.openblas) to feed an external BLAS INTO Eigen — never both.
-- The header-only path and the `use_blas`/`mpl2only` DEFINES themselves are
-- proven on 0.0.69 (compile_commands.json carries EIGEN_USE_BLAS / EIGEN_MPL2_ONLY;
-- a header-only `mpl2only` consumer builds+runs; `eigen_blas` alone compiles).
--
-- Note: `unsupported/` modules are header-only and live BESIDE `Eigen/` under the
-- same tarball root, so the core include path (`*`) already exposes them; a
-- sources-only gate cannot hide headers, so there is nothing to gate.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*` absorbs
-- the GitLab archive's `eigen-<tag>/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.eigen",
    description = "C++ template library for linear algebra (header-only)",
    licenses    = {"MPL-2.0"},
    repo        = "https://gitlab.com/libeigen/eigen",
    type        = "package",

    xpm = {
        linux = {
            ["5.0.1"] = {
                url    = {
                    GLOBAL = "https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/eigen/releases/download/5.0.1/eigen-5.0.1.tar.gz",
                },
                sha256 = "e9c326dc8c05cd1e044c71f30f1b2e34a6161a3b6ecf445d56b53ff1669e3dec",
            },
        },
        macosx = {
            ["5.0.1"] = {
                url    = {
                    GLOBAL = "https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/eigen/releases/download/5.0.1/eigen-5.0.1.tar.gz",
                },
                sha256 = "e9c326dc8c05cd1e044c71f30f1b2e34a6161a3b6ecf445d56b53ff1669e3dec",
            },
        },
        windows = {
            ["5.0.1"] = {
                url    = {
                    GLOBAL = "https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/eigen/releases/download/5.0.1/eigen-5.0.1.tar.gz",
                },
                sha256 = "e9c326dc8c05cd1e044c71f30f1b2e34a6161a3b6ecf445d56b53ff1669e3dec",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- Tarball root: exposes `Eigen/` (stable) and `unsupported/Eigen/`
        -- (experimental) to consumers writing `#include <Eigen/...>`.
        include_dirs = { "*" },
        -- Header-only: a trivial anchor TU gives mcpp a buildable lib target.
        generated_files = {
            ["mcpp_generated/eigen_anchor.c"] = [==[
int mcpp_compat_eigen_headers_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/eigen_anchor.c" },
        targets      = { ["eigen"] = { kind = "lib" } },
        -- Feature System v2 (mcpp >= 0.0.69). See the header for the
        -- provider-vs-consumer distinction. Old mcpp ignores the `defines`/
        -- `requires`/`provides` keys (skip-unknown), so this recipe still parses
        -- there — only the v2 behaviors are inert.
        features     = {
            -- PROVIDER: compile Eigen's reference BLAS (eigen_blas) into the lib
            -- and advertise the `blas` capability. C++ + f2c-C only, no Fortran.
            -- blas/ has exactly the 5 library .cpp and blas/f2c/ exactly the 18
            -- library .c (the upstream eigen_blas set); the globs match those.
            ["eigen_blas"]  = {
                sources  = { "*/blas/*.cpp", "*/blas/f2c/*.c" },
                provides = { "blas" },
            },
            -- CONSUMER: delegate Eigen's kernels to an external BLAS / LAPACK.
            ["use_blas"]    = { defines = { "EIGEN_USE_BLAS" },    requires = { "blas" } },
            ["use_lapacke"] = { defines = { "EIGEN_USE_LAPACKE" }, requires = { "lapack" } },
            -- BACKEND (Feature System v2, mcpp >= 0.0.72): one-liner that PULLS an
            -- external BLAS provider AND turns on the consumer switch.
            -- `implies use_blas` defines EIGEN_USE_BLAS + requires the `blas`
            -- capability; `deps compat.openblas` pulls the provider that
            -- `provides=["blas"]`, so the resolver binds it automatically. Do NOT
            -- combine with `eigen_blas` (provider vs consumer are exclusive).
            -- Requires mcpp >= 0.0.72: EIGEN_USE_BLAS is an INTERFACE define that
            -- must reach the consumer's TUs (Eigen is header-only) — interface-
            -- define propagation landed in 0.0.72. On 0.0.71 the dep is still
            -- pulled and linked, but Eigen keeps its built-in GEMM in the consumer.
            ["backend-openblas"] = {
                implies = { "use_blas" },
                deps    = { ["compat.openblas"] = "0.3.33" },
            },
            -- Pure package-owned define knob.
            ["mpl2only"]    = { defines = { "EIGEN_MPL2_ONLY" } },
        },
        deps         = { },
    },
}
