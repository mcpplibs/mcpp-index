-- Form B inline descriptor for Boost.Beast 1.92.0 — HTTP and WebSocket
-- networking built on Asio, the largest member of this index's modular-boost
-- header family so far. Header-only (upstream's CMake target is INTERFACE;
-- beast/zlib is a bundled inflate/deflate port, no external zlib; beast/ssl
-- is NOT part of boost/beast.hpp's aggregate — using it needs an OpenSSL dep
-- the consumer must bring, e.g. compat.openssl).
--
-- Why boost.asio and not the standalone chriskohlhoff.asio already in this
-- index: upstream removed BEAST_USE_STANDALONE_ASIO around Boost 1.87 — the
-- 1.92 tree hardwires boost/system + boost/asio (beast/core/error.hpp aliases
-- error_code to boost::system::error_code unconditionally), and grepping the
-- whole include tree for "STANDALONE" comes up empty. So this package rides
-- the boost.asio family member, which carries its own default-feature defines
-- disabling the boost.context/boost.date_time optional surface.
--
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Dependency closure verified by
-- grepping every `<boost/...>` include across the include tree (both
-- `#include` and `# include` spellings) and cross-checked against the repo's
-- CMakeLists BOOST_BEAST_DEPENDENCIES line — the two agree exactly, 19 libs,
-- of which four were already in this index (assert, config, throw-exception,
-- type-traits):
--     beast -> asio, assert, bind, config, container, container_hash, core,
--              endian, intrusive, logic, mp11, optional, smart_ptr,
--              static_string, system, throw_exception, type_index,
--              type_traits, winapi
-- winapi enters through beast/core/file_win32 (Windows-only paths) and
-- boost/system; the headers are inert on POSIX, so the dep is declared on all
-- three platforms like the rest of the family. type_index is reached via the
-- single-file boost/type_index.hpp shims (a dir-only grep would miss it —
-- that mistake cost the first draft of this closure a dependency).
--
-- The default feature re-states boost-asio's three runtime defines (the two
-- optional-boost disables plus BOOST_ASIO_HAS_THREADS, which feeds
-- BOOST_ASIO_VERSION_TAG): feature defines propagate to direct consumers, and
-- restating them here keeps a beast consumer's TUs consistent even if
-- transitive propagation through an intermediate package ever changes. Same
-- values on both sides = idempotent.
--
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-beast",
    description = "Boost.Beast 1.92.0 — HTTP and WebSocket networking on Boost.Asio (header-only)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/beast",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/beast/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "de6f1308125438d238d7d53d2b9be8eddc11db17977baf87e2a2e7fc1dd9ea29",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/beast/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "de6f1308125438d238d7d53d2b9be8eddc11db17977baf87e2a2e7fc1dd9ea29",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/beast/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "de6f1308125438d238d7d53d2b9be8eddc11db17977baf87e2a2e7fc1dd9ea29",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        -- Exposes boost/beast.hpp + boost/beast/* for `#include
        -- <boost/beast.hpp>`-style consumption.
        include_dirs = { "*/include" },
        -- Header-only: a trivial anchor TU gives mcpp a buildable lib target.
        generated_files = {
            ["mcpp_generated/boost_beast_anchor.cpp"] = [==[
int mcpp_compat_boost_beast_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_beast_anchor.cpp" },
        targets      = { ["boost_beast"] = { kind = "lib" } },
        features = {
            ["default"]     = { implies = { "asio-config" } },
            ["asio-config"] = {
                defines = {
                    "BOOST_ASIO_DISABLE_BOOST_CONTEXT_FIBER",
                    "BOOST_ASIO_DISABLE_BOOST_DATE_TIME",
                    "BOOST_ASIO_HAS_THREADS",
                },
            },
        },
        deps         = {
            ["compat.boost-asio"]            = "1.92.0",
            ["compat.boost-assert"]          = "1.92.0",
            ["compat.boost-bind"]            = "1.92.0",
            ["compat.boost-config"]          = "1.92.0",
            ["compat.boost-container"]       = "1.92.0",
            ["compat.boost-container-hash"]  = "1.92.0",
            ["compat.boost-core"]            = "1.92.0",
            ["compat.boost-endian"]          = "1.92.0",
            ["compat.boost-intrusive"]       = "1.92.0",
            ["compat.boost-logic"]           = "1.92.0",
            ["compat.boost-mp11"]            = "1.92.0",
            ["compat.boost-optional"]        = "1.92.0",
            ["compat.boost-smart-ptr"]       = "1.92.0",
            ["compat.boost-static-string"]   = "1.92.0",
            ["compat.boost-system"]          = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
            ["compat.boost-type-index"]      = "1.92.0",
            ["compat.boost-type-traits"]     = "1.92.0",
            ["compat.boost-winapi"]          = "1.92.0",
        },
    },
}
