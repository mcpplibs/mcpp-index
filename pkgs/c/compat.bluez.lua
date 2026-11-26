local versions = {
    ["5.88"] = {
        url    = "https://github.com/bluez/bluez/archive/refs/tags/5.88.tar.gz",
        sha256 = "667203f5dba91cf8b2094239dd9b415b487146cb00d4653179c11723dce52f19",
    },
}

-- compat.bluez — BlueZ 5.88 user-space Bluetooth headers and libbluetooth helpers (Linux).
--
-- Form B source-built package compiling `*/lib/bluetooth/{bluetooth,hci,sdp,uuid}.c`
-- and exposing `<bluetooth/*.h>` (`bluetooth.h`, `l2cap.h`, `hci.h`, `rfcomm.h`, `uuid.h`).
-- Used on Linux alongside `gnome.gio` (`org.bluez` D-Bus + `AF_BLUETOOTH` sockets).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "bluez",
    description = "BlueZ 5.88 — Linux Bluetooth protocol stack headers and libbluetooth library",
    licenses    = { "GPL-2.0-or-later", "LGPL-2.1-or-later" },
    repo        = "https://github.com/bluez/bluez",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/bluez/bluez/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = { ["5.88"] = versions["5.88"] },
    },

    mcpp = {
        language             = "c++23",
        import_std           = false,
        c_standard           = "c11",
        license_files        = { "*/COPYING", "*/COPYING.LIB" },
        include_dirs         = { "*/lib", "*/lib/bluetooth" },
        private_include_dirs = { "*/lib/bluetooth" },

        cflags = { "-D_GNU_SOURCE" },

        sources = {
            "*/lib/bluetooth/bluetooth.c",
            "*/lib/bluetooth/hci.c",
            "*/lib/bluetooth/sdp.c",
            "*/lib/bluetooth/uuid.c",
        },

        targets = {
            bluetooth = { kind = "static" },
        },
    },
}
