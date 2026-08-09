-- compat.mysql-connector-cpp -- MySQL Connector/C++ X DevAPI and JDBC.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "mysql-connector-cpp",
    description = "MySQL Connector/C++ X DevAPI and JDBC (static, source-built)",
    licenses    = {"GPL-2.0-only", "Universal-FOSS-exception-1.0"},
    repo        = "https://github.com/mysql/mysql-connector-cpp",
    type        = "package",

    xpm = {
        linux = {
            deps = {
                "compat:libmysqlclient@8.4.6.1",
                "compat:openssl@3.5.1",
                "xim:cmake@latest",
                "xim:make@latest",
            },
            ["26.7.0"] = {
                url = "https://github.com/mysql/mysql-connector-cpp/archive/refs/tags/26.7.0.tar.gz",
                sha256 = "b2299862eefc33fd71c0aac68328305671805fc955e6bd2578ef205c10f98550",
            },
        },
        macosx = {
            deps = {
                "compat:libmysqlclient@8.4.6.1",
                "compat:openssl@3.5.1",
                "xim:cmake@latest",
            },
            ["26.7.0"] = {
                url = "https://github.com/mysql/mysql-connector-cpp/archive/refs/tags/26.7.0.tar.gz",
                sha256 = "b2299862eefc33fd71c0aac68328305671805fc955e6bd2578ef205c10f98550",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        sources      = { "mcpp_mysql_connector_cpp_anchor.c" },
        include_dirs = { "include" },
        targets      = { ["mysql_connector_cpp"] = { kind = "lib" } },
        deps = {
            ["compat.libmysqlclient"] = "8.4.6.1",
            ["compat.openssl"]        = "3.5.1",
        },

        linux = {
            ldflags = {
                "-Llib", "-l:libmysqlcppconnx-static.a",
                "-l:libmysqlcppconn-static.a", "-lresolv",
            },
        },
        macosx = {
            ldflags = {
                "-Llib", "-lmysqlcppconnx-static",
                "-lmysqlcppconn-static", "-lresolv",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")
-- Hook diagnostics: xlings swallows install-hook stdout and log.error, so a
-- failure used to surface only as an empty E_INTERNAL with no build log. This
-- hook writes a step trace + the failing reason to
-- $HOME/.mcpp/registry/data/mcpp_mysql_connector_cpp_build.log, which
-- validate.yml's `find ... -name 'mcpp_*_build.log'` dump tail-prints. It is a
-- no-op outside the xlings runtime (the `path` global is absent there), so the
-- descriptor-executing lint helpers stay green.
local hook_logf
local function hook_log(msg)
    if type(path) ~= "table" then return end
    if not hook_logf then
        local home = os.getenv and os.getenv("HOME") or "/tmp"
        hook_logf = home .. "/.mcpp/registry/data/mcpp_mysql_connector_cpp_build.log"
    end
    local f = io.open(hook_logf, "a")
    if f then
        f:write(os.date("%H:%M:%S") .. " " .. tostring(msg) .. "\n")
        f:close()
    end
end
hook_log("descriptor loaded")

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function resolve_tool(dep, name, fallback)
    local pkg = pkginfo.build_dep(dep)
    if pkg then
        local candidates = {}
        if pkg.bin then candidates[#candidates + 1] = path.join(pkg.bin, name) end
        if pkg.path then
            -- macOS .app bundles (xim cmake ships CMake.app/Contents/bin).
            candidates[#candidates + 1] =
                path.join(pkg.path, name .. ".app", "Contents", "bin", name)
        end
        for _, cand in ipairs(candidates) do
            if os.isfile(cand) then return cand end
        end
    end
    return fallback
end

local function tail_lines(file, count)
    local ok, content = pcall(io.readfile, file)
    if not ok or not content then return "<log unavailable>" end
    local lines = {}
    for line in (tostring(content) .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = line
    end
    return table.concat(lines, "\n", math.max(1, #lines - count + 1), #lines)
end

local function run(step, logf, command)
    -- xlings 的 os.exec 通过返回值报告非零退出；pcall 只负责捕获 Lua 错误。
    local invoked, result, reason, code =
        pcall(os.exec, string.format("bash -c %s", sh_quote(command)))
    if invoked and result then return true end
    local err = invoked and (tostring(reason) .. " " .. tostring(code))
                        or tostring(result)
    local msg = "compat.mysql-connector-cpp: " .. step .. " failed ("
             .. tostring(err) .. ")\n--- last 40 lines of " .. logf .. " ---\n"
             .. tail_lines(logf, 40)
    log.error("%s", msg)
    hook_log(msg)
    return false
end

local function find_source_root()
    local ifile = pkginfo.install_file()
    local roots = {}
    if ifile then roots[#roots + 1] = tostring(ifile):replace(".tar.gz", "") end
    roots[#roots + 1] = "mysql-connector-cpp-" .. pkginfo.version()
    for _, root in ipairs(roots) do
        if os.isfile(path.join(root, "CMakeLists.txt")) then return root end
    end
end

local function find_mysql_source_root(prefix)
    local direct = path.join(prefix, "libmysqlclient-8.4.6.1")
    if os.isfile(path.join(direct, "mcpp.toml")) then return direct end
    for _, manifest in ipairs(os.files(path.join(prefix, "**", "mcpp.toml")) or {}) do
        local root = path.directory(manifest)
        if os.isfile(path.join(root, "include", "mysql.h")) then return root end
    end
end

-- `pkginfo.install_dir` scans only the member-local xpkgs roots; a dependency
-- that was installed into the shared registry cache (e.g. compat.openssl built
-- by the sibling libmysqlclient member and reused here without a member-local
-- copy) is invisible to it and comes back nil. Fall back to the known xpkgs
-- roots before giving up.
local function find_dep_install_dir(dep_name, dep_version)
    local dir = pkginfo.install_dir(dep_name, dep_version)
    if dir then return dir end
    local ns, bare = dep_name:match("^([^:]+):(.+)$")
    if not ns then return nil end
    local store = ns .. "-x-" .. bare
    local pfx = pkginfo.install_dir()
    local roots = {}
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    local home = os.getenv and os.getenv("MCPP_HOME") or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.mcpp" end
    roots[#roots + 1] = path.join(home, "registry/data/xpkgs")
    for _, root in ipairs(roots) do
        local cand = path.join(root, store, dep_version)
        if os.isdir(cand) then return cand end
    end
    return nil
end

local function patch_internal_compression_helper(srcroot)
    local source = path.join(srcroot, "common", "session.cc")
    local content = io.readfile(source)
    local replacement =
        "\nstatic TCPIP_options::compression_algorithm_t get_compression_algorithm(std::string alg)"
    if content:find(replacement, 1, true) then return true end

    local signature =
        "\nTCPIP_options::compression_algorithm_t get_compression_algorithm%(std::string alg%)"
    local patched, count = content:gsub(signature, replacement)
    if count ~= 1 then
        log.error("compat.mysql-connector-cpp: expected one compression helper, found "
                  .. tostring(count))
        return false
    end
    io.writefile(source, patched)
    return true
end

function install()
    hook_log("install() called; install_file=" .. tostring(pkginfo.install_file())
         .. " install_dir=" .. tostring(pkginfo.install_dir())
         .. " deps=" .. tostring(pkginfo.deps_list()))
    local ok, result = pcall(function()
    local srcroot = find_source_root()
    local mysql = find_dep_install_dir("compat:libmysqlclient", "8.4.6.1")
    local openssl = find_dep_install_dir("compat:openssl", "3.5.1")
    hook_log("srcroot=" .. tostring(srcroot) .. " mysql=" .. tostring(mysql)
             .. " openssl=" .. tostring(openssl))
    if not srcroot or not mysql or not openssl then
        local why = "source/dependency prefix not found (srcroot="
                    .. tostring(srcroot) .. " mysql=" .. tostring(mysql)
                    .. " openssl=" .. tostring(openssl) .. ")"
        log.error("compat.mysql-connector-cpp: %s", why)
        hook_log(why)
        return false
    end

    local mysql_src = find_mysql_source_root(mysql)
    hook_log("mysql_src=" .. tostring(mysql_src))
    if not mysql_src then
        log.error("compat.mysql-connector-cpp: libmysqlclient Form A source root not found")
        return false
    end

    local prefix = pkginfo.install_dir()
    local builddir = path.join(srcroot, "mcpp-build")
    local logf = path.join(prefix, "mcpp_mysql_connector_cpp_build.log")
    hook_log("prefix=" .. tostring(prefix) .. " builddir=" .. tostring(builddir)
             .. " logf=" .. tostring(logf))
    os.tryrm(prefix)
    os.mkdir(prefix)
    os.tryrm(builddir)

    -- 此 helper 只在 session.cc 内使用；内部链接避免与 MySQL 8.4
    -- libmysqlclient 中同签名的实现发生静态链接符号冲突。
    if not patch_internal_compression_helper(srcroot) then return false end

    -- Connector/C++ 的配置阶段只要求能找到一个 mysqlclient archive；真正的
    -- libmysqlclient.a 会在最终消费时由 mcpp 的依赖图链接。这里的探测库不安装。
    local mysql_probe = path.join(builddir, "mysqlclient-probe")
    os.mkdir(path.join(mysql_probe, "lib"))
    os.mkdir(path.join(mysql_probe, "include"))
    local probe_src = path.join(mysql_probe, "probe.c")
    local probe_obj = path.join(mysql_probe, "probe.o")
    local probe_lib = path.join(mysql_probe, "lib", "libmysqlclient.a")
    io.writefile(probe_src, "int mcpp_mysqlclient_probe(void) { return 0; }\n")
    local probe_command = string.format(
        "cp -R %s/. %s/ && cp %s/*.h %s/ && "
        .. "cc -c %s -o %s && ar rcs %s %s",
        sh_quote(path.join(mysql_src, "include")),
        sh_quote(path.join(mysql_probe, "include")),
        sh_quote(path.join(mysql_src, "generated")),
        sh_quote(path.join(mysql_probe, "include")),
        sh_quote(probe_src), sh_quote(probe_obj), sh_quote(probe_lib), sh_quote(probe_obj))
    if not run("mysqlclient probe archive", logf,
               probe_command .. " >" .. sh_quote(logf) .. " 2>&1") then
        return false
    end

    local cmake = resolve_tool("xim:cmake", "cmake", "cmake")
    local make = resolve_tool("xim:make", "make", "make")
    local jobs = (os.default_njob and os.default_njob()) or 4
    local clean_env = "env -u CPPFLAGS -u CFLAGS -u CXXFLAGS -u LDFLAGS "
    local compiler = ""
    if os.host() == "macosx" then
        -- Connector 在 project() 前启动 bootstrap CMake；必须通过环境变量
        -- 将最低系统版本同步给 bootstrap 及其后续的内置依赖构建。
        clean_env = clean_env .. "MACOSX_DEPLOYMENT_TARGET=14.0 "
        -- Sanitize PATH: the connector's CMake merge step invokes Apple's
        -- libtool, and a GNU libtool earlier on PATH (conda/homebrew) breaks
        -- the archive merge. cmake/make come from xim by absolute path and
        -- cc/c++ are pinned below, so system-only PATH is safe here.
        local system_path = "/usr/bin:/bin:/usr/sbin:/sbin:" .. (os.getenv("PATH") or "")
        clean_env = clean_env .. "PATH=" .. sh_quote(system_path) .. " "
        compiler = "-DCMAKE_C_COMPILER=/usr/bin/cc -DCMAKE_CXX_COMPILER=/usr/bin/c++ "
                .. "-DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 "
    end

    local configure = string.format(
        "%s%s -S %s -B %s -G \"Unix Makefiles\" "
        .. "-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%s "
        .. "-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_MAKE_PROGRAM=%s "
        .. "-DBUILD_STATIC=ON -DWITH_JDBC=ON -DWITH_TESTS=OFF "
        .. "-DWITH_DOC=OFF -DWITH_HEADER_CHECKS=OFF "
        .. "-DOPENSSL_USE_STATIC_LIBS=TRUE -DWITH_SSL=%s "
        .. "-DMYSQL_INCLUDE_DIR=%s/include -DMYSQL_LIB_DIR=%s/lib "
        .. "-DMYSQLCLIENT_STATIC_LINKING=ON -DMYSQLCLIENT_STATIC_BINDING=ON %s",
        clean_env, sh_quote(cmake), sh_quote(srcroot), sh_quote(builddir),
        sh_quote(prefix), sh_quote(make), sh_quote(openssl),
        sh_quote(mysql_probe), sh_quote(mysql_probe), compiler)
    if not run("CMake configure", logf, configure .. " >" .. sh_quote(logf) .. " 2>&1") then
        return false
    end

    local build = string.format(
        "%s%s --build %s --target connector -- -j%d >>%s 2>&1",
        clean_env, sh_quote(cmake), sh_quote(builddir), jobs, sh_quote(logf))
    if not run("X DevAPI build", logf, build) then return false end

    local jdbc_build = string.format(
        "%s%s --build %s --target connector-jdbc -- -j%d >>%s 2>&1",
        clean_env, sh_quote(cmake), sh_quote(builddir), jobs, sh_quote(logf))
    if not run("JDBC build", logf, jdbc_build) then return false end

    local install_cmd = string.format(
        "%s%s --install %s --component XDevAPIDev >>%s 2>&1",
        clean_env, sh_quote(cmake), sh_quote(builddir), sh_quote(logf))
    if not run("X DevAPI install", logf, install_cmd) then return false end

    local jdbc_install = string.format(
        "%s%s --install %s --component JDBCDev >>%s 2>&1",
        clean_env, sh_quote(cmake), sh_quote(builddir), sh_quote(logf))
    if not run("JDBC install", logf, jdbc_install) then return false end

    if not os.isfile(path.join(prefix, "include", "mysqlx", "xdevapi.h"))
       or not os.isfile(path.join(prefix, "include", "mysql", "jdbc.h"))
       or not os.isfile(path.join(prefix, "lib", "libmysqlcppconnx-static.a"))
       or not os.isfile(path.join(prefix, "lib", "libmysqlcppconn-static.a")) then
        log.error("compat.mysql-connector-cpp: incomplete X DevAPI/JDBC install")
        return false
    end

    io.writefile(path.join(prefix, "mcpp_mysql_connector_cpp_anchor.c"),
                 "int mcpp_compat_mysql_connector_cpp_anchor(void) { return 0; }\n")
        end)
    if not ok then
        hook_log("UNCAUGHT Lua error: " .. tostring(result))
        return false
    end
    hook_log("install() result=" .. tostring(result))
    return result
end
