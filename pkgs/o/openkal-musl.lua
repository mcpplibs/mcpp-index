-- openkal-musl --- musl 1.2.5 above openkal rather than above one kernel.
--
-- The version line continues rather than restarting. This repository was
-- `openkal-libc' up to 0.2.0, and those tags are still in it; a package that
-- restarted at 0.1.0 would give one tag two meanings, which is the one thing a
-- release chain cannot allow. The earlier name keeps its own descriptor so that
-- a project pinned to it continues to resolve, and nothing is added to it.
--
-- No `deps'. The package names the specification it is written against and the
-- implementation of openkal for the target being built, both in its own
-- manifest --- because a C library is the one consumer that knows the program
-- above it carries no other runtime, and that is what selects the
-- implementation's `standalone' feature.
--
-- The consequence for a program is that it names this package and nothing else.
--
-- 0.17.0 states what this library does NOT supply: a top-level
-- `[c-abi-absent]` table of 24 rows, each naming the shape in which that
-- absence reaches a program (`link`, `enosys`, `accepted-no-effect`), with
-- the package's own CI asserting every row against the objects it builds.
-- It also moves the implementation pins to openkal-linux 0.15.0 and
-- openkal-windows 0.10.0. No source changed.
--
-- 0.19.0 reads `__MCPP_TARGET_WINDOWS__` in `bits/setjmp.h`, the INSTALLED
-- header that sizes `jmp_buf` by the target's calling convention, keeping
-- `|| defined(__CYGWIN__)` beside it. Two operands cover every engine and the
-- order of releases does not matter: mcpp up to 2026.9.21.1 defines the
-- borrowed name, the release that withdraws it defines mcpp's own, and no
-- engine defines neither. No source of musl itself changed.
--
-- IT ASKS NOTHING OF `index.toml`'s `min_mcpp`, AND THAT WAS MEASURED. mcpp
-- ignores a top-level table it does not know and refuses an unknown MEMBER of
-- a table it does know, so the first spelling of this table --- `[c-abi]`.`absent`
-- --- made every engine below 2026.9.20.1 refuse the whole manifest on every
-- target. Measured against the published 2026.9.18.3 archive on this exact
-- manifest; the table moved to the top level, and openkal-musl's own CI now
-- builds 0.17.0 green with that same published 2026.9.18.3. A client stopped
-- below 2026.9.20.1 therefore keeps this package and loses only the note mcpp
-- would have attached to a link that failed at one of these names.
--
-- (An earlier revision of this comment said 0.15.0 was pending and unlisted.
-- It had been released and registered; a note claiming a published version
-- does not exist reads as missing data rather than as a stale sentence.)
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-musl",
    description = "musl 1.2.5 redirected onto openkal: one C library, ported once, above every implementation of the specification rather than above one kernel",
    licenses    = {"Apache-2.0", "MIT"},
    repo        = "https://github.com/mcpplibs/openkal-musl",
    type        = "package",

    xpm = {
        linux = {
            ["0.19.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.0/openkal-musl-0.19.0.tar.gz",
                },
                sha256 = "a7ff6615a9111ab829dfc175154384b6bc743b4b1f936c0fca22e6cabed4a516",
            },
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.18.0/openkal-musl-0.18.0.tar.gz",
                },
                sha256 = "67eeaa9b1d9813d284f498322422f953448afcf53673645af86d53e4c980d377",
            },
            ["0.17.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.17.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.17.0/openkal-musl-0.17.0.tar.gz",
                },
                sha256 = "201932848af47311dd6610c9acf6b35d193559cea64cf5f620c246656f2ccc05",
            },
            ["0.16.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.16.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.16.0/openkal-musl-0.16.0.tar.gz",
                },
                sha256 = "8ffa4a2a79fcc7fe7565c1e69624b9d3b575020ed97d2043e20cdf542d519105",
            },
            ["0.15.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.15.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.15.0/openkal-musl-0.15.0.tar.gz",
                },
                sha256 = "ee953bd8ff39822ecc66e67faa3a37efdab3703e097e85c6e422e51e084ca8b6",
            },
            ["0.14.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.14.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.14.0/openkal-musl-0.14.0.tar.gz",
                },
                sha256 = "91e747f495e041846c48522a3a5a2061ce6fd8f81e4b4e60f54cfaec4358bd66",
            },
            ["0.13.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.5/openkal-musl-0.13.5.tar.gz",
                },
                sha256 = "4ca2ace91d0af248b90f2f6e1534bbb78eac7381c24d691d1de91f879670e8c8",
            },
            ["0.13.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.4/openkal-musl-0.13.4.tar.gz",
                },
                sha256 = "bea25da11a7c074082439fd5561e288f3e6e0f75cc8d965da8187848d3193f48",
            },
            ["0.13.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.3/openkal-musl-0.13.3.tar.gz",
                },
                sha256 = "4f47f9b0c09a7dd7717e8e6c2933ac909f2bc1ced40fb17420f44501f55ffcf0",
            },
            ["0.13.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.2/openkal-musl-0.13.2.tar.gz",
                },
                sha256 = "7c21fc51063951a1f19215410c0bdebcd6d510242f82678fa4be913ae56351aa",
            },
            ["0.13.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.1/openkal-musl-0.13.1.tar.gz",
                },
                sha256 = "6acdb824c83ccb5eec384be0f3261ce49bc10c6b66707092334487554979b332",
            },
            ["0.13.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.0/openkal-musl-0.13.0.tar.gz",
                },
                sha256 = "0bfdeeafef1f9aecaa2d77df19366ecfffe62179329b7dfcc43114cc897d4e1f",
            },
            ["0.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.12.0/openkal-musl-0.12.0.tar.gz",
                },
                sha256 = "2727f10d2ebffb05d87d82525fe4755ed4eb02fdaf55eb816179a0628e9de5de",
            },
            ["0.11.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.11.0/openkal-musl-0.11.0.tar.gz",
                },
                sha256 = "6b9212b047ae9a8995582baf59402bf29b46c3a2ff0a0c39c318a91db3013d4d",
            },
            ["0.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.10.0/openkal-musl-0.10.0.tar.gz",
                },
                sha256 = "c5e151aa63e63ce0f13c6fc28bfd26004a9a305b4f1973ee2888ec871c68ee8f",
            },
            ["0.9.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.9.0/openkal-musl-0.9.0.tar.gz",
                },
                sha256 = "18e63f25ac0ccde6057ca0028e33630790a6268d83ca0eca03fc81fde818dc1a",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.8.0/openkal-musl-0.8.0.tar.gz",
                },
                sha256 = "1a54c2696ad0118efb632c6eddf8659f85484c42574a82abf604783d00b6db0c",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.7.0/openkal-musl-0.7.0.tar.gz",
                },
                sha256 = "e66bf5a2fac456a1ca40f53856d8908f256145a9a5093a052e29760a6580c730",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.6.0/openkal-musl-0.6.0.tar.gz",
                },
                sha256 = "ca7696638c7387f8391947443c6fbfeb6f0c86021a07a15ac6b82b39c6616c86",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.5.0/openkal-musl-0.5.0.tar.gz",
                },
                sha256 = "315238f2f15fb486816e570aa6a549284daa248a5206b332b67ada4ecad4426b",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.4.0/openkal-musl-0.4.0.tar.gz",
                },
                sha256 = "aa29225b7a71fb9d81b3f356f4ac21d89ad0a87d9229a8e42b29f807208519c3",
            },
            ["0.3.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.5/openkal-musl-0.3.5.tar.gz",
                },
                sha256 = "0f8335633d230f0989db6083f5d5dff35a11d32fac940281dc886e3ba7bb6a55",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.4/openkal-musl-0.3.4.tar.gz",
                },
                sha256 = "a2c17775bc17d2c981dca624bebe1661e6d1662844f2cecf7d465c2828a27249",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.3/openkal-musl-0.3.3.tar.gz",
                },
                sha256 = "1a5ebc69bae296b98783719e2db242ae17a118e4ee35e73b1ad836bc94afedca",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.2/openkal-musl-0.3.2.tar.gz",
                },
                sha256 = "35246bf4326e0f4c9b606ae1934b5f7752cfc10832a7039d71291f7c5707d886",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.1/openkal-musl-0.3.1.tar.gz",
                },
                sha256 = "c09c6f4f29b9121be2dba69959043fef4effe52807215882c9f2e62644f9331b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
        macosx = {
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.18.0/openkal-musl-0.18.0.tar.gz",
                },
                sha256 = "67eeaa9b1d9813d284f498322422f953448afcf53673645af86d53e4c980d377",
            },
            ["0.17.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.17.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.17.0/openkal-musl-0.17.0.tar.gz",
                },
                sha256 = "201932848af47311dd6610c9acf6b35d193559cea64cf5f620c246656f2ccc05",
            },
            ["0.16.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.16.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.16.0/openkal-musl-0.16.0.tar.gz",
                },
                sha256 = "8ffa4a2a79fcc7fe7565c1e69624b9d3b575020ed97d2043e20cdf542d519105",
            },
            ["0.15.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.15.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.15.0/openkal-musl-0.15.0.tar.gz",
                },
                sha256 = "ee953bd8ff39822ecc66e67faa3a37efdab3703e097e85c6e422e51e084ca8b6",
            },
            ["0.14.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.14.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.14.0/openkal-musl-0.14.0.tar.gz",
                },
                sha256 = "91e747f495e041846c48522a3a5a2061ce6fd8f81e4b4e60f54cfaec4358bd66",
            },
            ["0.13.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.5/openkal-musl-0.13.5.tar.gz",
                },
                sha256 = "4ca2ace91d0af248b90f2f6e1534bbb78eac7381c24d691d1de91f879670e8c8",
            },
            ["0.13.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.4/openkal-musl-0.13.4.tar.gz",
                },
                sha256 = "bea25da11a7c074082439fd5561e288f3e6e0f75cc8d965da8187848d3193f48",
            },
            ["0.13.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.3/openkal-musl-0.13.3.tar.gz",
                },
                sha256 = "4f47f9b0c09a7dd7717e8e6c2933ac909f2bc1ced40fb17420f44501f55ffcf0",
            },
            ["0.13.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.2/openkal-musl-0.13.2.tar.gz",
                },
                sha256 = "7c21fc51063951a1f19215410c0bdebcd6d510242f82678fa4be913ae56351aa",
            },
            ["0.13.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.1/openkal-musl-0.13.1.tar.gz",
                },
                sha256 = "6acdb824c83ccb5eec384be0f3261ce49bc10c6b66707092334487554979b332",
            },
            ["0.13.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.0/openkal-musl-0.13.0.tar.gz",
                },
                sha256 = "0bfdeeafef1f9aecaa2d77df19366ecfffe62179329b7dfcc43114cc897d4e1f",
            },
            ["0.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.12.0/openkal-musl-0.12.0.tar.gz",
                },
                sha256 = "2727f10d2ebffb05d87d82525fe4755ed4eb02fdaf55eb816179a0628e9de5de",
            },
            ["0.11.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.11.0/openkal-musl-0.11.0.tar.gz",
                },
                sha256 = "6b9212b047ae9a8995582baf59402bf29b46c3a2ff0a0c39c318a91db3013d4d",
            },
            ["0.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.10.0/openkal-musl-0.10.0.tar.gz",
                },
                sha256 = "c5e151aa63e63ce0f13c6fc28bfd26004a9a305b4f1973ee2888ec871c68ee8f",
            },
            ["0.9.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.9.0/openkal-musl-0.9.0.tar.gz",
                },
                sha256 = "18e63f25ac0ccde6057ca0028e33630790a6268d83ca0eca03fc81fde818dc1a",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.8.0/openkal-musl-0.8.0.tar.gz",
                },
                sha256 = "1a54c2696ad0118efb632c6eddf8659f85484c42574a82abf604783d00b6db0c",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.7.0/openkal-musl-0.7.0.tar.gz",
                },
                sha256 = "e66bf5a2fac456a1ca40f53856d8908f256145a9a5093a052e29760a6580c730",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.6.0/openkal-musl-0.6.0.tar.gz",
                },
                sha256 = "ca7696638c7387f8391947443c6fbfeb6f0c86021a07a15ac6b82b39c6616c86",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.5.0/openkal-musl-0.5.0.tar.gz",
                },
                sha256 = "315238f2f15fb486816e570aa6a549284daa248a5206b332b67ada4ecad4426b",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.4.0/openkal-musl-0.4.0.tar.gz",
                },
                sha256 = "aa29225b7a71fb9d81b3f356f4ac21d89ad0a87d9229a8e42b29f807208519c3",
            },
            ["0.3.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.5/openkal-musl-0.3.5.tar.gz",
                },
                sha256 = "0f8335633d230f0989db6083f5d5dff35a11d32fac940281dc886e3ba7bb6a55",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.4/openkal-musl-0.3.4.tar.gz",
                },
                sha256 = "a2c17775bc17d2c981dca624bebe1661e6d1662844f2cecf7d465c2828a27249",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.3/openkal-musl-0.3.3.tar.gz",
                },
                sha256 = "1a5ebc69bae296b98783719e2db242ae17a118e4ee35e73b1ad836bc94afedca",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.2/openkal-musl-0.3.2.tar.gz",
                },
                sha256 = "35246bf4326e0f4c9b606ae1934b5f7752cfc10832a7039d71291f7c5707d886",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.1/openkal-musl-0.3.1.tar.gz",
                },
                sha256 = "c09c6f4f29b9121be2dba69959043fef4effe52807215882c9f2e62644f9331b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
        windows = {
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.18.0/openkal-musl-0.18.0.tar.gz",
                },
                sha256 = "67eeaa9b1d9813d284f498322422f953448afcf53673645af86d53e4c980d377",
            },
            ["0.17.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.17.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.17.0/openkal-musl-0.17.0.tar.gz",
                },
                sha256 = "201932848af47311dd6610c9acf6b35d193559cea64cf5f620c246656f2ccc05",
            },
            ["0.16.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.16.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.16.0/openkal-musl-0.16.0.tar.gz",
                },
                sha256 = "8ffa4a2a79fcc7fe7565c1e69624b9d3b575020ed97d2043e20cdf542d519105",
            },
            ["0.15.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.15.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.15.0/openkal-musl-0.15.0.tar.gz",
                },
                sha256 = "ee953bd8ff39822ecc66e67faa3a37efdab3703e097e85c6e422e51e084ca8b6",
            },
            ["0.14.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.14.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.14.0/openkal-musl-0.14.0.tar.gz",
                },
                sha256 = "91e747f495e041846c48522a3a5a2061ce6fd8f81e4b4e60f54cfaec4358bd66",
            },
            ["0.13.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.5/openkal-musl-0.13.5.tar.gz",
                },
                sha256 = "4ca2ace91d0af248b90f2f6e1534bbb78eac7381c24d691d1de91f879670e8c8",
            },
            ["0.13.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.4/openkal-musl-0.13.4.tar.gz",
                },
                sha256 = "bea25da11a7c074082439fd5561e288f3e6e0f75cc8d965da8187848d3193f48",
            },
            ["0.13.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.3/openkal-musl-0.13.3.tar.gz",
                },
                sha256 = "4f47f9b0c09a7dd7717e8e6c2933ac909f2bc1ced40fb17420f44501f55ffcf0",
            },
            ["0.13.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.2/openkal-musl-0.13.2.tar.gz",
                },
                sha256 = "7c21fc51063951a1f19215410c0bdebcd6d510242f82678fa4be913ae56351aa",
            },
            ["0.13.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.1/openkal-musl-0.13.1.tar.gz",
                },
                sha256 = "6acdb824c83ccb5eec384be0f3261ce49bc10c6b66707092334487554979b332",
            },
            ["0.13.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.13.0/openkal-musl-0.13.0.tar.gz",
                },
                sha256 = "0bfdeeafef1f9aecaa2d77df19366ecfffe62179329b7dfcc43114cc897d4e1f",
            },
            ["0.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.12.0/openkal-musl-0.12.0.tar.gz",
                },
                sha256 = "2727f10d2ebffb05d87d82525fe4755ed4eb02fdaf55eb816179a0628e9de5de",
            },
            ["0.11.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.11.0/openkal-musl-0.11.0.tar.gz",
                },
                sha256 = "6b9212b047ae9a8995582baf59402bf29b46c3a2ff0a0c39c318a91db3013d4d",
            },
            ["0.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.10.0/openkal-musl-0.10.0.tar.gz",
                },
                sha256 = "c5e151aa63e63ce0f13c6fc28bfd26004a9a305b4f1973ee2888ec871c68ee8f",
            },
            ["0.9.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.9.0/openkal-musl-0.9.0.tar.gz",
                },
                sha256 = "18e63f25ac0ccde6057ca0028e33630790a6268d83ca0eca03fc81fde818dc1a",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.8.0/openkal-musl-0.8.0.tar.gz",
                },
                sha256 = "1a54c2696ad0118efb632c6eddf8659f85484c42574a82abf604783d00b6db0c",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.7.0/openkal-musl-0.7.0.tar.gz",
                },
                sha256 = "e66bf5a2fac456a1ca40f53856d8908f256145a9a5093a052e29760a6580c730",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.6.0/openkal-musl-0.6.0.tar.gz",
                },
                sha256 = "ca7696638c7387f8391947443c6fbfeb6f0c86021a07a15ac6b82b39c6616c86",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.5.0/openkal-musl-0.5.0.tar.gz",
                },
                sha256 = "315238f2f15fb486816e570aa6a549284daa248a5206b332b67ada4ecad4426b",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.4.0/openkal-musl-0.4.0.tar.gz",
                },
                sha256 = "aa29225b7a71fb9d81b3f356f4ac21d89ad0a87d9229a8e42b29f807208519c3",
            },
            ["0.3.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.5/openkal-musl-0.3.5.tar.gz",
                },
                sha256 = "0f8335633d230f0989db6083f5d5dff35a11d32fac940281dc886e3ba7bb6a55",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.4/openkal-musl-0.3.4.tar.gz",
                },
                sha256 = "a2c17775bc17d2c981dca624bebe1661e6d1662844f2cecf7d465c2828a27249",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.3/openkal-musl-0.3.3.tar.gz",
                },
                sha256 = "1a5ebc69bae296b98783719e2db242ae17a118e4ee35e73b1ad836bc94afedca",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.2/openkal-musl-0.3.2.tar.gz",
                },
                sha256 = "35246bf4326e0f4c9b606ae1934b5f7752cfc10832a7039d71291f7c5707d886",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.1/openkal-musl-0.3.1.tar.gz",
                },
                sha256 = "c09c6f4f29b9121be2dba69959043fef4effe52807215882c9f2e62644f9331b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
