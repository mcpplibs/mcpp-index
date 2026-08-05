-- compat.websocket — IXWebSocket, a pure C++ WebSocket client (RFC 6455).
--
-- Header-compat shape (Form B, `import_std = false`): the client TUs are
-- compiled into one lib and the public headers are exposed through
-- `include_dirs`, so a consumer writes `#include <ixwebsocket/IXWebSocket.h>`.
-- Upstream is a flat `ixwebsocket/` directory holding both headers and sources;
-- the whole thing compiles at this index's c++23 floor even though upstream
-- targets C++11 (verified with the CI clang).
--
-- CLIENT-ONLY. Four upstream TUs are the server side and are left out:
-- IXWebSocketServer.cpp, IXWebSocketProxyServer.cpp, IXHttpServer.cpp and
-- IXSocketServer.cpp. Nothing the client compiles references any of them
-- (checked by grepping the included TUs for their class names), so the link
-- stays clean. IXGetFreePort.cpp IS included: it is a standalone utility and
-- part of the client-side lib.
--
-- ZERO external dependencies, all three knobs turned off:
--
--   * No IXWEBSOCKET_USE_TLS — the TLS socket TUs (OpenSSL / MbedTLS /
--     AppleSSL) are not compiled and the public headers that reach consumers
--     never include them; IXSocketFactory.cpp only pulls the TLS headers under
--     `#ifdef IXWEBSOCKET_USE_TLS`.
--   * No IXWEBSOCKET_USE_ZLIB — IXGzipCodec.cpp and the per-message-deflate
--     codec guard every zlib call behind that macro, so they compile to
--     pass-through no-ops. Per-message-deflate negotiation is then inert on
--     the wire (clients offer no compression extension), which is exactly the
--     conservative default.
--   * No server feature — there is no compilable optional component worth
--     gating here; the server side is deliberately not offered.
--
-- The 32 sources below transcribe upstream CMake's `IXWEBSOCKET_SOURCES` minus
-- the four server TUs above. All names are unique within the index, so the
-- flat-obj dir shared across a link (mcpp#233/#240) has no collisions.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/` absorbs
-- the GitHub tarball's `IXWebSocket-12.0.1/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "websocket",
    description = "IXWebSocket — pure C++ WebSocket client (RFC 6455), client-only, zero deps",
    licenses    = {"MIT"},
    repo        = "https://github.com/machinezone/IXWebSocket",
    type        = "package",

    xpm = {
        -- CN mirror not published yet (no mcpp-res write access here);
        -- plain-string url keeps lint green and lets CN users fall back to
        -- upstream, per docs/cn-mirror.md. Flip to { GLOBAL, CN } once a
        -- gitcode release exists — sha256 stays the same.
        linux = {
            ["12.0.1"] = {
                url    = "https://github.com/machinezone/IXWebSocket/archive/refs/tags/v12.0.1.tar.gz",
                sha256 = "d23bdc91dbfe2b9ae13c322d539392d7a6b8b506560f41c90e227fa0f86a2405",
            },
        },
        macosx = {
            ["12.0.1"] = {
                url    = "https://github.com/machinezone/IXWebSocket/archive/refs/tags/v12.0.1.tar.gz",
                sha256 = "d23bdc91dbfe2b9ae13c322d539392d7a6b8b506560f41c90e227fa0f86a2405",
            },
        },
        windows = {
            ["12.0.1"] = {
                url    = "https://github.com/machinezone/IXWebSocket/archive/refs/tags/v12.0.1.tar.gz",
                sha256 = "d23bdc91dbfe2b9ae13c322d539392d7a6b8b506560f41c90e227fa0f86a2405",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,

        -- The verdir root carries `ixwebsocket/` with every header, matching
        -- upstream's install layout (`<includedir>/ixwebsocket/`), so consumers
        -- write `#include <ixwebsocket/IXWebSocket.h>`.
        include_dirs = { "*" },

        -- Upstream CMake `IXWEBSOCKET_SOURCES` minus the server TUs. Only the
        -- first 32 of the 36 are the client; IXWebSocketServer / IXSocketServer
        -- / IXHttpServer / IXWebSocketProxyServer are intentionally absent.
        sources = {
            "*/ixwebsocket/IXBench.cpp",
            "*/ixwebsocket/IXCancellationRequest.cpp",
            "*/ixwebsocket/IXConnectionState.cpp",
            "*/ixwebsocket/IXDNSLookup.cpp",
            "*/ixwebsocket/IXExponentialBackoff.cpp",
            "*/ixwebsocket/IXGetFreePort.cpp",
            "*/ixwebsocket/IXGzipCodec.cpp",
            "*/ixwebsocket/IXHttp.cpp",
            "*/ixwebsocket/IXHttpClient.cpp",
            "*/ixwebsocket/IXNetSystem.cpp",
            "*/ixwebsocket/IXSelectInterrupt.cpp",
            "*/ixwebsocket/IXSelectInterruptFactory.cpp",
            "*/ixwebsocket/IXSelectInterruptPipe.cpp",
            "*/ixwebsocket/IXSelectInterruptEvent.cpp",
            "*/ixwebsocket/IXSetThreadName.cpp",
            "*/ixwebsocket/IXSocket.cpp",
            "*/ixwebsocket/IXSocketConnect.cpp",
            "*/ixwebsocket/IXSocketFactory.cpp",
            "*/ixwebsocket/IXSocketTLSOptions.cpp",
            "*/ixwebsocket/IXStrCaseCompare.cpp",
            "*/ixwebsocket/IXUdpSocket.cpp",
            "*/ixwebsocket/IXUrlParser.cpp",
            "*/ixwebsocket/IXUuid.cpp",
            "*/ixwebsocket/IXUserAgent.cpp",
            "*/ixwebsocket/IXWebSocket.cpp",
            "*/ixwebsocket/IXWebSocketCloseConstants.cpp",
            "*/ixwebsocket/IXWebSocketHandshake.cpp",
            "*/ixwebsocket/IXWebSocketHttpHeaders.cpp",
            "*/ixwebsocket/IXWebSocketPerMessageDeflate.cpp",
            "*/ixwebsocket/IXWebSocketPerMessageDeflateCodec.cpp",
            "*/ixwebsocket/IXWebSocketPerMessageDeflateOptions.cpp",
            "*/ixwebsocket/IXWebSocketTransport.cpp",
        },

        targets = { ["websocket"] = { kind = "lib" } },

        -- ── Optional components ──────────────────────────────────────────
        -- The base build is the zero-dependency client above; two components
        -- can be enabled on top. mcpp features only ADD, so a consumer naming
        -- one keeps everything else:
        --
        --   websocket = "12.0.1"                                   -> client only
        --   websocket = { …, features = ["server"] }                -> + the server (implies zlib)
        --   websocket = { …, features = ["zlib"] }                  -> + compression
        --   websocket = { …, features = ["server", "zlib"] }        -> + both
        --
        -- `server` brings the four TUs the base build leaves out. It needs
        -- nothing external: every IX* header it touches is already compiled
        -- into the client, and its external includes are stdlib only (checked
        -- against the four .cpp files). `IXWebSocketServer` derives from
        -- `SocketServer`, so consumers reach `getPort()` etc. through it.
        --
        -- `server` IMPLIES `zlib`: upstream's server enables permessage-deflate
        -- by default and the transport's extension negotiation is NOT gated on
        -- IXWEBSOCKET_USE_ZLIB (only the gzip codec is). A server built without
        -- the define would offer compression its codec cannot perform, so the
        -- implication keeps every server build capable of what it advertises.
        --
        -- `zlib` turns the gzip codec from its no-op into real
        -- permessage-deflate compression. Only
        -- IXWebSocketPerMessageDeflateCodec.cpp is gated by
        -- IXWEBSOCKET_USE_ZLIB; the negotiation logic in
        -- IXWebSocketPerMessageDeflate.cpp is zlib-free. The define reaches
        -- this package's own TUs — consumers need no define, they just call
        -- enablePerMessageDeflate() on their client (and the server enables it
        -- by default).
        features = {
            ["server"] = {
                implies = { "zlib" },
                sources = {
                    "*/ixwebsocket/IXSocketServer.cpp",
                    "*/ixwebsocket/IXHttpServer.cpp",
                    "*/ixwebsocket/IXWebSocketServer.cpp",
                    "*/ixwebsocket/IXWebSocketProxyServer.cpp",
                },
            },
            ["zlib"] = {
                defines = { "IXWEBSOCKET_USE_ZLIB=1" },
                deps    = { ["compat.zlib"] = "1.3.2" },
            },
        },

        -- ── Platform-specific ──────────────────────────────────────────────
        -- Upstream: Threads::Threads on UNIX, wsock32/ws2_32/shlwapi +
        -- _CRT_SECURE_NO_WARNINGS on Windows. shlwapi is only reached from the
        -- excluded IXSocketOpenSSL.cpp (its PathFileExists helpers), so it is
        -- dropped here; wsock32 is kept alongside ws2_32 exactly as upstream
        -- lists it.
        linux = {
            ldflags = { "-lpthread" },
        },
        macosx = {
            ldflags = { "-lpthread" },
        },
        windows = {
            cxxflags = { "-D_CRT_SECURE_NO_WARNINGS" },
            ldflags  = { "-lws2_32", "-lwsock32" },
        },
    },
}
