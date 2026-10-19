package = {
    spec        = "1",
    namespace   = "compat",
    name        = "muduo",
    description = "A reactor-based C++ network library for Linux",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/chenshuo/muduo",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/chenshuo/muduo/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["2.0.3"] = {
                url    = "https://github.com/chenshuo/muduo/archive/refs/tags/v2.0.3.tar.gz",
                sha256 = "5e90c2f07074ed5ab9347959edc8d387e40a57fbffb92e4a99cfb9a230851371",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        -- Frozen upstream uses abort() without declaring it. Recent libc++
        -- no longer provides that declaration through unrelated headers.
        cxxflags     = { "-include", "cstdlib" },
        include_dirs = { "*" },
        sources      = {
            "*/muduo/base/*.cc",
            "*/muduo/net/poller/DefaultPoller.cc",
            "*/muduo/net/poller/EPollPoller.cc",
            "*/muduo/net/poller/PollPoller.cc",
            "*/muduo/net/Acceptor.cc",
            "*/muduo/net/Buffer.cc",
            "*/muduo/net/Channel.cc",
            "*/muduo/net/Connector.cc",
            "*/muduo/net/EventLoop.cc",
            "*/muduo/net/EventLoopThread.cc",
            "*/muduo/net/EventLoopThreadPool.cc",
            "*/muduo/net/InetAddress.cc",
            "*/muduo/net/Poller.cc",
            "*/muduo/net/Socket.cc",
            "*/muduo/net/SocketsOps.cc",
            "*/muduo/net/TcpClient.cc",
            "*/muduo/net/TcpConnection.cc",
            "*/muduo/net/TcpServer.cc",
            "*/muduo/net/Timer.cc",
            "*/muduo/net/TimerQueue.cc",
        },
        targets = {
            ["muduo"] = { kind = "lib" },
        },
        deps = {
            ["compat.boost-circular-buffer"] = "1.92.0",
            ["compat.boost-any"] = "1.92.0",
            ["compat.boost-utility"] = "1.92.0",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

function install()
    local wrap = "muduo-" .. pkginfo.version()
    if not os.isfile(path.join(wrap, "muduo/net/TcpClient.cc")) then
        log.error("compat.muduo: expected %s/muduo/net/TcpClient.cc", wrap)
        return false
    end

    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    local srcroot = path.join(prefix, wrap)
    os.mv(wrap, srcroot)

    -- shared_ptr::unique() was removed in C++20; the upstream C++17 code
    -- uses it before copying connection_. Preserve its exact meaning.
    local source = path.join(srcroot, "muduo/net/TcpClient.cc")
    local content = io.readfile(source)
    local patched, count = content:gsub("connection_%.unique%(%);", "connection_.use_count() == 1;")
    if count ~= 1 then
        log.error("compat.muduo: expected exactly one shared_ptr::unique() call, got %d", count)
        return false
    end
    io.writefile(source, patched)
    -- sys/time.h does not promise the definition of struct tm. Clang's
    -- Linux sysroot needs the explicit time.h include for gmtime_r().
    source = path.join(srcroot, "muduo/base/Timestamp.cc")
    content = io.readfile(source)
    patched, count = content:gsub("#include <sys/time%.h>\n", "#include <sys/time.h>\n#include <time.h>\n")
    if count ~= 1 then
        log.error("compat.muduo: expected exactly one sys/time.h include, got %d", count)
        return false
    end
    io.writefile(source, patched)
    return true
end
