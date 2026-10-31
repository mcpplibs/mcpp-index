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
-- 0.19.2 ships the eight archives musl's own `make install` places beside
-- `libc.a` --- `libm.a', `librt.a', `libpthread.a', `libcrypt.a', `libutil.a',
-- `libxnet.a', `libresolv.a' and `libdl.a', each an empty archive --- and adds
-- their directory to its Linux `ldflags'. A program's `-lm' is then answered
-- by this package rather than by the build machine's own libraries: with no
-- host directory in a graph link's search (mcpp#696), `-lm' fails without them,
-- and before that fix it was answered by the host's glibc archive. Nothing
-- else changed, and it asks nothing more of `min_mcpp': openkal-musl's own CI
-- builds 0.19.2 with the published 2026.9.18.3 and reads, in the linker's own
-- trace, that each of `-lm', `-lpthread', `-ldl' and `-lrt' opened this
-- package's archive and nothing under /usr or /lib.
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
--
-- 0.22.4 reads the flags word of `renameat2': RENAME_NOREPLACE is
-- `kal_fs_rename_flags(KAL_RENAME_NO_REPLACE)' and every other flag is EINVAL.
-- Before it the word was not read, and a RENAME_EXCHANGE lost the second
-- file. The image form pins openkal-ld 0.1.2.
--
-- 0.22.6 takes a program's arguments again when it is entered. On Mach-O the
-- library is brought up from a constructor, and openkal-macos records the
-- arguments from a constructor of its own, in the order the linker loaded
-- their objects; a program whose link loaded this library's first received
-- argc 0 (mcppls on aarch64-macos).
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
            ["0.23.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.2/openkal-musl-0.23.2.tar.gz",
                },
                sha256 = "fed008a354d8443eadcc5b168eb785b1a414ac89a7143c5d4c43361198965fe4",
            },
            ["0.23.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.1/openkal-musl-0.23.1.tar.gz",
                },
                sha256 = "81d9aa3bcb6dd1228cc15ce63ca79b2a13829fcf3d5a0824e60e7d73d2bccee6",
            },
            ["0.23.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.0/openkal-musl-0.23.0.tar.gz",
                },
                sha256 = "d2238aef42b4155d23aa87431d3c344fafcba78446473499bb9b1472f9d31a87",
            },
            ["0.22.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.9/openkal-musl-0.22.9.tar.gz",
                },
                sha256 = "c146d036b23f03d4804314cc7b3f3c4d7bdeb737b5b27cffe60e00fa8ef17535",
            },
            ["0.22.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.8/openkal-musl-0.22.8.tar.gz",
                },
                sha256 = "c278fc9565732961860f36dad8032f51057b65fbf7f583441af9ec38e67d2dd7",
            },
            ["0.22.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.7/openkal-musl-0.22.7.tar.gz",
                },
                sha256 = "034de7f9c4c57fe04560737c1c3fc5c9a3f656e00f3050f4957a97f61482c265",
            },
            ["0.22.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.6/openkal-musl-0.22.6.tar.gz",
                },
                sha256 = "4942212a063a9e14a477eef53b71153d1a9209946376652cac605dc1cb726c8e",
            },
            ["0.22.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.5/openkal-musl-0.22.5.tar.gz",
                },
                sha256 = "31887badfe8bfe687f0a09b015d5d8164c2b47e791235cb3ef746d59a6bce76d",
            },
            ["0.22.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.4/openkal-musl-0.22.4.tar.gz",
                },
                sha256 = "ee796a13882d4e4a1fb7829d72898eb865147e6d2b3b7c1a09c7f325b226cf68",
            },
            ["0.22.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.3/openkal-musl-0.22.3.tar.gz",
                },
                sha256 = "390f1b300ba210f9b7aa45b6306de18be3796041ade7256d67db16159e043f8f",
            },
            ["0.22.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.2/openkal-musl-0.22.2.tar.gz",
                },
                sha256 = "1751116a49af6985fa662a593ae26e576a1b21d957b8b1560e42825ad7ac7d78",
            },
            ["0.22.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.1/openkal-musl-0.22.1.tar.gz",
                },
                sha256 = "a0ecda41e4e935a117c53b2290082e42138a2c076871f2b3cc8256197d83a9f5",
            },
            ["0.22.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.0/openkal-musl-0.22.0.tar.gz",
                },
                sha256 = "28779cba8bd509b9aa4360f6918b0bab28e594a188d69c808ba00f692454f892",
            },
            ["0.21.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.21.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.21.1/openkal-musl-0.21.1.tar.gz",
                },
                sha256 = "cd1219b15c7485bf6aaad904ed7e6e7d1bfc6e76dcc90d4c3d5e8c1ec8557886",
            },
            ["0.21.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.21.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.21.0/openkal-musl-0.21.0.tar.gz",
                },
                sha256 = "98889c1fa7bbac05787e8c362ea79e4941c97aaa1ffca86a0ed7d88ff419545c",
            },
            ["0.20.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.20.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.20.1/openkal-musl-0.20.1.tar.gz",
                },
                sha256 = "66e7e9954486eaea0bb7a9ece727b7a039ccfa3fb140038da7d8304b094d8e7c",
            },
            ["0.20.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.20.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.20.0/openkal-musl-0.20.0.tar.gz",
                },
                sha256 = "7625bc484b8d408a3ddd91232881d948db45ce7025391e53f9a563fb3731719c",
            },
            ["0.19.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.3/openkal-musl-0.19.3.tar.gz",
                },
                sha256 = "4d772a741128c070b0ec5d1e8357d5324c0d4085340feea8468a0b285722b1d6",
            },
            ["0.19.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.2/openkal-musl-0.19.2.tar.gz",
                },
                sha256 = "e8043bcd9971ee91a0861ef11b7678606a690898abfe98744a254222d9c82238",
            },
            ["0.19.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.1/openkal-musl-0.19.1.tar.gz",
                },
                sha256 = "8abfeab644830b9aa40314f9fdb56e0233733445198bafaa2767b53b8e44ef70",
            },
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
            ["0.23.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.2/openkal-musl-0.23.2.tar.gz",
                },
                sha256 = "fed008a354d8443eadcc5b168eb785b1a414ac89a7143c5d4c43361198965fe4",
            },
            ["0.23.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.1/openkal-musl-0.23.1.tar.gz",
                },
                sha256 = "81d9aa3bcb6dd1228cc15ce63ca79b2a13829fcf3d5a0824e60e7d73d2bccee6",
            },
            ["0.23.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.0/openkal-musl-0.23.0.tar.gz",
                },
                sha256 = "d2238aef42b4155d23aa87431d3c344fafcba78446473499bb9b1472f9d31a87",
            },
            ["0.22.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.9/openkal-musl-0.22.9.tar.gz",
                },
                sha256 = "c146d036b23f03d4804314cc7b3f3c4d7bdeb737b5b27cffe60e00fa8ef17535",
            },
            ["0.22.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.8/openkal-musl-0.22.8.tar.gz",
                },
                sha256 = "c278fc9565732961860f36dad8032f51057b65fbf7f583441af9ec38e67d2dd7",
            },
            ["0.22.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.7/openkal-musl-0.22.7.tar.gz",
                },
                sha256 = "034de7f9c4c57fe04560737c1c3fc5c9a3f656e00f3050f4957a97f61482c265",
            },
            ["0.22.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.6/openkal-musl-0.22.6.tar.gz",
                },
                sha256 = "4942212a063a9e14a477eef53b71153d1a9209946376652cac605dc1cb726c8e",
            },
            ["0.22.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.5/openkal-musl-0.22.5.tar.gz",
                },
                sha256 = "31887badfe8bfe687f0a09b015d5d8164c2b47e791235cb3ef746d59a6bce76d",
            },
            ["0.22.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.4/openkal-musl-0.22.4.tar.gz",
                },
                sha256 = "ee796a13882d4e4a1fb7829d72898eb865147e6d2b3b7c1a09c7f325b226cf68",
            },
            ["0.22.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.3/openkal-musl-0.22.3.tar.gz",
                },
                sha256 = "390f1b300ba210f9b7aa45b6306de18be3796041ade7256d67db16159e043f8f",
            },
            ["0.22.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.2/openkal-musl-0.22.2.tar.gz",
                },
                sha256 = "1751116a49af6985fa662a593ae26e576a1b21d957b8b1560e42825ad7ac7d78",
            },
            ["0.22.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.1/openkal-musl-0.22.1.tar.gz",
                },
                sha256 = "a0ecda41e4e935a117c53b2290082e42138a2c076871f2b3cc8256197d83a9f5",
            },
            ["0.22.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.0/openkal-musl-0.22.0.tar.gz",
                },
                sha256 = "28779cba8bd509b9aa4360f6918b0bab28e594a188d69c808ba00f692454f892",
            },
            ["0.21.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.21.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.21.1/openkal-musl-0.21.1.tar.gz",
                },
                sha256 = "cd1219b15c7485bf6aaad904ed7e6e7d1bfc6e76dcc90d4c3d5e8c1ec8557886",
            },
            ["0.21.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.21.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.21.0/openkal-musl-0.21.0.tar.gz",
                },
                sha256 = "98889c1fa7bbac05787e8c362ea79e4941c97aaa1ffca86a0ed7d88ff419545c",
            },
            ["0.20.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.20.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.20.1/openkal-musl-0.20.1.tar.gz",
                },
                sha256 = "66e7e9954486eaea0bb7a9ece727b7a039ccfa3fb140038da7d8304b094d8e7c",
            },
            ["0.20.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.20.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.20.0/openkal-musl-0.20.0.tar.gz",
                },
                sha256 = "7625bc484b8d408a3ddd91232881d948db45ce7025391e53f9a563fb3731719c",
            },
            ["0.19.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.3/openkal-musl-0.19.3.tar.gz",
                },
                sha256 = "4d772a741128c070b0ec5d1e8357d5324c0d4085340feea8468a0b285722b1d6",
            },
            ["0.19.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.2/openkal-musl-0.19.2.tar.gz",
                },
                sha256 = "e8043bcd9971ee91a0861ef11b7678606a690898abfe98744a254222d9c82238",
            },
            ["0.19.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.1/openkal-musl-0.19.1.tar.gz",
                },
                sha256 = "8abfeab644830b9aa40314f9fdb56e0233733445198bafaa2767b53b8e44ef70",
            },
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
        windows = {
            ["0.23.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.2/openkal-musl-0.23.2.tar.gz",
                },
                sha256 = "fed008a354d8443eadcc5b168eb785b1a414ac89a7143c5d4c43361198965fe4",
            },
            ["0.23.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.1/openkal-musl-0.23.1.tar.gz",
                },
                sha256 = "81d9aa3bcb6dd1228cc15ce63ca79b2a13829fcf3d5a0824e60e7d73d2bccee6",
            },
            ["0.23.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.23.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.23.0/openkal-musl-0.23.0.tar.gz",
                },
                sha256 = "d2238aef42b4155d23aa87431d3c344fafcba78446473499bb9b1472f9d31a87",
            },
            ["0.22.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.9/openkal-musl-0.22.9.tar.gz",
                },
                sha256 = "c146d036b23f03d4804314cc7b3f3c4d7bdeb737b5b27cffe60e00fa8ef17535",
            },
            ["0.22.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.8/openkal-musl-0.22.8.tar.gz",
                },
                sha256 = "c278fc9565732961860f36dad8032f51057b65fbf7f583441af9ec38e67d2dd7",
            },
            ["0.22.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.7/openkal-musl-0.22.7.tar.gz",
                },
                sha256 = "034de7f9c4c57fe04560737c1c3fc5c9a3f656e00f3050f4957a97f61482c265",
            },
            ["0.22.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.6/openkal-musl-0.22.6.tar.gz",
                },
                sha256 = "4942212a063a9e14a477eef53b71153d1a9209946376652cac605dc1cb726c8e",
            },
            ["0.22.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.5/openkal-musl-0.22.5.tar.gz",
                },
                sha256 = "31887badfe8bfe687f0a09b015d5d8164c2b47e791235cb3ef746d59a6bce76d",
            },
            ["0.22.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.4/openkal-musl-0.22.4.tar.gz",
                },
                sha256 = "ee796a13882d4e4a1fb7829d72898eb865147e6d2b3b7c1a09c7f325b226cf68",
            },
            ["0.22.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.3/openkal-musl-0.22.3.tar.gz",
                },
                sha256 = "390f1b300ba210f9b7aa45b6306de18be3796041ade7256d67db16159e043f8f",
            },
            ["0.22.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.2/openkal-musl-0.22.2.tar.gz",
                },
                sha256 = "1751116a49af6985fa662a593ae26e576a1b21d957b8b1560e42825ad7ac7d78",
            },
            ["0.22.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.1/openkal-musl-0.22.1.tar.gz",
                },
                sha256 = "a0ecda41e4e935a117c53b2290082e42138a2c076871f2b3cc8256197d83a9f5",
            },
            ["0.22.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.22.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.22.0/openkal-musl-0.22.0.tar.gz",
                },
                sha256 = "28779cba8bd509b9aa4360f6918b0bab28e594a188d69c808ba00f692454f892",
            },
            ["0.21.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.21.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.21.1/openkal-musl-0.21.1.tar.gz",
                },
                sha256 = "cd1219b15c7485bf6aaad904ed7e6e7d1bfc6e76dcc90d4c3d5e8c1ec8557886",
            },
            ["0.21.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.21.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.21.0/openkal-musl-0.21.0.tar.gz",
                },
                sha256 = "98889c1fa7bbac05787e8c362ea79e4941c97aaa1ffca86a0ed7d88ff419545c",
            },
            ["0.20.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.20.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.20.1/openkal-musl-0.20.1.tar.gz",
                },
                sha256 = "66e7e9954486eaea0bb7a9ece727b7a039ccfa3fb140038da7d8304b094d8e7c",
            },
            ["0.20.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.20.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.20.0/openkal-musl-0.20.0.tar.gz",
                },
                sha256 = "7625bc484b8d408a3ddd91232881d948db45ce7025391e53f9a563fb3731719c",
            },
            ["0.19.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.3/openkal-musl-0.19.3.tar.gz",
                },
                sha256 = "4d772a741128c070b0ec5d1e8357d5324c0d4085340feea8468a0b285722b1d6",
            },
            ["0.19.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.2/openkal-musl-0.19.2.tar.gz",
                },
                sha256 = "e8043bcd9971ee91a0861ef11b7678606a690898abfe98744a254222d9c82238",
            },
            ["0.19.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.19.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.19.1/openkal-musl-0.19.1.tar.gz",
                },
                sha256 = "8abfeab644830b9aa40314f9fdb56e0233733445198bafaa2767b53b8e44ef70",
            },
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
    },

    mcpp = "*/mcpp.toml",
}
