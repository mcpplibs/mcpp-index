-- Form A descriptor: the upstream repo ships its own mcpp.toml from
-- v0.2.1 onwards, so we omit the `mcpp` field — mcpp default-look-up
-- finds <verdir>/<repo-tag>/mcpp.toml inside the GitHub tarball wrap.
package = {
    spec        = "1",
    namespace = "mcpplibs",
    name        = "mcpplibs.tinyhttps",
    description = "Minimal C++23 HTTP/HTTPS client with SSE streaming support",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/tinyhttps",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.1/tinyhttps-0.2.1.tar.gz",
                },
                sha256 = "88adc68b1c1ec635c409604547fdfe8486aa1b376bad28c74858ed1f3ce5391c",
            },
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.2/tinyhttps-0.2.2.tar.gz",
                },
                sha256 = "bc4cb59475826a975dd0408b59a00cf41c4aa4078a0fc2e54929bde7fb696248",
            },
            ["0.2.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.3/tinyhttps-0.2.3.tar.gz",
                },
                sha256 = "67ff75050d31157d3c35562187c9fb622e66167c98bb950cebb51db9b07ebe97",
            },
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.4/tinyhttps-0.2.4.tar.gz",
                },
                sha256 = "e9aa33ca770b5a8a651907fade26d6f4dc34aa8cb6605bae9eef096d30703992",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.5/tinyhttps-0.2.5.tar.gz",
                },
                sha256 = "87084c23d151818e35ba68821b5e54502e1f454cfa2145f246fb55637edebf93",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.6/tinyhttps-0.2.6.tar.gz",
                },
                sha256 = "5e0bbc4b7f2021c7b042f396908ad67f0f733dbbc2d5b85f98656e3d90ee6206",
            },
            ["0.2.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.7/tinyhttps-0.2.7.tar.gz",
                },
                sha256 = "c8444d0974e8b743c2c842da2b656c9d4378e1a1ebed152a7099d824d28b983b",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.8/tinyhttps-0.2.8.tar.gz",
                },
                sha256 = "a3d72396b267820405b675dd89c0889ef72605e3eedb94e000c6f48479b38001",
            },
            ["0.2.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.9/tinyhttps-0.2.9.tar.gz",
                },
                sha256 = "b17e0b15d2c205a2918708bcd3ac992384f1a38d03232c28f17190a1db081e54",
            },
        },
        macosx = {
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.1/tinyhttps-0.2.1.tar.gz",
                },
                sha256 = "88adc68b1c1ec635c409604547fdfe8486aa1b376bad28c74858ed1f3ce5391c",
            },
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.2/tinyhttps-0.2.2.tar.gz",
                },
                sha256 = "bc4cb59475826a975dd0408b59a00cf41c4aa4078a0fc2e54929bde7fb696248",
            },
            ["0.2.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.3/tinyhttps-0.2.3.tar.gz",
                },
                sha256 = "67ff75050d31157d3c35562187c9fb622e66167c98bb950cebb51db9b07ebe97",
            },
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.4/tinyhttps-0.2.4.tar.gz",
                },
                sha256 = "e9aa33ca770b5a8a651907fade26d6f4dc34aa8cb6605bae9eef096d30703992",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.5/tinyhttps-0.2.5.tar.gz",
                },
                sha256 = "87084c23d151818e35ba68821b5e54502e1f454cfa2145f246fb55637edebf93",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.6/tinyhttps-0.2.6.tar.gz",
                },
                sha256 = "5e0bbc4b7f2021c7b042f396908ad67f0f733dbbc2d5b85f98656e3d90ee6206",
            },
            ["0.2.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.7/tinyhttps-0.2.7.tar.gz",
                },
                sha256 = "c8444d0974e8b743c2c842da2b656c9d4378e1a1ebed152a7099d824d28b983b",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.8/tinyhttps-0.2.8.tar.gz",
                },
                sha256 = "a3d72396b267820405b675dd89c0889ef72605e3eedb94e000c6f48479b38001",
            },
            ["0.2.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.9/tinyhttps-0.2.9.tar.gz",
                },
                sha256 = "b17e0b15d2c205a2918708bcd3ac992384f1a38d03232c28f17190a1db081e54",
            },
        },
        windows = {
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.1/tinyhttps-0.2.1.tar.gz",
                },
                sha256 = "88adc68b1c1ec635c409604547fdfe8486aa1b376bad28c74858ed1f3ce5391c",
            },
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.2/tinyhttps-0.2.2.tar.gz",
                },
                sha256 = "bc4cb59475826a975dd0408b59a00cf41c4aa4078a0fc2e54929bde7fb696248",
            },
            ["0.2.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.3/tinyhttps-0.2.3.tar.gz",
                },
                sha256 = "67ff75050d31157d3c35562187c9fb622e66167c98bb950cebb51db9b07ebe97",
            },
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.4/tinyhttps-0.2.4.tar.gz",
                },
                sha256 = "e9aa33ca770b5a8a651907fade26d6f4dc34aa8cb6605bae9eef096d30703992",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.5/tinyhttps-0.2.5.tar.gz",
                },
                sha256 = "87084c23d151818e35ba68821b5e54502e1f454cfa2145f246fb55637edebf93",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.6/tinyhttps-0.2.6.tar.gz",
                },
                sha256 = "5e0bbc4b7f2021c7b042f396908ad67f0f733dbbc2d5b85f98656e3d90ee6206",
            },
            ["0.2.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.7/tinyhttps-0.2.7.tar.gz",
                },
                sha256 = "c8444d0974e8b743c2c842da2b656c9d4378e1a1ebed152a7099d824d28b983b",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.8/tinyhttps-0.2.8.tar.gz",
                },
                sha256 = "a3d72396b267820405b675dd89c0889ef72605e3eedb94e000c6f48479b38001",
            },
            ["0.2.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.9/tinyhttps-0.2.9.tar.gz",
                },
                sha256 = "b17e0b15d2c205a2918708bcd3ac992384f1a38d03232c28f17190a1db081e54",
            },
        },
    },
}
