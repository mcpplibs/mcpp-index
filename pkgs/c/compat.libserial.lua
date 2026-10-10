-- compat.libserial — LibSerial 1.0.0, an object-oriented C++ wrapper over the
-- POSIX serial-port interface: `SerialPort` (a descriptor-style class) and
-- `SerialStream` (an iostream on top of a `SerialStreamBuf`).
--
-- Shape A (C++-source compat), same as compat.websocket: upstream's three
-- translation units from src/CMakeLists.txt (`LIBSERIAL_SOURCES`) compiled into
-- one lib target, and the public headers exposed through `include_dirs` so a
-- consumer writes `#include <libserial/SerialPort.h>` — upstream's own install
-- layout (`install(DIRECTORY libserial DESTINATION include)`).
--
-- LINUX ONLY, and there is no macOS/Windows section to write. Upstream targets
-- POSIX: SerialPortConstants.h includes <termios.h> from the top, and every
-- implementation TU reaches <linux/serial.h>, <sys/ioctl.h> and <unistd.h>.
-- The serial-port ioctls it drives (TIOCEXCL, TIOCMGET, FIONREAD, TIOCSSERIAL)
-- and `struct serial_struct` are Linux UAPI. This is why the test member gates
-- the dependency with `[target.'cfg(linux)'.dependencies]` and compiles to a
-- no-op main() elsewhere — the mirror image of compat.wil and the same shape as
-- compat.libaio. (Single-platform `xpm` is why platform-version-parity stays
-- quiet: it only compares platforms that both carry versions.)
--
-- TWO CONSUMER-VISIBLE DEFECTS ARE FIXED HERE. The first: src/libserial/SerialPortConstants.h
-- declares `using DataBuffer = std::vector<uint8_t>;` but includes neither
-- <cstdint> nor <stdint.h>. On gcc 16.1.0 / libstdc++ this compiles only by
-- accident of transitive includes — a bare consumer that opens the header first
-- gets "'uint8_t' was not declared in this scope" (reproduced against the
-- tarball). A `generated_files` shim named after the same path, found first
-- because mcpp_generated precedes `*/src` in include_dirs, includes <cstdint>
-- and then `#include_next`s upstream's real header (the compat.yaml-cpp /
-- compat.cpptrace / compat.catch2 pattern). The test's first line is that
-- include with nothing before it, so the shim is compile-time asserted.
--
-- The second: src/libserial/SerialPort.h declares the public template
-- `call_with_retry` with `std::result_of<Fn(Args...)>`, which C++20 REMOVED.
-- libstdc++ still ships it (deprecated), so gcc builds; libc++ does not, so on
-- an llvm toolchain all three TUs fail with "no type named 'result_of' in
-- namespace 'std'" — and so would every consumer TU, since it is a public
-- header (upstream master still has it). A shim cannot fix a template inside
-- the header, and libc++'s _LIBCPP_ENABLE_CXX20_REMOVED_TYPE_TRAITS only works
-- when defined before the FIRST libc++ header of every TU, consumers included,
-- which a descriptor cannot guarantee. So install() rewrites the two spellings
-- to the C++17 equivalent `std::invoke_result_t<Fn, Args...>` (identical for the
-- function pointers and decayed arguments it is called with) and adds the
-- <type_traits> it needs, asserting each match count so an upstream change
-- fails the install instead of silently skipping the fix.
--
-- NO FEATURE. The three TUs are the whole library; upstream's optional parts
-- are the GoogleTest suite (test/, its own main()), the SIP Python bindings
-- (sip/) and the Doxygen docs (doxygen.conf.in) — none is an optional
-- compilable component of the lib. So `features` is not declared at all.
--
-- VERSION. 1.0.0 is upstream's latest release (github tag `v1.0.0`, the only
-- v1 tag; earlier tags are 0.5/0.6 release candidates and are not built here).
-- CN mirror: mcpp-res/libserial carries the same tarball (byte-identical, same
-- sha256), per docs/cn-mirror.md.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libserial",
    description = "LibSerial — object-oriented C++ serial-port library (SerialPort / SerialStream)",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/crayzeewulf/libserial",
    type        = "package",

    xpm = {
        linux = {
            ["1.0.0"] = {
                url    = {
                    GLOBAL = "https://github.com/crayzeewulf/libserial/archive/refs/tags/v1.0.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libserial/releases/download/1.0.0/libserial-1.0.0.tar.gz",
                },
                sha256 = "063142d6bfe08898316e9a6055f2ddeedef56de06f7cfc8dcdfecc6efabf4bdd",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,

        -- ORDER MATTERS: mcpp_generated first, so the <cstdint> shim for
        -- libserial/SerialPortConstants.h is found before upstream's copy,
        -- which it then reaches with #include_next. `*/src` is upstream's
        -- install root and carries only the libserial/ directory, so there is
        -- nothing generic here that could shadow a system header.
        include_dirs = { "mcpp_generated", "*/src" },

        generated_files = {
            -- See the header note. Without this, a consumer TU that opens a
            -- libserial header before any libstdc++ header that transitively
            -- pulls <cstdint> fails with "'uint8_t' was not declared".
            ["mcpp_generated/libserial/SerialPortConstants.h"] = [==[
// compat.libserial shim: upstream's SerialPortConstants.h uses uint8_t but
// includes neither <cstdint> nor <stdint.h>; it compiles only through a
// transitive include of whatever stdlib header happens to come first. This
// shim guarantees <cstdint> and then resumes the search at upstream's header.
#ifndef MCPP_COMPAT_LIBSERIAL_CSTDINT_SHIM
#define MCPP_COMPAT_LIBSERIAL_CSTDINT_SHIM
#include <cstdint>
#include_next <libserial/SerialPortConstants.h>
#endif
]==],
        },

        -- Upstream src/CMakeLists.txt `LIBSERIAL_SOURCES`, verbatim.
        sources = {
            "*/src/SerialPort.cpp",
            "*/src/SerialStream.cpp",
            "*/src/SerialStreamBuf.cpp",
        },

        -- `libserial.a` / `-lserial`, the spelling upstream's libserial.pc
        -- publishes.
        targets = { ["serial"] = { kind = "lib" } },
        deps    = { },
    },
}

import("xim.libxpkg.pkginfo")

-- See the header note: the C++20-removed std::result_of in SerialPort.h.
-- Patched in the unpacked tree, which is then moved into the install dir as
-- its single wrap level so the `*/src` globs keep matching (compat.ftxui /
-- taskflow.taskflow do the same).
function install()
    local wrap = "libserial-" .. pkginfo.version()
    local function patch(relative, before, after, expected)
        local source = path.join(wrap, relative)
        local content = io.readfile(source)
        if not content then
            log.error("compat.libserial: cannot read %s", source)
            return false
        end
        local pattern = before:gsub("(%W)", "%%%1")
        local patched, count = content:gsub(pattern, function() return after end)
        if count ~= expected then
            log.error("compat.libserial: expected %d match(es) of %q in %s, found %d",
                      expected, before, source, count)
            return false
        end
        io.writefile(source, patched)
        return true
    end

    local header = "src/libserial/SerialPort.h"
    if not patch(header, "typename std::result_of<Fn(Args...)>::type",
                 "std::invoke_result_t<Fn, Args...>", 2) then return false end
    if not patch(header, "#include <memory>\n",
                 "#include <memory>\n#include <type_traits>\n", 1) then return false end

    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    os.mv(wrap, path.join(prefix, wrap))
    return true
end
