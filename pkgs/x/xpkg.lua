-- Form A descriptor: the upstream repo ships its own mcpp.toml from
-- v0.0.39 onwards, so we omit the `mcpp` field — mcpp default-look-up
-- finds <verdir>/libxpkg-<tag>/mcpp.toml inside the GitHub tarball wrap.
package = {
    spec        = "1",
    namespace = "mcpplibs",
    name        = "xpkg",
    description = "C++23 reference implementation of the xpkg V1 spec — `import mcpplibs.xpkg;`",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/openxlings/libxpkg",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.51"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.51.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.51/xpkg-0.0.51.tar.gz",
                },
                sha256 = "d347eabb5c04433bfd9c9dfdfe52cf2a24eac6836e44721eebf21f7d3ca9b738",
            },
            ["0.0.50"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.50.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.50/xpkg-0.0.50.tar.gz",
                },
                sha256 = "add16d5c36796b5550f55924dc5eae7a17dcb20a33fd07aa77cd95d0899b3e5e",
            },
            ["0.0.49"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.49.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.49/xpkg-0.0.49.tar.gz",
                },
                sha256 = "45f23d16aba01833cc38ad4a2a117ab2646d9c0edad5f4c9eafecc53a70457ff",
            },
            ["0.0.48"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.48.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.48/xpkg-0.0.48.tar.gz",
                },
                sha256 = "0ceb6e85c17f0e4b32942193edceb1cbe2ad929742af7f0b10133c7f01da39e4",
            },
            ["0.0.47"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.47.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.47/xpkg-0.0.47.tar.gz",
                },
                sha256 = "fe879e8f52ea5a7f316ca54bca1fa393febb8e2a23a3de852b0c2be1918a0be9",
            },
            ["0.0.46"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.46.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.46/xpkg-0.0.46.tar.gz",
                },
                sha256 = "6ffbc16108458d47f377ec6046dcf4c67f9a1d3815fc59ea331e39f31906dba0",
            },
            ["0.0.45"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.45.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.45/xpkg-0.0.45.tar.gz",
                },
                sha256 = "8a21ffe14c368834e1b135fc2977f499628845049fb161dff8743e3b96e858fa",
            },
            ["0.0.44"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.44.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.44/xpkg-0.0.44.tar.gz",
                },
                sha256 = "152a27425ba418312182bddb316c8c5bc636bbd8a37faf30e75390dc844e2e95",
            },
            ["0.0.42"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.42.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.42/xpkg-0.0.42.tar.gz",
                },
                sha256 = "5f8732abf9b768c2ac6c210a5ff03982cffaf1f889cf700e5df39545920ca665",
            },
            ["0.0.41"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.41.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.41/xpkg-0.0.41.tar.gz",
                },
                sha256 = "d4a0dc6df0388858415cf6899dd1aa6d5d8b9836f1f81c9687b0b34fb7ee0e2e",
            },
            ["0.0.40"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.40.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.40/xpkg-0.0.40.tar.gz",
                },
                sha256 = "95fd6d7b2c044578830015fd5b1dceaafd5c0dbadc04a0c78e82d380405e193f",
            },
            ["0.0.39"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.39.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.39/xpkg-0.0.39.tar.gz",
                },
                sha256 = "292d6a85da95b3615cc96f8e2e64dbe7767d059d8a8e9422bbc72db648f81f71",
            },
        },
        macosx = {
            ["0.0.51"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.51.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.51/xpkg-0.0.51.tar.gz",
                },
                sha256 = "d347eabb5c04433bfd9c9dfdfe52cf2a24eac6836e44721eebf21f7d3ca9b738",
            },
            ["0.0.50"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.50.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.50/xpkg-0.0.50.tar.gz",
                },
                sha256 = "add16d5c36796b5550f55924dc5eae7a17dcb20a33fd07aa77cd95d0899b3e5e",
            },
            ["0.0.49"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.49.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.49/xpkg-0.0.49.tar.gz",
                },
                sha256 = "45f23d16aba01833cc38ad4a2a117ab2646d9c0edad5f4c9eafecc53a70457ff",
            },
            ["0.0.48"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.48.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.48/xpkg-0.0.48.tar.gz",
                },
                sha256 = "0ceb6e85c17f0e4b32942193edceb1cbe2ad929742af7f0b10133c7f01da39e4",
            },
            ["0.0.47"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.47.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.47/xpkg-0.0.47.tar.gz",
                },
                sha256 = "fe879e8f52ea5a7f316ca54bca1fa393febb8e2a23a3de852b0c2be1918a0be9",
            },
            ["0.0.46"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.46.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.46/xpkg-0.0.46.tar.gz",
                },
                sha256 = "6ffbc16108458d47f377ec6046dcf4c67f9a1d3815fc59ea331e39f31906dba0",
            },
            ["0.0.45"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.45.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.45/xpkg-0.0.45.tar.gz",
                },
                sha256 = "8a21ffe14c368834e1b135fc2977f499628845049fb161dff8743e3b96e858fa",
            },
            ["0.0.44"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.44.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.44/xpkg-0.0.44.tar.gz",
                },
                sha256 = "152a27425ba418312182bddb316c8c5bc636bbd8a37faf30e75390dc844e2e95",
            },
            ["0.0.42"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.42.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.42/xpkg-0.0.42.tar.gz",
                },
                sha256 = "5f8732abf9b768c2ac6c210a5ff03982cffaf1f889cf700e5df39545920ca665",
            },
            ["0.0.41"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.41.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.41/xpkg-0.0.41.tar.gz",
                },
                sha256 = "d4a0dc6df0388858415cf6899dd1aa6d5d8b9836f1f81c9687b0b34fb7ee0e2e",
            },
            ["0.0.40"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.40.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.40/xpkg-0.0.40.tar.gz",
                },
                sha256 = "95fd6d7b2c044578830015fd5b1dceaafd5c0dbadc04a0c78e82d380405e193f",
            },
            ["0.0.39"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.39.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.39/xpkg-0.0.39.tar.gz",
                },
                sha256 = "292d6a85da95b3615cc96f8e2e64dbe7767d059d8a8e9422bbc72db648f81f71",
            },
        },
        windows = {
            ["0.0.51"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.51.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.51/xpkg-0.0.51.tar.gz",
                },
                sha256 = "d347eabb5c04433bfd9c9dfdfe52cf2a24eac6836e44721eebf21f7d3ca9b738",
            },
            ["0.0.50"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.50.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.50/xpkg-0.0.50.tar.gz",
                },
                sha256 = "add16d5c36796b5550f55924dc5eae7a17dcb20a33fd07aa77cd95d0899b3e5e",
            },
            ["0.0.49"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.49.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.49/xpkg-0.0.49.tar.gz",
                },
                sha256 = "45f23d16aba01833cc38ad4a2a117ab2646d9c0edad5f4c9eafecc53a70457ff",
            },
            ["0.0.48"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.48.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.48/xpkg-0.0.48.tar.gz",
                },
                sha256 = "0ceb6e85c17f0e4b32942193edceb1cbe2ad929742af7f0b10133c7f01da39e4",
            },
            ["0.0.47"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.47.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.47/xpkg-0.0.47.tar.gz",
                },
                sha256 = "fe879e8f52ea5a7f316ca54bca1fa393febb8e2a23a3de852b0c2be1918a0be9",
            },
            ["0.0.46"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.46.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.46/xpkg-0.0.46.tar.gz",
                },
                sha256 = "6ffbc16108458d47f377ec6046dcf4c67f9a1d3815fc59ea331e39f31906dba0",
            },
            ["0.0.45"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/0.0.45.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.45/xpkg-0.0.45.tar.gz",
                },
                sha256 = "8a21ffe14c368834e1b135fc2977f499628845049fb161dff8743e3b96e858fa",
            },
            ["0.0.44"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.44.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.44/xpkg-0.0.44.tar.gz",
                },
                sha256 = "152a27425ba418312182bddb316c8c5bc636bbd8a37faf30e75390dc844e2e95",
            },
            ["0.0.42"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.42.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.42/xpkg-0.0.42.tar.gz",
                },
                sha256 = "5f8732abf9b768c2ac6c210a5ff03982cffaf1f889cf700e5df39545920ca665",
            },
            ["0.0.41"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.41.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.41/xpkg-0.0.41.tar.gz",
                },
                sha256 = "d4a0dc6df0388858415cf6899dd1aa6d5d8b9836f1f81c9687b0b34fb7ee0e2e",
            },
            ["0.0.40"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.40.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.40/xpkg-0.0.40.tar.gz",
                },
                sha256 = "95fd6d7b2c044578830015fd5b1dceaafd5c0dbadc04a0c78e82d380405e193f",
            },
            ["0.0.39"] = {
                url    = {
                    GLOBAL = "https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.39.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.39/xpkg-0.0.39.tar.gz",
                },
                sha256 = "292d6a85da95b3615cc96f8e2e64dbe7767d059d8a8e9422bbc72db648f81f71",
            },
        },
    },
}
