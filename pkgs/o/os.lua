-- os --- mcpplibs.os, a C++ operating-system library over openkal.
--
-- Processes, files, the environment, terminals, conventional directories and
-- local IPC, composed from openkal's atoms, with compile-time platform
-- constants for a program built for a system and `host()' answered at load for
-- one built as an ok image (`<arch>-openkal').
--
-- No `deps'. The package names openkal and, for the system it is built for,
-- that system's implementation in its own manifest. From 0.2.1 an ok image's
-- C library, C++ run-time and loader are its platform's (openkal-platform,
-- which mcpp 2026.10.27.1 selects for `<arch>-openkal'), and the package
-- declares none of them.
-- From 0.2.2 it builds for `wasm32-emscripten' over Emscripten's C library and
-- openkal-emscripten 0.6.0, which its manifest names for that target; starting
-- a program there fails at link, naming the openkal symbol.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "os",
    description = "mcpplibs.os: a C++ operating-system library over openkal --- processes, files, environment, terminals, directories and local IPC, with compile-time platform constants and a few platform modules",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/os",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/mcpplibs/os/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.4.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.3/os-0.4.3.tar.gz",
                },
                sha256 = "1e372cbb6cca80631644dd1537a583ed5fb816d9a65353aac1f356af155cf224",
            },
            ["0.4.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.2/os-0.4.2.tar.gz",
                },
                sha256 = "ca58bf5ffe591e9a2f317b69c4705aeb50e813859dba45accd3f4401b8066646",
            },
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.1/os-0.4.1.tar.gz",
                },
                sha256 = "149ecc26e79a6e4b1d9188c1e10ca67679ef683de2502e683c8ea6d74e093805",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.0/os-0.4.0.tar.gz",
                },
                sha256 = "ad0b61b962469166ec2053ad5c1f5a7114278e98edd94cc3c5235d6148a8111a",
            },
            ["0.3.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.3.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.3.1/os-0.3.1.tar.gz",
                },
                sha256 = "26492cf9fe4a5a0ac5d6c0590e6659ff435c0104d636450dbf0f14cef15823b1",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.3.0/os-0.3.0.tar.gz",
                },
                sha256 = "338a26822378ce0bc97dda4be8629acdffaaa05e6743bccb4e02408866164920",
            },
            ["0.2.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.9/os-0.2.9.tar.gz",
                },
                sha256 = "4168f6a1a1608856bfd79b79d8edd46245905baebe57be0c86371a772a967639",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.8/os-0.2.8.tar.gz",
                },
                sha256 = "f64f2625cd111011a2477c8c69b270237c7cdd1f0e237b883bac6a49e6730c0b",
            },
            ["0.2.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.7/os-0.2.7.tar.gz",
                },
                sha256 = "c3f8ebcb921ca43c48895a025166118dd91b54eeb5e2061301892865a127994f",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.6/os-0.2.6.tar.gz",
                },
                sha256 = "7bea6784440d67044447794f960410f73c834756573ec622ca24d90d5eb0645e",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.5/os-0.2.5.tar.gz",
                },
                sha256 = "14a8e23093eeea0cf085a437d6867603473cc52bd00a921bc024e2ab5b3b7290",
            },
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.4/os-0.2.4.tar.gz",
                },
                sha256 = "70089d2745ff133b38c93e826e471ff080da30432abd6fd84672c7927d817d9a",
            },
            ["0.2.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.3/os-0.2.3.tar.gz",
                },
                sha256 = "e280c00d8be69c057dfbac9c9e49ea9aedb97aa5ec10b693f2262e861740e0b4",
            },
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.2/os-0.2.2.tar.gz",
                },
                sha256 = "33c5d946c29de1ba7bacabe40fe6ee2f60bea0b25e62c0359f8c570b0f654e3e",
            },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.1/os-0.2.1.tar.gz",
                },
                sha256 = "264a3b80ef40fcb760b7c63565e01597549fdd8e5aa0672389b5d9384661218f",
            },
            ["0.2.0"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "9dc147ad8dca0216549c40dc4dfabaed7394cdf7a7f253c58613ccc226abd04e",
            },
            ["0.1.2"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.2.tar.gz",
                sha256 = "bf6f5cfb1518b045b693e246ee39306746074586434419d4052e648be111ea34",
            },
            ["0.1.1"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.1.tar.gz",
                sha256 = "c5abfb625ded0d5d837b799722c836c302460251d47081fef7a57a2a12e6b2b9",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.1.0/os-0.1.0.tar.gz",
                },
                sha256 = "f7e4117612d721da2ae311cb36afab42625391208e4b0f8e8491534a00b6ab18",
            },
        },
        macosx = {
            ["0.4.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.3/os-0.4.3.tar.gz",
                },
                sha256 = "1e372cbb6cca80631644dd1537a583ed5fb816d9a65353aac1f356af155cf224",
            },
            ["0.4.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.2/os-0.4.2.tar.gz",
                },
                sha256 = "ca58bf5ffe591e9a2f317b69c4705aeb50e813859dba45accd3f4401b8066646",
            },
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.1/os-0.4.1.tar.gz",
                },
                sha256 = "149ecc26e79a6e4b1d9188c1e10ca67679ef683de2502e683c8ea6d74e093805",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.0/os-0.4.0.tar.gz",
                },
                sha256 = "ad0b61b962469166ec2053ad5c1f5a7114278e98edd94cc3c5235d6148a8111a",
            },
            ["0.3.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.3.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.3.1/os-0.3.1.tar.gz",
                },
                sha256 = "26492cf9fe4a5a0ac5d6c0590e6659ff435c0104d636450dbf0f14cef15823b1",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.3.0/os-0.3.0.tar.gz",
                },
                sha256 = "338a26822378ce0bc97dda4be8629acdffaaa05e6743bccb4e02408866164920",
            },
            ["0.2.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.9/os-0.2.9.tar.gz",
                },
                sha256 = "4168f6a1a1608856bfd79b79d8edd46245905baebe57be0c86371a772a967639",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.8/os-0.2.8.tar.gz",
                },
                sha256 = "f64f2625cd111011a2477c8c69b270237c7cdd1f0e237b883bac6a49e6730c0b",
            },
            ["0.2.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.7/os-0.2.7.tar.gz",
                },
                sha256 = "c3f8ebcb921ca43c48895a025166118dd91b54eeb5e2061301892865a127994f",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.6/os-0.2.6.tar.gz",
                },
                sha256 = "7bea6784440d67044447794f960410f73c834756573ec622ca24d90d5eb0645e",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.5/os-0.2.5.tar.gz",
                },
                sha256 = "14a8e23093eeea0cf085a437d6867603473cc52bd00a921bc024e2ab5b3b7290",
            },
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.4/os-0.2.4.tar.gz",
                },
                sha256 = "70089d2745ff133b38c93e826e471ff080da30432abd6fd84672c7927d817d9a",
            },
            ["0.2.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.3/os-0.2.3.tar.gz",
                },
                sha256 = "e280c00d8be69c057dfbac9c9e49ea9aedb97aa5ec10b693f2262e861740e0b4",
            },
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.2/os-0.2.2.tar.gz",
                },
                sha256 = "33c5d946c29de1ba7bacabe40fe6ee2f60bea0b25e62c0359f8c570b0f654e3e",
            },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.1/os-0.2.1.tar.gz",
                },
                sha256 = "264a3b80ef40fcb760b7c63565e01597549fdd8e5aa0672389b5d9384661218f",
            },
            ["0.2.0"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "9dc147ad8dca0216549c40dc4dfabaed7394cdf7a7f253c58613ccc226abd04e",
            },
            ["0.1.2"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.2.tar.gz",
                sha256 = "bf6f5cfb1518b045b693e246ee39306746074586434419d4052e648be111ea34",
            },
            ["0.1.1"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.1.tar.gz",
                sha256 = "c5abfb625ded0d5d837b799722c836c302460251d47081fef7a57a2a12e6b2b9",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.1.0/os-0.1.0.tar.gz",
                },
                sha256 = "f7e4117612d721da2ae311cb36afab42625391208e4b0f8e8491534a00b6ab18",
            },
        },
        windows = {
            ["0.4.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.3/os-0.4.3.tar.gz",
                },
                sha256 = "1e372cbb6cca80631644dd1537a583ed5fb816d9a65353aac1f356af155cf224",
            },
            ["0.4.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.2/os-0.4.2.tar.gz",
                },
                sha256 = "ca58bf5ffe591e9a2f317b69c4705aeb50e813859dba45accd3f4401b8066646",
            },
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.1/os-0.4.1.tar.gz",
                },
                sha256 = "149ecc26e79a6e4b1d9188c1e10ca67679ef683de2502e683c8ea6d74e093805",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.4.0/os-0.4.0.tar.gz",
                },
                sha256 = "ad0b61b962469166ec2053ad5c1f5a7114278e98edd94cc3c5235d6148a8111a",
            },
            ["0.3.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.3.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/os/releases/download/0.3.1/os-0.3.1.tar.gz",
                },
                sha256 = "26492cf9fe4a5a0ac5d6c0590e6659ff435c0104d636450dbf0f14cef15823b1",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.3.0/os-0.3.0.tar.gz",
                },
                sha256 = "338a26822378ce0bc97dda4be8629acdffaaa05e6743bccb4e02408866164920",
            },
            ["0.2.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.9/os-0.2.9.tar.gz",
                },
                sha256 = "4168f6a1a1608856bfd79b79d8edd46245905baebe57be0c86371a772a967639",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.8/os-0.2.8.tar.gz",
                },
                sha256 = "f64f2625cd111011a2477c8c69b270237c7cdd1f0e237b883bac6a49e6730c0b",
            },
            ["0.2.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.7/os-0.2.7.tar.gz",
                },
                sha256 = "c3f8ebcb921ca43c48895a025166118dd91b54eeb5e2061301892865a127994f",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.6/os-0.2.6.tar.gz",
                },
                sha256 = "7bea6784440d67044447794f960410f73c834756573ec622ca24d90d5eb0645e",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.5/os-0.2.5.tar.gz",
                },
                sha256 = "14a8e23093eeea0cf085a437d6867603473cc52bd00a921bc024e2ab5b3b7290",
            },
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.4/os-0.2.4.tar.gz",
                },
                sha256 = "70089d2745ff133b38c93e826e471ff080da30432abd6fd84672c7927d817d9a",
            },
            ["0.2.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.3/os-0.2.3.tar.gz",
                },
                sha256 = "e280c00d8be69c057dfbac9c9e49ea9aedb97aa5ec10b693f2262e861740e0b4",
            },
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.2/os-0.2.2.tar.gz",
                },
                sha256 = "33c5d946c29de1ba7bacabe40fe6ee2f60bea0b25e62c0359f8c570b0f654e3e",
            },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.1/os-0.2.1.tar.gz",
                },
                sha256 = "264a3b80ef40fcb760b7c63565e01597549fdd8e5aa0672389b5d9384661218f",
            },
            ["0.2.0"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "9dc147ad8dca0216549c40dc4dfabaed7394cdf7a7f253c58613ccc226abd04e",
            },
            ["0.1.2"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.2.tar.gz",
                sha256 = "bf6f5cfb1518b045b693e246ee39306746074586434419d4052e648be111ea34",
            },
            ["0.1.1"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.1.tar.gz",
                sha256 = "c5abfb625ded0d5d837b799722c836c302460251d47081fef7a57a2a12e6b2b9",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.1.0/os-0.1.0.tar.gz",
                },
                sha256 = "f7e4117612d721da2ae311cb36afab42625391208e4b0f8e8491534a00b6ab18",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
