package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.x11",
    description = "Xlib runtime library and public headers built from upstream sources",
    licenses    = {"BSD-1-Clause", "HPND-sell-variant", "ISC", "MIT", "MIT-Open-Group", "X11"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libx11",
    type        = "package",

    xpm = {
        linux = {
            ["1.8.13"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libX11-1.8.13.tar.gz",
                sha256 = "acf0e7cd7541110e6330ecb539441a2d53061f386ec7be6906dfde0de2598470",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {
            ".",
            "include",
            "include/X11",
            "src",
            "src/xcms",
            "src/xkb",
            "src/xlibi18n",
            "modules/im/ximcp",
            "modules/lc/def",
            "modules/lc/gen",
            "modules/lc/Utf8",
            "modules/om/generic",
        },
        cflags = {
            "-D_GNU_SOURCE",
            "-D_DEFAULT_SOURCE",
            "-D_BSD_SOURCE",
            "-DXIM_t=1",
            "-DTRANS_CLIENT=1",
            "-DHAVE_CONFIG_H",
        },
        sources = {
            "src/*.c",
            "src/xcms/*.c",
            "src/xkb/*.c",
            "src/xlibi18n/*.c",
            "!src/xlibi18n/XlcDL.c",
            "!src/xlibi18n/XlcSL.c",
            "modules/im/ximcp/*.c",
            "modules/lc/def/*.c",
            "modules/lc/gen/*.c",
            "modules/lc/Utf8/*.c",
            "modules/om/generic/*.c",
        },
        targets = { ["X11"] = { kind = "shared", soname = "libX11.so.6" } },
        deps = {
            ["compat.xcb"]       = "1.17.0",
            ["compat.xorgproto"] = "2025.1",
            ["compat.xtrans"]    = "1.6.0",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local makekeys_py = [=[
import re
import sys

KTNUM = 4000
MIN_REHASH = 15
MATCHES = 10
XK_VOID_SYMBOL = 0xFFFFFF

defs = []

def parse_line(line):
    m = re.match(r"#define\s+(\S+)\s+0x([0-9a-fA-F]+)", line)
    if m and "XK_" in m.group(1):
        key = m.group(1)
        i = key.find("XK_")
        return key[:i] + key[i + 3:], int(m.group(2), 16)

    m = re.match(r"#define\s+(\S+)\s+_EVDEVK\(0x([0-9a-fA-F]+)\)", line)
    if m and "XK_" in m.group(1):
        key = m.group(1)
        i = key.find("XK_")
        return key[:i] + key[i + 3:], int(m.group(2), 16) + 0x10081000

    m = re.match(r"#define\s+(\S+)\s+(\S+)", line)
    if m and "XK_" in m.group(1) and "XK_" in m.group(2):
        key = m.group(1)
        alias = m.group(2)
        i = key.find("XK_")
        ai = alias.find("XK_")
        name = key[:i] + key[i + 3:]
        alias_name = alias[:ai] + alias[ai + 3:]
        for old_name, old_value in reversed(defs):
            if old_name == alias_name:
                return name, old_value
    return None

for filename in sys.argv[1:]:
    with open(filename, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            parsed = parse_line(line)
            if not parsed:
                continue
            name, value = parsed
            if value == XK_VOID_SYMBOL:
                value = 0
            if value > 0x1FFFFFFF:
                continue
            defs.append((name, value))

def signature(name):
    sig = 0
    for ch in name:
        sig = ((sig << 1) + ord(ch)) & 0xFFFFFFFF
    return sig

def find_hash_by_name():
    best_max = len(defs)
    best_z = 0
    found = 0
    for z in range(len(defs), KTNUM):
        used = [False] * z
        max_rehash = 0
        ok = True
        for name, _ in defs:
            sig = signature(name)
            first = j = sig % z
            k = 0
            while used[j]:
                k += 1
                j += first + 1
                if j >= z:
                    j -= z
                if j == first:
                    ok = False
                    break
            if not ok:
                break
            used[j] = True
            max_rehash = max(max_rehash, k)
        if ok and max_rehash < MIN_REHASH:
            if max_rehash < best_max:
                best_max = max_rehash
                best_z = z
            found += 1
            if found >= MATCHES:
                break
    return best_z, best_max

def find_hash_by_value():
    best_max = len(defs)
    best_z = 0
    found = 0
    for z in range(len(defs), KTNUM):
        used = [False] * z
        values = [None] * z
        max_rehash = 0
        ok = True
        for _, value in defs:
            first = j = value % z
            k = 0
            while used[j]:
                if values[j] == value:
                    break
                k += 1
                j += first + 1
                if j >= z:
                    j -= z
                if j == first:
                    ok = False
                    break
            if not ok:
                break
            used[j] = True
            values[j] = value
            max_rehash = max(max_rehash, k)
        if ok and max_rehash < MIN_REHASH:
            if max_rehash < best_max:
                best_max = max_rehash
                best_z = z
            found += 1
            if found >= MATCHES:
                break
    return best_z, best_max

def c_char(ch):
    if ch == "'":
        return "'\\''"
    if ch == "\\":
        return "'\\\\'"
    return "'" + ch + "'"

z, max_rehash = find_hash_by_name()
if not z:
    raise SystemExit("makekeys: failed to find string hash")

offsets = [0] * z
indexes = [0] * len(defs)
rows = []
k = 1
for i, (name, value) in enumerate(defs):
    sig = signature(name)
    first = j = sig % z
    while offsets[j]:
        j += first + 1
        if j >= z:
            j -= z
    offsets[j] = k
    indexes[i] = k
    row = [
        "0x%.2x" % ((sig >> 8) & 0xff),
        "0x%.2x" % (sig & 0xff),
        "0x%.2x" % ((value >> 24) & 0xff),
        "0x%.2x" % ((value >> 16) & 0xff),
        "0x%.2x" % ((value >> 8) & 0xff),
        "0x%.2x" % (value & 0xff),
    ]
    row.extend(c_char(ch) for ch in name)
    row.append("0")
    rows.append(row)
    k += 7 + len(name)

print("/* This file is generated from keysymdef.h. */")
print("/* Do not edit. */")
print()
print("#ifdef NEEDKTABLE")
print("const unsigned char _XkeyTable[] = {")
print("0,")
for i, row in enumerate(rows):
    end = "" if i == len(rows) - 1 else ","
    print(", ".join(row) + end)
print("};")
print()
print("#define KTABLESIZE %d" % z)
print("#define KMAXHASH %d" % (max_rehash + 1))
print()
print("static const unsigned short hashString[KTABLESIZE] = {")
for i in range(0, z, 8):
    chunk = offsets[i:i + 8]
    line = ", ".join("0x%.4x" % x for x in chunk)
    if i + 8 < z:
        line += ","
    print(line)
print()
print("};")
print("#endif /* NEEDKTABLE */")

z, max_rehash = find_hash_by_value()
if not z:
    raise SystemExit("makekeys: failed to find value hash")

offsets = [0] * z
values = [None] * z
for i, (_, value) in enumerate(defs):
    first = j = value % z
    while offsets[j]:
        if values[j] == value:
            break
        j += first + 1
        if j >= z:
            j -= z
    if not offsets[j]:
        offsets[j] = indexes[i] + 2
        values[j] = value

print()
print("#ifdef NEEDVTABLE")
print("#define VTABLESIZE %d" % z)
print("#define VMAXHASH %d" % (max_rehash + 1))
print()
print("static const unsigned short hashKeysym[VTABLESIZE] = {")
for i in range(0, z, 8):
    chunk = offsets[i:i + 8]
    line = ", ".join("0x%.4x" % x for x in chunk)
    if i + 8 < z:
        line += ","
    print(line)
print()
print("};")
print("#endif /* NEEDVTABLE */")
]=]

local function first_existing(paths)
    for _, candidate in ipairs(paths) do
        if os.isfile(candidate) then
            return candidate
        end
    end
    return nil
end

local function xorgproto_header(root, name)
    return first_existing({
        path.join(root, "include", "X11", name),
        path.join(root, "xorgproto-2025.1", "include", "X11", name),
    })
end

local function c_string(value)
    return '"' .. tostring(value):gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

local function strip_xk_prefix(symbol)
    local pos = symbol:find("XK_", 1, true)
    if not pos then
        return nil
    end
    return symbol:sub(1, pos - 1) .. symbol:sub(pos + 3)
end

local function parse_keysym_headers(headers)
    local defs = {}
    for _, filename in ipairs(headers) do
        local content = io.readfile(filename)
        for line in content:gmatch("[^\r\n]+") do
            local key, hex = line:match("^%s*#define%s+(%S+)%s+0x([0-9a-fA-F]+)")
            if key and key:find("XK_", 1, true) then
                local name = strip_xk_prefix(key)
                local value = tonumber(hex, 16)
                if value == 0xFFFFFF then
                    value = 0
                end
                if value <= 0x1FFFFFFF then
                    table.insert(defs, { name = name, value = value })
                end
            else
                key, hex = line:match("^%s*#define%s+(%S+)%s+_EVDEVK%(0x([0-9a-fA-F]+)%)")
                if key and key:find("XK_", 1, true) then
                    local name = strip_xk_prefix(key)
                    table.insert(defs, { name = name, value = tonumber(hex, 16) + 0x10081000 })
                else
                    local alias
                    key, alias = line:match("^%s*#define%s+(%S+)%s+(%S+)")
                    if key and alias and key:find("XK_", 1, true) and alias:find("XK_", 1, true) then
                        local name = strip_xk_prefix(key)
                        local alias_name = strip_xk_prefix(alias)
                        for i = #defs, 1, -1 do
                            if defs[i].name == alias_name then
                                table.insert(defs, { name = name, value = defs[i].value })
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    return defs
end

local function signature(name)
    local sig = 0
    for i = 1, #name do
        sig = (sig * 2 + name:byte(i)) % 0x100000000
    end
    return sig
end

local function find_hash_by_name(defs)
    local best_max = #defs
    local best_z = 0
    local found = 0
    for z = #defs, 3999 do
        local used = {}
        local max_rehash = 0
        local ok = true
        for _, def in ipairs(defs) do
            local sig = signature(def.name)
            local first = sig % z
            local j = first
            local k = 0
            while used[j] do
                k = k + 1
                j = j + first + 1
                if j >= z then
                    j = j - z
                end
                if j == first then
                    ok = false
                    break
                end
            end
            if not ok then
                break
            end
            used[j] = true
            if k > max_rehash then
                max_rehash = k
            end
        end
        if ok and max_rehash < 15 then
            if max_rehash < best_max then
                best_max = max_rehash
                best_z = z
            end
            found = found + 1
            if found >= 10 then
                break
            end
        end
    end
    return best_z, best_max
end

local function find_hash_by_value(defs)
    local best_max = #defs
    local best_z = 0
    local found = 0
    for z = #defs, 3999 do
        local used = {}
        local values = {}
        local max_rehash = 0
        local ok = true
        for _, def in ipairs(defs) do
            local first = def.value % z
            local j = first
            local k = 0
            while used[j] do
                if values[j] == def.value then
                    break
                end
                k = k + 1
                j = j + first + 1
                if j >= z then
                    j = j - z
                end
                if j == first then
                    ok = false
                    break
                end
            end
            if not ok then
                break
            end
            used[j] = true
            values[j] = def.value
            if k > max_rehash then
                max_rehash = k
            end
        end
        if ok and max_rehash < 15 then
            if max_rehash < best_max then
                best_max = max_rehash
                best_z = z
            end
            found = found + 1
            if found >= 10 then
                break
            end
        end
    end
    return best_z, best_max
end

local function c_char(ch)
    if ch == "'" then
        return "'\\''"
    end
    if ch == "\\" then
        return "'\\\\'"
    end
    return "'" .. ch .. "'"
end

local function hex2(value)
    return string.format("0x%.2x", value % 0x100)
end

local function hex4(value)
    return string.format("0x%.4x", value % 0x10000)
end

local function write_ks_tables(headers, out)
    local defs = parse_keysym_headers(headers)
    local z, max_rehash = find_hash_by_name(defs)
    if z == 0 then
        log.error("makekeys: failed to find string hash")
        return false
    end

    local lines = {
        "/* This file is generated from keysymdef.h. */",
        "/* Do not edit. */",
        "",
        "#ifdef NEEDKTABLE",
        "const unsigned char _XkeyTable[] = {",
        "0,",
    }
    local offsets = {}
    local indexes = {}
    local rows = {}
    local k = 1
    for i, def in ipairs(defs) do
        local sig = signature(def.name)
        local first = sig % z
        local j = first
        while offsets[j] do
            j = j + first + 1
            if j >= z then
                j = j - z
            end
        end
        offsets[j] = k
        indexes[i] = k

        local row = {
            hex2(math.floor(sig / 0x100)),
            hex2(sig),
            hex2(math.floor(def.value / 0x1000000)),
            hex2(math.floor(def.value / 0x10000)),
            hex2(math.floor(def.value / 0x100)),
            hex2(def.value),
        }
        for pos = 1, #def.name do
            table.insert(row, c_char(def.name:sub(pos, pos)))
        end
        table.insert(row, "0")
        table.insert(rows, row)
        k = k + 7 + #def.name
    end

    for i, row in ipairs(rows) do
        local suffix = i == #rows and "" or ","
        table.insert(lines, table.concat(row, ", ") .. suffix)
    end

    table.insert(lines, "};")
    table.insert(lines, "")
    table.insert(lines, "#define KTABLESIZE " .. tostring(z))
    table.insert(lines, "#define KMAXHASH " .. tostring(max_rehash + 1))
    table.insert(lines, "")
    table.insert(lines, "static const unsigned short hashString[KTABLESIZE] = {")
    for i = 0, z - 1, 8 do
        local chunk = {}
        for j = i, math.min(i + 7, z - 1) do
            table.insert(chunk, hex4(offsets[j] or 0))
        end
        local suffix = i + 8 < z and "," or ""
        table.insert(lines, table.concat(chunk, ", ") .. suffix)
    end
    table.insert(lines, "")
    table.insert(lines, "};")
    table.insert(lines, "#endif /* NEEDKTABLE */")

    z, max_rehash = find_hash_by_value(defs)
    if z == 0 then
        log.error("makekeys: failed to find value hash")
        return false
    end

    offsets = {}
    local values = {}
    for i, def in ipairs(defs) do
        local first = def.value % z
        local j = first
        while offsets[j] do
            if values[j] == def.value then
                break
            end
            j = j + first + 1
            if j >= z then
                j = j - z
            end
        end
        if not offsets[j] then
            offsets[j] = indexes[i] + 2
            values[j] = def.value
        end
    end

    table.insert(lines, "")
    table.insert(lines, "#ifdef NEEDVTABLE")
    table.insert(lines, "#define VTABLESIZE " .. tostring(z))
    table.insert(lines, "#define VMAXHASH " .. tostring(max_rehash + 1))
    table.insert(lines, "")
    table.insert(lines, "static const unsigned short hashKeysym[VTABLESIZE] = {")
    for i = 0, z - 1, 8 do
        local chunk = {}
        for j = i, math.min(i + 7, z - 1) do
            table.insert(chunk, hex4(offsets[j] or 0))
        end
        local suffix = i + 8 < z and "," or ""
        table.insert(lines, table.concat(chunk, ", ") .. suffix)
    end
    table.insert(lines, "")
    table.insert(lines, "};")
    table.insert(lines, "#endif /* NEEDVTABLE */")

    io.writefile(out, table.concat(lines, "\n") .. "\n")
    return true
end

local function write_config(installdir)
    local x11datadir = path.join(installdir, "share", "X11")
    io.writefile(path.join(installdir, "config.h"), [[#ifndef MCPP_COMPAT_X11_CONFIG_H
#define MCPP_COMPAT_X11_CONFIG_H

#define HAVE_UNISTD_H 1
#define HAVE_SYS_IOCTL_H 1
#define HAVE_SYS_SELECT_H 1
#define HAVE_SYS_SOCKET_H 1
#define HAVE_STRCASECMP 1
#define HAVE_STRNCASECMP 1
#define HAVE_STRDUP 1
#define HAVE_POLL 1
#define USE_POLL 1
#define HAS_SHM 1
#define XTHREADS 1
#define XUSE_MTSAFE_API 1
#define XKB 1
#define XCMS 1
#define XLOCALE 1
#define XCMSDIR ]] .. c_string(x11datadir) .. "\n" .. [[
#define XLOCALEDIR ]] .. c_string(path.join(x11datadir, "locale")) .. "\n" .. [[
#define XLOCALELIBDIR ]] .. c_string(path.join(x11datadir, "locale")) .. "\n" .. [[
#define XLOCALEDATADIR ]] .. c_string(path.join(x11datadir, "locale")) .. "\n" .. [[
#define XERRORDB ]] .. c_string(path.join(x11datadir, "XErrorDB")) .. [[

#endif
]])

    io.writefile(path.join(installdir, "include", "X11", "XlibConf.h"), [[#ifndef _XLIBCONF_H_
#define _XLIBCONF_H_
#define XTHREADS 1
#define XUSE_MTSAFE_API 1
#endif
]])
end

local function generate_ks_tables(installdir)
    local proto_dir = pkginfo.install_dir("compat:compat.xorgproto", "2025.1")
        or pkginfo.install_dir("compat.xorgproto", "2025.1")
    if not proto_dir then
        log.error("compat.xorgproto@2025.1 install dir not found")
        return false
    end

    local headers = {
        xorgproto_header(proto_dir, "keysymdef.h"),
        xorgproto_header(proto_dir, "XF86keysym.h"),
        xorgproto_header(proto_dir, "Sunkeysym.h"),
        xorgproto_header(proto_dir, "DECkeysym.h"),
        xorgproto_header(proto_dir, "HPkeysym.h"),
    }
    for _, header in ipairs(headers) do
        if not header then
            log.error("missing xorgproto keysym header")
            return false
        end
    end

    local out = path.join(installdir, "src", "ks_tables.h")
    return write_ks_tables(headers, out) and os.isfile(out)
end

function install()
    local srcdir = pkginfo.install_file():replace(".tar.gz", "")
    if not os.isdir(srcdir) then
        srcdir = "libX11-" .. pkginfo.version()
    end

    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())

    local datadir = path.join(pkginfo.install_dir(), "share", "X11")
    os.mkdir(datadir)
    os.cp(path.join(pkginfo.install_dir(), "src", "XErrorDB"), path.join(datadir, "XErrorDB"))
    os.cp(path.join(pkginfo.install_dir(), "src", "xcms", "Xcms.txt"), path.join(datadir, "Xcms.txt"))

    write_config(pkginfo.install_dir())
    return generate_ks_tables(pkginfo.install_dir())
end
