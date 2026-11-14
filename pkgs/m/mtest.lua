-- mtest --- mcpplibs.mtest, the C++ library of the mtest test system.
--
-- One of the packages of mcpp-community/mtest, which share one tag and one
-- archive; each descriptor names its member's manifest. Cases, expectations,
-- fixtures and attributes with no macro and no header; a program built with it
-- speaks the mtest test protocol (spec/protocol.md), and its entry begins a
-- test file that defines no `main` (mcpp 2026.11.8.1 and later).
--
-- 0.6.0 implements the mcpp test spec's optional capabilities (mcpp
-- docs/specs/test.md): each case's checks and output, and a test session the
-- engine serves (`mtest serve`); its entry states them (`test-capabilities`,
-- `test-session`), which mcpp 2026.11.10.1 reads and an earlier mcpp ignores.
--
-- 0.6.3 runs a conformance suite against a subject (`mcpplibs.mtest.cts`:
-- `cts::against`, `cts::needs`): a case that needs what the subject states it
-- lacks is skipped as unsupported, and what the run requires and the subject
-- lacks fails; the protocol is unchanged. It carries 0.6.1 (`skip_exit`) and
-- 0.6.2 (the sources write the version the manifests state).
--
-- 0.7.0 adds to `mcpplibs.mtest.e2e` the matchers that carry a session
-- (`succeeded`, `exited`, `contains`, `matches`, `shell_line`) and an
-- interactive session over one pipe (`e2e::session`: expect and send); the
-- engine's capabilities, coverage, plan and resume are the program's.
--
-- 0.7.1 states `mcpplibs.mtest.e2e`, `.bench` and `.cts` as public modules (each
-- a feature on by default), so a program that imports one builds against the
-- packed library as from source.
--
-- 0.7.2 adds `bench::each` to `mcpplibs.mtest.bench`: every call measured by
-- itself (`name`, `.p95`, `.p99`, `.max`, `.mean`, `.per_item`), with a lap that
-- pauses and states items.
--
-- 0.8.0 states where a case runs (`only{}`, `except{}` over mcpplibs.os's
-- platforms and architectures) and what it needs of the machine (`capability`,
-- declared in code and answered by the program under any runner).
--
-- 0.8.3 (with 0.8.1's and 0.8.2's content, which were not indexed) has a measured
-- call say what it was made of (parts, times, values, the slowest calls, a
-- count over a limit, allocations), measures as a loop (`bench::laps`), prints
-- the numbers where a program runs alone, and selects there by identifier,
-- name or pattern.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "mtest",
    description = "mcpplibs.mtest: the C++ test library of mtest --- cases, expectations, fixtures, bench, conformance and end-to-end helpers, with no macro and no header, speaking the mtest test protocol",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpp-community/mtest",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/mcpp-community/mtest/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.8.3/mtest-v0.8.3.tar.gz",
                },
                sha256 = "f61fb09b2ddab8db8c8cd4fcfb1125306d00d6719769ca78379e4ba727a59a8c",
            },
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.8.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.8.0/mtest-v0.8.0.tar.gz",
                },
                sha256 = "6ea516f470ae0aeea49039c071dda97b1403d71577539530d95fa0b959d12f26",
            },
            ["0.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.2/mtest-v0.7.2.tar.gz",
                },
                sha256 = "c4e6e3d526da16f4f0ce983e4ccf5a3470ce2e603dd49cfb779ade58dd9e705a",
            },
            ["0.7.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.1/mtest-v0.7.1.tar.gz",
                },
                sha256 = "4cf903fc883162c0e498946d2bcdd650ad82aa3e3c4b88f88d07a8543230fe09",
            },
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.0/mtest-v0.7.0.tar.gz",
                },
                sha256 = "ab312f844066e6070c929be3eabee9091a903b550b8220c8c59d098e17b42bd6",
            },
            ["0.6.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.3/mtest-v0.6.3.tar.gz",
                },
                sha256 = "a41e5001e40098beacb92d62f92b4f09d0e5dd2113fb98eda5e949af277cbaa2",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.0/mtest-v0.6.0.tar.gz",
                },
                sha256 = "eb90f823b4b2c6e4407110cd7c4bac290b683fdf3c1b6b471a58e9e7016b5472",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.2/mtest-v0.5.2.tar.gz",
                },
                sha256 = "e61819239dca14d3c987f554b8c09e5bc248fdb8bba2650adb53e775db2ccf93",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.1/mtest-v0.5.1.tar.gz",
                },
                sha256 = "48625c19d548aa4e90bf658f895fe99c10bf9316efaa3354d4cb65df9ccd7324",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.0/mtest-v0.5.0.tar.gz",
                },
                sha256 = "586d8a2f4fb5d335583642ccc0ccfc20a0600e8886eebf07707e959bbd3e9b47",
            },
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.1/mtest-v0.4.1.tar.gz",
                },
                sha256 = "c0a769eba5d36d5c70186fe6cb8092b2f2237b5526a694d4f14581fe81eb8c86",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.0/mtest-v0.4.0.tar.gz",
                },
                sha256 = "9c90fc7b225a5d0dc562070cf3c2d1336a391c77b56755d62854bc38d2c88040",
            },
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.3.0/mtest-v0.3.0.tar.gz",
                },
                sha256 = "b695022706d5fac107918c1d9461b953a8f462c63b78acacf52ea427e7009187",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.2.0/mtest-v0.2.0.tar.gz",
                },
                sha256 = "600f52ff1b55489b012c16174fcded3dc9b9aea112377c783a2c9425072e03d2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.1.0/mtest-v0.1.0.tar.gz",
                },
                sha256 = "2e09528d97173371e0238c720cb8ac80602241f4e05d55d3acb12f21b5c95c75",
            },
        },
        macosx = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.8.3/mtest-v0.8.3.tar.gz",
                },
                sha256 = "f61fb09b2ddab8db8c8cd4fcfb1125306d00d6719769ca78379e4ba727a59a8c",
            },
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.8.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.8.0/mtest-v0.8.0.tar.gz",
                },
                sha256 = "6ea516f470ae0aeea49039c071dda97b1403d71577539530d95fa0b959d12f26",
            },
            ["0.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.2/mtest-v0.7.2.tar.gz",
                },
                sha256 = "c4e6e3d526da16f4f0ce983e4ccf5a3470ce2e603dd49cfb779ade58dd9e705a",
            },
            ["0.7.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.1/mtest-v0.7.1.tar.gz",
                },
                sha256 = "4cf903fc883162c0e498946d2bcdd650ad82aa3e3c4b88f88d07a8543230fe09",
            },
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.0/mtest-v0.7.0.tar.gz",
                },
                sha256 = "ab312f844066e6070c929be3eabee9091a903b550b8220c8c59d098e17b42bd6",
            },
            ["0.6.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.3/mtest-v0.6.3.tar.gz",
                },
                sha256 = "a41e5001e40098beacb92d62f92b4f09d0e5dd2113fb98eda5e949af277cbaa2",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.0/mtest-v0.6.0.tar.gz",
                },
                sha256 = "eb90f823b4b2c6e4407110cd7c4bac290b683fdf3c1b6b471a58e9e7016b5472",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.2/mtest-v0.5.2.tar.gz",
                },
                sha256 = "e61819239dca14d3c987f554b8c09e5bc248fdb8bba2650adb53e775db2ccf93",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.1/mtest-v0.5.1.tar.gz",
                },
                sha256 = "48625c19d548aa4e90bf658f895fe99c10bf9316efaa3354d4cb65df9ccd7324",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.0/mtest-v0.5.0.tar.gz",
                },
                sha256 = "586d8a2f4fb5d335583642ccc0ccfc20a0600e8886eebf07707e959bbd3e9b47",
            },
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.1/mtest-v0.4.1.tar.gz",
                },
                sha256 = "c0a769eba5d36d5c70186fe6cb8092b2f2237b5526a694d4f14581fe81eb8c86",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.0/mtest-v0.4.0.tar.gz",
                },
                sha256 = "9c90fc7b225a5d0dc562070cf3c2d1336a391c77b56755d62854bc38d2c88040",
            },
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.3.0/mtest-v0.3.0.tar.gz",
                },
                sha256 = "b695022706d5fac107918c1d9461b953a8f462c63b78acacf52ea427e7009187",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.2.0/mtest-v0.2.0.tar.gz",
                },
                sha256 = "600f52ff1b55489b012c16174fcded3dc9b9aea112377c783a2c9425072e03d2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.1.0/mtest-v0.1.0.tar.gz",
                },
                sha256 = "2e09528d97173371e0238c720cb8ac80602241f4e05d55d3acb12f21b5c95c75",
            },
        },
        windows = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.8.3/mtest-v0.8.3.tar.gz",
                },
                sha256 = "f61fb09b2ddab8db8c8cd4fcfb1125306d00d6719769ca78379e4ba727a59a8c",
            },
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.8.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.8.0/mtest-v0.8.0.tar.gz",
                },
                sha256 = "6ea516f470ae0aeea49039c071dda97b1403d71577539530d95fa0b959d12f26",
            },
            ["0.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.2/mtest-v0.7.2.tar.gz",
                },
                sha256 = "c4e6e3d526da16f4f0ce983e4ccf5a3470ce2e603dd49cfb779ade58dd9e705a",
            },
            ["0.7.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.1/mtest-v0.7.1.tar.gz",
                },
                sha256 = "4cf903fc883162c0e498946d2bcdd650ad82aa3e3c4b88f88d07a8543230fe09",
            },
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.0/mtest-v0.7.0.tar.gz",
                },
                sha256 = "ab312f844066e6070c929be3eabee9091a903b550b8220c8c59d098e17b42bd6",
            },
            ["0.6.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.3/mtest-v0.6.3.tar.gz",
                },
                sha256 = "a41e5001e40098beacb92d62f92b4f09d0e5dd2113fb98eda5e949af277cbaa2",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.0/mtest-v0.6.0.tar.gz",
                },
                sha256 = "eb90f823b4b2c6e4407110cd7c4bac290b683fdf3c1b6b471a58e9e7016b5472",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.2/mtest-v0.5.2.tar.gz",
                },
                sha256 = "e61819239dca14d3c987f554b8c09e5bc248fdb8bba2650adb53e775db2ccf93",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.1/mtest-v0.5.1.tar.gz",
                },
                sha256 = "48625c19d548aa4e90bf658f895fe99c10bf9316efaa3354d4cb65df9ccd7324",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.0/mtest-v0.5.0.tar.gz",
                },
                sha256 = "586d8a2f4fb5d335583642ccc0ccfc20a0600e8886eebf07707e959bbd3e9b47",
            },
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.1/mtest-v0.4.1.tar.gz",
                },
                sha256 = "c0a769eba5d36d5c70186fe6cb8092b2f2237b5526a694d4f14581fe81eb8c86",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.0/mtest-v0.4.0.tar.gz",
                },
                sha256 = "9c90fc7b225a5d0dc562070cf3c2d1336a391c77b56755d62854bc38d2c88040",
            },
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.3.0/mtest-v0.3.0.tar.gz",
                },
                sha256 = "b695022706d5fac107918c1d9461b953a8f462c63b78acacf52ea427e7009187",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.2.0/mtest-v0.2.0.tar.gz",
                },
                sha256 = "600f52ff1b55489b012c16174fcded3dc9b9aea112377c783a2c9425072e03d2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.1.0/mtest-v0.1.0.tar.gz",
                },
                sha256 = "2e09528d97173371e0238c720cb8ac80602241f4e05d55d3acb12f21b5c95c75",
            },
        },
    },

    mcpp = "*/lib/mcpp.toml",
}
