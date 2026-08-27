-- openkal-uefi — openkal on UEFI Boot Services.
--
-- ⚠️ The consuming project targets `x86_64-windows-gnu` with three link flags
-- (`-nostdlib`, `--subsystem,10`, `-e,efi_main`), which is not a workaround: a
-- UEFI application IS PE/COFF with subsystem 10, entered through the Microsoft
-- x64 calling convention, and that target already has both properties.
--
-- An earlier analysis held that a new "PE freestanding" target would be needed
-- first. Measured otherwise — the flags above produce
-- IMAGE_SUBSYSTEM_EFI_APPLICATION with no DLL imports, verified booting under
-- OVMF.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-uefi",
    description = "An implementation of openkal on UEFI Boot Services, for applications the firmware loads before an operating system exists",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-uefi",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.2.0/openkal-uefi-0.2.0.tar.gz",
                },
                sha256 = "c2ee06df0bf7ff958f70040953c2bb0d11c989ad755e8e35c3c3472ce4f41333",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.3/openkal-uefi-0.1.3.tar.gz",
                },
                sha256 = "8ad74dec84c850e45767e4c3a640398502f613cf80b909a6dd17b22a095f07d7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.2/openkal-uefi-0.1.2.tar.gz",
                },
                sha256 = "8307af0b2678cf2cf0b3885757dca382839431bbb7d873673d25e24fab3dc1ce",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.1/openkal-uefi-0.1.1.tar.gz",
                },
                sha256 = "9718169383ca4e51cd79a82a96471b1a41923363adb81c7a5eae6fffc70ae172",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.0/openkal-uefi-0.1.0.tar.gz",
                },
                sha256 = "2b8a5035cd738e8b23d4ece7ea70cf6d2aba8c8b1150c613c8f1deb94092035a",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.2.0/openkal-uefi-0.2.0.tar.gz",
                },
                sha256 = "c2ee06df0bf7ff958f70040953c2bb0d11c989ad755e8e35c3c3472ce4f41333",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.3/openkal-uefi-0.1.3.tar.gz",
                },
                sha256 = "8ad74dec84c850e45767e4c3a640398502f613cf80b909a6dd17b22a095f07d7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.2/openkal-uefi-0.1.2.tar.gz",
                },
                sha256 = "8307af0b2678cf2cf0b3885757dca382839431bbb7d873673d25e24fab3dc1ce",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.1/openkal-uefi-0.1.1.tar.gz",
                },
                sha256 = "9718169383ca4e51cd79a82a96471b1a41923363adb81c7a5eae6fffc70ae172",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.0/openkal-uefi-0.1.0.tar.gz",
                },
                sha256 = "2b8a5035cd738e8b23d4ece7ea70cf6d2aba8c8b1150c613c8f1deb94092035a",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.2.0/openkal-uefi-0.2.0.tar.gz",
                },
                sha256 = "c2ee06df0bf7ff958f70040953c2bb0d11c989ad755e8e35c3c3472ce4f41333",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.3/openkal-uefi-0.1.3.tar.gz",
                },
                sha256 = "8ad74dec84c850e45767e4c3a640398502f613cf80b909a6dd17b22a095f07d7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.2/openkal-uefi-0.1.2.tar.gz",
                },
                sha256 = "8307af0b2678cf2cf0b3885757dca382839431bbb7d873673d25e24fab3dc1ce",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.1/openkal-uefi-0.1.1.tar.gz",
                },
                sha256 = "9718169383ca4e51cd79a82a96471b1a41923363adb81c7a5eae6fffc70ae172",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.0/openkal-uefi-0.1.0.tar.gz",
                },
                sha256 = "2b8a5035cd738e8b23d4ece7ea70cf6d2aba8c8b1150c613c8f1deb94092035a",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
