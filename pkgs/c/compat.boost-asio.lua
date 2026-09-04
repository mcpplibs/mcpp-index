-- Form B inline descriptor for Boost.Asio 1.92.0 — networking/async I/O as
-- consumed INSIDE the modular-boost header family. This is the boostorg/asio
-- tree (Boost.Asio), NOT the standalone chriskohlhoff.asio package already in
-- this index: Beast 1.92 removed BEAST_USE_STANDALONE_ASIO upstream, so the
-- beast descriptor has no choice but to ride boost.asio (see compat.boost-beast).
--
-- Header-only — the boostorg superproject builds no compiled asio target.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree and cross-checked
-- against the repo's CMakeLists INTERFACE line:
--     asio -> align, assert, config, system, throw_exception
--         (+ context, date_time — both DISABLED, see below)
-- Boost.Align looks surprising on first read but is real: asio/detail/memory
-- routes aligned allocations through boost::align::align.
--
-- Two optional Boost libraries are compile-time auto-detected and deliberately
-- switched OFF via the package's default feature (same trick as the
-- standalone chriskohlhoff.asio's ASIO_DISABLE_BOOST_CONTEXT_FIBER):
--
--   * boost.context — spawn()/yield_context stackful coroutines. The fiber
--     detection is compiler-only (clang/gcc >= C++11 ⇒ on), so without the
--     disable define asio/impl/spawn.hpp would #include <boost/context/fiber.hpp>,
--     and Boost.Context is a COMPILED (and assembly) library — packaging it
--     would end this family's header-only property. Beast never calls spawn.
--   * boost.date_time — the legacy deadline_timer. asio/deadline_timer.hpp and
--     time_traits.hpp are guarded by BOOST_ASIO_HAS_BOOST_DATE_TIME, so with
--     the disable define even `#include <boost/asio.hpp>` never reaches
--     boost/date_time. Beast uses steady_timer (std::chrono).
--
-- With both off, the asio surface is the same one the standalone package
-- exposes minus iostream/streambuf quirks: io_context, timers, sockets,
-- buffers, co_spawn/awaitable, ssl (headers — requires an OpenSSL dep the
-- consumer must bring, e.g. compat.openssl; NOT wired here). Handlers run on
-- POSIX threads auto-detected via unistd.h macros; no ldflags needed beyond
-- what the consumer's own profile carries — see chriskohlhoff.asio for the
-- -pthread precedent if a member ever needs it pinned.
--
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-asio",
    description = "Boost.Asio 1.92.0 — networking/async I/O; the boostorg tree consumed by Boost.Beast",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/asio",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/asio/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "9aff35259a81bc08cf7a4498cec06e8e35a645a54b917ae16c3e5884fd260ecb",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/asio/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "9aff35259a81bc08cf7a4498cec06e8e35a645a54b917ae16c3e5884fd260ecb",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/asio/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "9aff35259a81bc08cf7a4498cec06e8e35a645a54b917ae16c3e5884fd260ecb",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        -- Exposes `boost/asio/` (+ boost/asio.hpp) so family consumers'
        -- `#include <boost/asio/buffer.hpp>` resolve.
        include_dirs = { "*/include" },
        -- Header-only: a trivial anchor TU gives mcpp a buildable lib target.
        generated_files = {
            ["mcpp_generated/boost_asio_anchor.cpp"] = [==[
int mcpp_compat_boost_asio_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_asio_anchor.cpp" },
        targets      = { ["boost_asio"] = { kind = "lib" } },
        -- The disable defines ride the package's default feature so they reach
        -- every TU that compiles an asio header — direct consumers here, and
        -- compat.boost-beast consumers through its own identical default
        -- feature (idempotent, same values — see that descriptor).
        features = {
            ["default"]        = { implies = { "no-boost-extras" } },
            ["no-boost-extras"] = {
                defines = {
                    "BOOST_ASIO_DISABLE_BOOST_CONTEXT_FIBER",
                    "BOOST_ASIO_DISABLE_BOOST_DATE_TIME",
                },
            },
        },
        deps         = {
            ["compat.boost-align"]           = "1.92.0",
            ["compat.boost-assert"]          = "1.92.0",
            ["compat.boost-config"]          = "1.92.0",
            ["compat.boost-system"]          = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
        },
    },
}
