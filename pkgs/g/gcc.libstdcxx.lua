-- libstdc++ as the C++ layer of an llvm build: `provides mcpp:c++-abi=libstdc++`.
--
-- WHY IT EXISTS. One process holds one C++ runtime (mcpp SPEC-002 §7). A
-- component built on libstdc++ -- `libsycl.so`, whose `sycl::exception` a SYCL
-- program catches by type -- cannot share a process with the libc++ an llvm
-- build links: the two runtimes define the same ABI names, an exception thrown
-- by one is caught by the other's personality only as `catch (...)`
-- (mcpp-community/mcpp#838), and `std::runtime_error` has a different layout
-- in each. The build therefore takes libstdc++ as its own C++ library, and the
-- compiler stays clang:
--
--   [dependencies]
--   gcc.libstdcxx = "16.1.0.1"
--
--   [toolchain]
--   default = "llvm@22.1.8"
--
-- THE MECHANISM IS THE ONE `llvm.libcxx` AND `openkal-llvm-runtime` USE, ONE
-- LIBRARY OVER: `provides` names the layer, the engine compiles with
-- `-nostdinc++` and these headers, precompiles `std` from `bits/std.cc`, and
-- links with `-stdlib=libstdc++`. Nothing is downloaded or compiled: install()
-- links the `xim:gcc` payload's headers and runtime directory into this
-- package's tree and writes its manifest, so the headers a unit is compiled
-- against, the `std` module it imports and the library it loads are one
-- release of GCC.
--
-- THE VERSION IS GCC'S, and the fourth segment is the packaging revision, as
-- `llvm.libcxx` established. A descriptor's dependency edge is per platform,
-- not per version, so one descriptor follows one GCC release: the one mcpp's
-- default gcc toolchain uses.
--
-- REQUIRES mcpp 2026.10.26.1: an earlier engine has no wiring for a
-- graph-supplied libstdc++ under clang and refuses the build at the target
-- side, naming the c++-abi layer.
package = {
    spec        = "1",
    namespace   = "gcc",
    name        = "libstdcxx",
    description = "libstdc++ from the GCC payload as the C++ standard library of an llvm build (provides mcpp:c++-abi=libstdc++)",
    licenses    = {"GPL-3.0-or-later WITH GCC-exception-3.1"},
    repo        = "https://gcc.gnu.org/git/gcc.git",
    type        = "package",

    xpm = {
        linux = {
            -- The install-time edge: the payload whose headers and runtime
            -- this package links. Materialised when THIS package installs.
            deps = { "xim:gcc@16.1.0" },
            ["16.1.0.1"] = {
                -- Nothing downloaded matters: the content is the tree
                -- install() links. A stable, tiny anchor keeps the entry
                -- well-formed, as compat.sycl-runtime does.
                url    = "https://raw.githubusercontent.com/gcc-mirror/gcc/releases/gcc-16.1.0/COPYING.RUNTIME",
                sha256 = "9d6b43ce4d8de0c878bf16b54d8e7a10d9bd42b75178153e3af6a815bdc90f74",
            },
            ["latest"] = { ref = "16.1.0.1" },
        },
    },

    -- Written by install(), because the target directory under the headers
    -- (`x86_64-linux-gnu`, `aarch64-linux-gnu`) is the payload's to say.
    mcpp = "mcpp.toml",
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local GCC_VERSION = "16.1.0"

-- The payload's install directory: the dependency edge's own answer first,
-- then the stores a shared registry keeps it in (the fallback
-- compat.sycl-runtime records the reason for).
local function gcc_dir()
    local dir = pkginfo.install_dir("xim:gcc", GCC_VERSION)
    if dir then return dir end
    local roots = {}
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    roots[#roots + 1] = path.join((os.getenv and os.getenv("HOME")) or "",
                                  ".mcpp/registry/data/xpkgs")
    for _, root in ipairs(roots) do
        local cand = path.join(root, "xim-x-gcc", GCC_VERSION)
        if os.isdir(cand) then return cand end
    end
    return nil
end

-- The target directory under include/c++/<version>: the one whose name ends
-- in `-linux-gnu`. `io.popen` rather than `os.files`, which the recipe sandbox
-- does not provide.
local function target_dir(cxx)
    local p = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], cxx))
    if not p then return nil end
    local found
    for line in p:lines() do
        local name = line:gsub("[\r\n]+$", "")
        if name:match("%-linux%-gnu$") and os.isdir(path.join(cxx, name)) then
            found = name
            break
        end
    end
    p:close()
    return found
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())
    local root = pkginfo.install_dir()

    local gcc = gcc_dir()
    if not gcc then
        log.error("gcc.libstdcxx: the xim:gcc %s payload was not found", GCC_VERSION)
        return false
    end
    local cxx = path.join(gcc, "include", "c++", GCC_VERSION)
    local triple = target_dir(cxx)
    if not os.isfile(path.join(cxx, "bits", "std.cc")) or not triple then
        log.error("gcc.libstdcxx: %s has no bits/std.cc or no target directory", cxx)
        return false
    end
    os.exec(string.format([[ln -sfn "%s" "%s"]], cxx, path.join(root, "cxx")))

    -- The runtime: the C++ library and the unwinder it needs, by the names a
    -- link asks for and the sonames the loader asks for.
    local lib = path.join(root, "lib")
    os.mkdir(lib)
    for _, name in ipairs({ "libstdc++.so", "libstdc++.so.6", "libstdc++.a",
                            "libgcc_s.so", "libgcc_s.so.1" }) do
        local f = path.join(gcc, "lib64", name)
        if os.isfile(f) or os.islink(f) then
            os.exec(string.format([[ln -sfn "%s" "%s"]], f, path.join(lib, name)))
        end
    end

    io.writefile(path.join(root, "mcpp.toml"), string.format([[
[package]
namespace = "gcc"
name      = "libstdcxx"
version   = "%s"
mcpp      = ">=2026.10.26.1"
provides  = ["mcpp:c++-abi=libstdc++"]
requires  = ["mcpp:compiler=llvm", "mcpp:c-abi=glibc"]

[build]
sources           = []
include_dirs      = ["cxx", "cxx/%s", "cxx/backward"]
std-module        = "cxx/bits/std.cc"
std-compat-module = "cxx/bits/std.compat.cc"

[runtime]
library_dirs = ["lib"]
]], pkginfo.version(), triple))
    return true
end
