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
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.0/openkal-uefi-0.1.0.tar.gz",
                },
                sha256 = "2b8a5035cd738e8b23d4ece7ea70cf6d2aba8c8b1150c613c8f1deb94092035a",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.1.0/openkal-uefi-0.1.0.tar.gz",
                },
                sha256 = "2b8a5035cd738e8b23d4ece7ea70cf6d2aba8c8b1150c613c8f1deb94092035a",
            },
        },
        windows = {
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
