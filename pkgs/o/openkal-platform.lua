-- openkal-platform --- the platform of the ok-image targets (mcpp SPEC-013).
--
-- A data package mcpp reads: the configuration of `x86_64-openkal` and
-- `aarch64-openkal` -- their toolchain, C library, C++ and compiler run-time,
-- tools, compile and link conventions, seal, runner and carrier -- and the
-- version group of the openkal family. mcpp's target table selects it for
-- both targets, so a project for an ok image declares nothing but its
-- sources; a project selects another release with
--   [target.'cfg(os = "openkal")'] platform = "openkal-platform@<version>"
-- Read by mcpp 2026.10.27.1 and later (the package states the floor).
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-platform",
    description = "The platform of ok images (<arch>-openkal): toolchain, C library and C++ run-time, tools, compile and link conventions, seal, runner and carrier, and the openkal family's version group, as one versioned statement mcpp reads",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-platform",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.24.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.4.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.4/openkal-platform-0.24.4.tar.gz",
                },
                sha256 = "966a703d97c7f9acdd6c954a02d8eed23bc0ddbf9c1272a65815a2df9075724e",
            },
            ["0.24.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.3/openkal-platform-0.24.3.tar.gz",
                },
                sha256 = "2e9325259b95e8b4c01a652640e65a80969d38ed3fff5eeef98bbbbef7fe027d",
            },
            ["0.24.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.2/openkal-platform-0.24.2.tar.gz",
                },
                sha256 = "a9fc68e4b9e7ddaf546c1a8b545032710d10efcbc64ad489b1a050443746e699",
            },
            ["0.24.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.1/openkal-platform-0.24.1.tar.gz",
                },
                sha256 = "fe1854c370c46c255795f93a382f0ab3b0f44ef68b74a395926c3c8e8feb0a10",
            },
            ["0.24.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.0/openkal-platform-0.24.0.tar.gz",
                },
                sha256 = "ef194b4bd284ce5539e1962b9ac3c945ff2413e4ca6e26e7f44fc067e361b8a2",
            },
            ["0.23.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.7/openkal-platform-0.23.7.tar.gz",
                },
                sha256 = "9150f75a77cb7074ea058c8084ad7a938913900f5e4d3af6dfc87a8478436707",
            },
            ["0.23.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.6/openkal-platform-0.23.6.tar.gz",
                },
                sha256 = "51903d50b436e81047b74b460ea1e7e23be25704ab601438b160b9370a7017c2",
            },
            ["0.23.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.5/openkal-platform-0.23.5.tar.gz",
                },
                sha256 = "e533ce5c9c68ff10f8b8748312a7e25180ae691713498aa5378e9a38ff27b01e",
            },
            ["0.23.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.4/openkal-platform-0.23.4.tar.gz",
                },
                sha256 = "dd1ea3ae41fd0607ccb02f1dbf2fe7aced073107b8442a81f33bfe74c96454d7",
            },
            ["0.23.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.3/openkal-platform-0.23.3.tar.gz",
                },
                sha256 = "83968cd52726dc30522a55779c48db584ca24a986eadac18e655813da6625422",
            },
            ["0.23.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.2/openkal-platform-0.23.2.tar.gz",
                },
                sha256 = "d81be8ad6edef9e2adf0dd920863f6b98e4d3a9ce776d57aaeaab3cdb5744dad",
            },
            ["0.23.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.1/openkal-platform-0.23.1.tar.gz",
                },
                sha256 = "fcad8f53ab7d0cff3b34746fae02ce7cf8182aead191389aaafd12025b7f7d70",
            },
            ["0.23.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.0/openkal-platform-0.23.0.tar.gz",
                },
                sha256 = "62c9b7e6f96129d93f666465ed60b7fd4e13726d0d4febbe2b0ac26ebd15fc03",
            },
            ["0.21.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.21.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.21.1/openkal-platform-0.21.1.tar.gz",
                },
                sha256 = "c15b6c31efb27a9eddc435fa43194016bfc1f88cb9fd50ac804457bea0b892c2",
            },
            ["0.21.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.21.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.21.0/openkal-platform-0.21.0.tar.gz",
                },
                sha256 = "278792651d83e585820dd2b243ba9ca53fb7b0371f1cfed212311e2f00495448",
            },
            ["0.20.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.2/openkal-platform-0.20.2.tar.gz",
                },
                sha256 = "ea81abe096524d9581de8399af2a084f2423d674bf8313640cfff8641dfb74e9",
            },
            ["0.20.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.1/openkal-platform-0.20.1.tar.gz",
                },
                sha256 = "feee95368c431d7140c01a196c8c77dbed9dcbb4725d5c31a5eabc0c4da2181a",
            },
            ["0.20.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.0/openkal-platform-0.20.0.tar.gz",
                },
                sha256 = "3c5e6eaaf4cc19dc2f4baa801b42f5a730d6621e3afb34f9acd05172c7f09329",
            },
            ["0.19.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.2/openkal-platform-0.19.2.tar.gz",
                },
                sha256 = "526c58958f31cc55d5e29b861da57c3c528d34cb2c773a4f608cd77d9778f1db",
            },
            ["0.19.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.1/openkal-platform-0.19.1.tar.gz",
                },
                sha256 = "09d44014d48bc65ac1b59a7c6c8d034c4e6315c8d0d8e76657282501fd10e237",
            },
            ["0.19.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.0/openkal-platform-0.19.0.tar.gz",
                },
                sha256 = "90f435a8e51def20f93cbbec84f93c06ddc20f65a0b10a460d74bea4a5f26f3a",
            },
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.18.0/openkal-platform-0.18.0.tar.gz",
                },
                sha256 = "8a25e101e1a7b15c41756134cb7f83d7f55864eeaa9e24a416e0fd3b0bc2f103",
            },
            ["0.17.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.3/openkal-platform-0.17.3.tar.gz",
                },
                sha256 = "36dcf9aa34cc664e12627176c5844bc64c2d386b576712022955c884577ba4ea",
            },
            ["0.17.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.2/openkal-platform-0.17.2.tar.gz",
                },
                sha256 = "e6f920b1907c1c6927e90b993ea4917620bfa1bec41ebf78b29cb79aec322038",
            },
            ["0.17.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.1/openkal-platform-0.17.1.tar.gz",
                },
                sha256 = "db006660fff2b34ff39dfa570774afac15b392e30ebcadd34675f88ea6a60b50",
            },
        },
        macosx = {
            ["0.24.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.4.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.4/openkal-platform-0.24.4.tar.gz",
                },
                sha256 = "966a703d97c7f9acdd6c954a02d8eed23bc0ddbf9c1272a65815a2df9075724e",
            },
            ["0.24.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.3/openkal-platform-0.24.3.tar.gz",
                },
                sha256 = "2e9325259b95e8b4c01a652640e65a80969d38ed3fff5eeef98bbbbef7fe027d",
            },
            ["0.24.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.2/openkal-platform-0.24.2.tar.gz",
                },
                sha256 = "a9fc68e4b9e7ddaf546c1a8b545032710d10efcbc64ad489b1a050443746e699",
            },
            ["0.24.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.1/openkal-platform-0.24.1.tar.gz",
                },
                sha256 = "fe1854c370c46c255795f93a382f0ab3b0f44ef68b74a395926c3c8e8feb0a10",
            },
            ["0.24.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.0/openkal-platform-0.24.0.tar.gz",
                },
                sha256 = "ef194b4bd284ce5539e1962b9ac3c945ff2413e4ca6e26e7f44fc067e361b8a2",
            },
            ["0.23.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.7/openkal-platform-0.23.7.tar.gz",
                },
                sha256 = "9150f75a77cb7074ea058c8084ad7a938913900f5e4d3af6dfc87a8478436707",
            },
            ["0.23.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.6/openkal-platform-0.23.6.tar.gz",
                },
                sha256 = "51903d50b436e81047b74b460ea1e7e23be25704ab601438b160b9370a7017c2",
            },
            ["0.23.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.5/openkal-platform-0.23.5.tar.gz",
                },
                sha256 = "e533ce5c9c68ff10f8b8748312a7e25180ae691713498aa5378e9a38ff27b01e",
            },
            ["0.23.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.4/openkal-platform-0.23.4.tar.gz",
                },
                sha256 = "dd1ea3ae41fd0607ccb02f1dbf2fe7aced073107b8442a81f33bfe74c96454d7",
            },
            ["0.23.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.3/openkal-platform-0.23.3.tar.gz",
                },
                sha256 = "83968cd52726dc30522a55779c48db584ca24a986eadac18e655813da6625422",
            },
            ["0.23.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.2/openkal-platform-0.23.2.tar.gz",
                },
                sha256 = "d81be8ad6edef9e2adf0dd920863f6b98e4d3a9ce776d57aaeaab3cdb5744dad",
            },
            ["0.23.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.1/openkal-platform-0.23.1.tar.gz",
                },
                sha256 = "fcad8f53ab7d0cff3b34746fae02ce7cf8182aead191389aaafd12025b7f7d70",
            },
            ["0.23.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.0/openkal-platform-0.23.0.tar.gz",
                },
                sha256 = "62c9b7e6f96129d93f666465ed60b7fd4e13726d0d4febbe2b0ac26ebd15fc03",
            },
            ["0.21.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.21.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.21.1/openkal-platform-0.21.1.tar.gz",
                },
                sha256 = "c15b6c31efb27a9eddc435fa43194016bfc1f88cb9fd50ac804457bea0b892c2",
            },
            ["0.21.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.21.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.21.0/openkal-platform-0.21.0.tar.gz",
                },
                sha256 = "278792651d83e585820dd2b243ba9ca53fb7b0371f1cfed212311e2f00495448",
            },
            ["0.20.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.2/openkal-platform-0.20.2.tar.gz",
                },
                sha256 = "ea81abe096524d9581de8399af2a084f2423d674bf8313640cfff8641dfb74e9",
            },
            ["0.20.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.1/openkal-platform-0.20.1.tar.gz",
                },
                sha256 = "feee95368c431d7140c01a196c8c77dbed9dcbb4725d5c31a5eabc0c4da2181a",
            },
            ["0.20.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.0/openkal-platform-0.20.0.tar.gz",
                },
                sha256 = "3c5e6eaaf4cc19dc2f4baa801b42f5a730d6621e3afb34f9acd05172c7f09329",
            },
            ["0.19.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.2/openkal-platform-0.19.2.tar.gz",
                },
                sha256 = "526c58958f31cc55d5e29b861da57c3c528d34cb2c773a4f608cd77d9778f1db",
            },
            ["0.19.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.1/openkal-platform-0.19.1.tar.gz",
                },
                sha256 = "09d44014d48bc65ac1b59a7c6c8d034c4e6315c8d0d8e76657282501fd10e237",
            },
            ["0.19.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.0/openkal-platform-0.19.0.tar.gz",
                },
                sha256 = "90f435a8e51def20f93cbbec84f93c06ddc20f65a0b10a460d74bea4a5f26f3a",
            },
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.18.0/openkal-platform-0.18.0.tar.gz",
                },
                sha256 = "8a25e101e1a7b15c41756134cb7f83d7f55864eeaa9e24a416e0fd3b0bc2f103",
            },
            ["0.17.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.3/openkal-platform-0.17.3.tar.gz",
                },
                sha256 = "36dcf9aa34cc664e12627176c5844bc64c2d386b576712022955c884577ba4ea",
            },
            ["0.17.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.2/openkal-platform-0.17.2.tar.gz",
                },
                sha256 = "e6f920b1907c1c6927e90b993ea4917620bfa1bec41ebf78b29cb79aec322038",
            },
            ["0.17.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.1/openkal-platform-0.17.1.tar.gz",
                },
                sha256 = "db006660fff2b34ff39dfa570774afac15b392e30ebcadd34675f88ea6a60b50",
            },
        },
        windows = {
            ["0.24.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.4.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.4/openkal-platform-0.24.4.tar.gz",
                },
                sha256 = "966a703d97c7f9acdd6c954a02d8eed23bc0ddbf9c1272a65815a2df9075724e",
            },
            ["0.24.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.3/openkal-platform-0.24.3.tar.gz",
                },
                sha256 = "2e9325259b95e8b4c01a652640e65a80969d38ed3fff5eeef98bbbbef7fe027d",
            },
            ["0.24.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.2/openkal-platform-0.24.2.tar.gz",
                },
                sha256 = "a9fc68e4b9e7ddaf546c1a8b545032710d10efcbc64ad489b1a050443746e699",
            },
            ["0.24.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.1/openkal-platform-0.24.1.tar.gz",
                },
                sha256 = "fe1854c370c46c255795f93a382f0ab3b0f44ef68b74a395926c3c8e8feb0a10",
            },
            ["0.24.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.24.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.24.0/openkal-platform-0.24.0.tar.gz",
                },
                sha256 = "ef194b4bd284ce5539e1962b9ac3c945ff2413e4ca6e26e7f44fc067e361b8a2",
            },
            ["0.23.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.7/openkal-platform-0.23.7.tar.gz",
                },
                sha256 = "9150f75a77cb7074ea058c8084ad7a938913900f5e4d3af6dfc87a8478436707",
            },
            ["0.23.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.6/openkal-platform-0.23.6.tar.gz",
                },
                sha256 = "51903d50b436e81047b74b460ea1e7e23be25704ab601438b160b9370a7017c2",
            },
            ["0.23.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.5/openkal-platform-0.23.5.tar.gz",
                },
                sha256 = "e533ce5c9c68ff10f8b8748312a7e25180ae691713498aa5378e9a38ff27b01e",
            },
            ["0.23.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.4/openkal-platform-0.23.4.tar.gz",
                },
                sha256 = "dd1ea3ae41fd0607ccb02f1dbf2fe7aced073107b8442a81f33bfe74c96454d7",
            },
            ["0.23.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.3/openkal-platform-0.23.3.tar.gz",
                },
                sha256 = "83968cd52726dc30522a55779c48db584ca24a986eadac18e655813da6625422",
            },
            ["0.23.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.2/openkal-platform-0.23.2.tar.gz",
                },
                sha256 = "d81be8ad6edef9e2adf0dd920863f6b98e4d3a9ce776d57aaeaab3cdb5744dad",
            },
            ["0.23.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.1/openkal-platform-0.23.1.tar.gz",
                },
                sha256 = "fcad8f53ab7d0cff3b34746fae02ce7cf8182aead191389aaafd12025b7f7d70",
            },
            ["0.23.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.23.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.23.0/openkal-platform-0.23.0.tar.gz",
                },
                sha256 = "62c9b7e6f96129d93f666465ed60b7fd4e13726d0d4febbe2b0ac26ebd15fc03",
            },
            ["0.21.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.21.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.21.1/openkal-platform-0.21.1.tar.gz",
                },
                sha256 = "c15b6c31efb27a9eddc435fa43194016bfc1f88cb9fd50ac804457bea0b892c2",
            },
            ["0.21.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.21.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.21.0/openkal-platform-0.21.0.tar.gz",
                },
                sha256 = "278792651d83e585820dd2b243ba9ca53fb7b0371f1cfed212311e2f00495448",
            },
            ["0.20.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.2/openkal-platform-0.20.2.tar.gz",
                },
                sha256 = "ea81abe096524d9581de8399af2a084f2423d674bf8313640cfff8641dfb74e9",
            },
            ["0.20.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.1/openkal-platform-0.20.1.tar.gz",
                },
                sha256 = "feee95368c431d7140c01a196c8c77dbed9dcbb4725d5c31a5eabc0c4da2181a",
            },
            ["0.20.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.20.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.20.0/openkal-platform-0.20.0.tar.gz",
                },
                sha256 = "3c5e6eaaf4cc19dc2f4baa801b42f5a730d6621e3afb34f9acd05172c7f09329",
            },
            ["0.19.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.2/openkal-platform-0.19.2.tar.gz",
                },
                sha256 = "526c58958f31cc55d5e29b861da57c3c528d34cb2c773a4f608cd77d9778f1db",
            },
            ["0.19.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.1/openkal-platform-0.19.1.tar.gz",
                },
                sha256 = "09d44014d48bc65ac1b59a7c6c8d034c4e6315c8d0d8e76657282501fd10e237",
            },
            ["0.19.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.19.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.19.0/openkal-platform-0.19.0.tar.gz",
                },
                sha256 = "90f435a8e51def20f93cbbec84f93c06ddc20f65a0b10a460d74bea4a5f26f3a",
            },
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.18.0/openkal-platform-0.18.0.tar.gz",
                },
                sha256 = "8a25e101e1a7b15c41756134cb7f83d7f55864eeaa9e24a416e0fd3b0bc2f103",
            },
            ["0.17.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.3/openkal-platform-0.17.3.tar.gz",
                },
                sha256 = "36dcf9aa34cc664e12627176c5844bc64c2d386b576712022955c884577ba4ea",
            },
            ["0.17.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.2/openkal-platform-0.17.2.tar.gz",
                },
                sha256 = "e6f920b1907c1c6927e90b993ea4917620bfa1bec41ebf78b29cb79aec322038",
            },
            ["0.17.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.1/openkal-platform-0.17.1.tar.gz",
                },
                sha256 = "db006660fff2b34ff39dfa570774afac15b392e30ebcadd34675f88ea6a60b50",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
