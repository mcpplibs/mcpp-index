-- openkal-uefi — openkal on UEFI Boot Services.
--
-- From 0.9.0 a project names the target `x86_64-uefi` and nothing else: the
-- row (clang's `x86_64-unknown-uefi`, PE32+ with the EFI application subsystem),
-- its compile and link conventions and its runner (QEMU's q35 with the edk2
-- firmware, through dirun) are the platform package openkal-uefi-platform's,
-- which selects this implementation. Before 0.9.0 a consuming project targeted
-- `x86_64-windows-gnu` with three link flags (`-nostdlib`, `--subsystem,10`,
-- `-e,efi_main`); the platform states the same facts once.
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
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.9.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.9.0/openkal-uefi-0.9.0.tar.gz",
                },
                sha256 = "1581fffd2bc4e44502ad02c68c3ee19fa94241a70de8a0b61df0952acca952d7",
            },
            ["0.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.8.1/openkal-uefi-0.8.1.tar.gz",
                },
                sha256 = "8f78a0cda718f79fe23a6b22a16d645b5ac22e071e2d34318b611333f5a7ad52",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.8.0/openkal-uefi-0.8.0.tar.gz",
                },
                sha256 = "a1c920dc862a974431b7c8518cdb8085bc6d0ff22bbacbd4d97fe7f8b16720ac",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.7.0/openkal-uefi-0.7.0.tar.gz",
                },
                sha256 = "fa16ad19d13dae8509d90ec2fd3714503701c27f323233bdbd2ba32ca3653068",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.6.0/openkal-uefi-0.6.0.tar.gz",
                },
                sha256 = "ca152cd52aacbc7631514ba34014ade6503c92162703316a1c46456e478a5478",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.5.0/openkal-uefi-0.5.0.tar.gz",
                },
                sha256 = "b2aef7b4d3a0da0e0fef92bf8d7f247a486f402bfea20d562fd48b17485b3177",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.4.0/openkal-uefi-0.4.0.tar.gz",
                },
                sha256 = "551282ee0135fe9439aa4c782ceb62f919437766bc287aa7098b0d9d58d9b042",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.3.0/openkal-uefi-0.3.0.tar.gz",
                },
                sha256 = "996514a2c0c59af76410bea324ea0f8276937d2c52b92da381ee40217e30311d",
            },
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
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.9.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.9.0/openkal-uefi-0.9.0.tar.gz",
                },
                sha256 = "1581fffd2bc4e44502ad02c68c3ee19fa94241a70de8a0b61df0952acca952d7",
            },
            ["0.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.8.1/openkal-uefi-0.8.1.tar.gz",
                },
                sha256 = "8f78a0cda718f79fe23a6b22a16d645b5ac22e071e2d34318b611333f5a7ad52",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.8.0/openkal-uefi-0.8.0.tar.gz",
                },
                sha256 = "a1c920dc862a974431b7c8518cdb8085bc6d0ff22bbacbd4d97fe7f8b16720ac",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.7.0/openkal-uefi-0.7.0.tar.gz",
                },
                sha256 = "fa16ad19d13dae8509d90ec2fd3714503701c27f323233bdbd2ba32ca3653068",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.6.0/openkal-uefi-0.6.0.tar.gz",
                },
                sha256 = "ca152cd52aacbc7631514ba34014ade6503c92162703316a1c46456e478a5478",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.5.0/openkal-uefi-0.5.0.tar.gz",
                },
                sha256 = "b2aef7b4d3a0da0e0fef92bf8d7f247a486f402bfea20d562fd48b17485b3177",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.4.0/openkal-uefi-0.4.0.tar.gz",
                },
                sha256 = "551282ee0135fe9439aa4c782ceb62f919437766bc287aa7098b0d9d58d9b042",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.3.0/openkal-uefi-0.3.0.tar.gz",
                },
                sha256 = "996514a2c0c59af76410bea324ea0f8276937d2c52b92da381ee40217e30311d",
            },
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
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.9.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.9.0/openkal-uefi-0.9.0.tar.gz",
                },
                sha256 = "1581fffd2bc4e44502ad02c68c3ee19fa94241a70de8a0b61df0952acca952d7",
            },
            ["0.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.8.1/openkal-uefi-0.8.1.tar.gz",
                },
                sha256 = "8f78a0cda718f79fe23a6b22a16d645b5ac22e071e2d34318b611333f5a7ad52",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.8.0/openkal-uefi-0.8.0.tar.gz",
                },
                sha256 = "a1c920dc862a974431b7c8518cdb8085bc6d0ff22bbacbd4d97fe7f8b16720ac",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.7.0/openkal-uefi-0.7.0.tar.gz",
                },
                sha256 = "fa16ad19d13dae8509d90ec2fd3714503701c27f323233bdbd2ba32ca3653068",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.6.0/openkal-uefi-0.6.0.tar.gz",
                },
                sha256 = "ca152cd52aacbc7631514ba34014ade6503c92162703316a1c46456e478a5478",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.5.0/openkal-uefi-0.5.0.tar.gz",
                },
                sha256 = "b2aef7b4d3a0da0e0fef92bf8d7f247a486f402bfea20d562fd48b17485b3177",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.4.0/openkal-uefi-0.4.0.tar.gz",
                },
                sha256 = "551282ee0135fe9439aa4c782ceb62f919437766bc287aa7098b0d9d58d9b042",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-uefi/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-uefi/releases/download/0.3.0/openkal-uefi-0.3.0.tar.gz",
                },
                sha256 = "996514a2c0c59af76410bea324ea0f8276937d2c52b92da381ee40217e30311d",
            },
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
