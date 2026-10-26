local versions = {
    ["12.1.0"] = {
        url = "https://github.com/machinezone/IXWebSocket/archive/refs/tags/v12.1.0.tar.gz",
        sha256 = "55f3a5d3a1a2c5f19d737c24e6aced28d1200f8f5deb45ecd8e5d46f765b5288",
    },
}

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
-- ZERO external dependencies by default, with the optional TLS, zlib and
-- server features below all turned off:
--
--   * No IXWEBSOCKET_USE_TLS — the TLS socket TUs (OpenSSL / MbedTLS /
--     AppleSSL) are not compiled and the public headers that reach consumers
--     never include them; IXSocketFactory.cpp only pulls the TLS headers under
--     `#ifdef IXWEBSOCKET_USE_TLS`. The opt-in `tls` feature consistently uses
--     OpenSSL across Linux, macOS and Windows through compat.openssl.
--   * No IXWEBSOCKET_USE_ZLIB — IXGzipCodec.cpp and the per-message-deflate
--     codec guard every zlib call behind that macro, so they compile to
--     pass-through no-ops. Per-message-deflate negotiation is then inert on
--     the wire (clients offer no compression extension), which is exactly the
--     conservative default.
--   * No server feature — the base is a client-only library; the optional
--     `server` feature adds the four upstream server translation units.
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

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/machinezone/IXWebSocket/archive/refs/tags/${tag}.tar.gz",
        },
    },

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
            ["12.1.0"] = versions["12.1.0"],
        },
        macosx = {
            ["12.0.1"] = {
                url    = "https://github.com/machinezone/IXWebSocket/archive/refs/tags/v12.0.1.tar.gz",
                sha256 = "d23bdc91dbfe2b9ae13c322d539392d7a6b8b506560f41c90e227fa0f86a2405",
            },
            ["12.1.0"] = versions["12.1.0"],
        },
        windows = {
            ["12.0.1"] = {
                url    = "https://github.com/machinezone/IXWebSocket/archive/refs/tags/v12.0.1.tar.gz",
                sha256 = "d23bdc91dbfe2b9ae13c322d539392d7a6b8b506560f41c90e227fa0f86a2405",
            },
            ["12.1.0"] = versions["12.1.0"],
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
        -- The base build is the zero-dependency client above; three components
        -- can be enabled on top. mcpp features only ADD, so a consumer naming
        -- one keeps everything else:
        --
        --   websocket = "12.0.1"                                   -> ws:// client only
        --   websocket = { …, features = ["tls"] }                   -> + wss:// via OpenSSL
        --   websocket = { …, features = ["server"] }                -> + the server (implies zlib)
        --   websocket = { …, features = ["zlib"] }                  -> + compression
        --   websocket = { …, features = ["tls", "server", "zlib"] } -> all three
        --
        -- `tls` is deliberately independent: TLS is client transport support,
        -- while server and compression are separately useful choices. IXSocket-
        -- Factory.cpp is already in the base sources and switches to
        -- SocketOpenSSL only when BOTH definitions below are set; this feature
        -- adds the one OpenSSL backend TU upstream CMake adds for USE_OPEN_SSL.
        -- compat.openssl is source-built/static across all declared platforms,
        -- so the consumer never falls through to a host libssl.
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
            ["tls"] = {
                -- CMake USE_TLS + USE_OPEN_SSL: IXSocketFactory.cpp selects
                -- SocketOpenSSL and this is its one optional source.
                defines = { "IXWEBSOCKET_USE_TLS=1", "IXWEBSOCKET_USE_OPEN_SSL=1" },
                sources = { "*/ixwebsocket/IXSocketOpenSSL.cpp" },
                deps    = { ["compat.openssl"] = "3.5.1" },
            },
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
        -- _CRT_SECURE_NO_WARNINGS on Windows. `tls` compiles
        -- IXSocketOpenSSL.cpp, which includes shlwapi's PathMatchSpecA; keep
        -- that system import library unconditional on Windows because mcpp's
        -- feature shape has no platform-local ldflags and it is harmless for
        -- the default ws:// build.
        linux = {
            ldflags = { "-lpthread" },
        },
        macosx = {
            ldflags = { "-lpthread" },
        },
        windows = {
            cxxflags = { "-D_CRT_SECURE_NO_WARNINGS" },
            ldflags  = { "-lws2_32", "-lwsock32", "-lshlwapi" },
        },
    },
}
