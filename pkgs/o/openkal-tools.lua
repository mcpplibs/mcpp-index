-- openkal-tools --- okrun, okld and okprof (openkal SPEC clause 12).
--
-- A member of mcpplibs/openkal-image (one tag, one archive). A project that
-- builds ok images (`<arch>-openkal`) declares it for this machine:
--
--     [build-dependencies]
--     openkal-tools = { version = "0.1.0", tools = ["okld", "okrun"] }
--
-- mcpp finishes each image with okld and runs it with okrun.
--
-- No `deps'. The package names openkal-run and openkal-ld.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-tools",
    description = "okrun, okld and okprof: the runner of ok images; the tool that writes an image's notes (requirements, placement, touches), checks the convention, signs and bundles it; and the reader of the runner's reports",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-image",
    type        = "package",

    xpm = {
        linux = {
            ["0.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.6.1/openkal-image-0.6.1.tar.gz",
                },
                sha256 = "36b792acadf4423aa5b4a90a020bb4b3dddd085ae0239f7860d12a02db0bfd99",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.6.0/openkal-image-0.6.0.tar.gz",
                },
                sha256 = "12e9a22a664a6cf6149ea375bd21797479be5ba6e0b98b36ef5f83edc534ba2f",
            },
            ["0.5.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.5.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.5/openkal-image-0.5.5.tar.gz",
                },
                sha256 = "ba1dcc6f93ec43e7c292849d8877990822873625e37c4f5b3eff5f0c4b68e789",
            },
            ["0.5.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.4.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.4/openkal-image-0.5.4.tar.gz",
                },
                sha256 = "84bc86cabd61459c202d348ffc5dcf91dd2585c351029794fefabbb839a8cf0a",
            },
            ["0.5.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.3/openkal-image-0.5.3.tar.gz",
                },
                sha256 = "8b44ad29f0ba44d3e51e5c4c0a17f48ff6d61f8d3dee5fac6ee3b17dda355fbe",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.2/openkal-image-0.5.2.tar.gz",
                },
                sha256 = "110b5c871fdf8120281be1b4398ec80ba79f9e863d99980e33d8f3bb3397f5a3",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.1/openkal-image-0.5.1.tar.gz",
                },
                sha256 = "10c4cae4dd2b46bf242332bb2150ceb34f6f084a452aec5d6a949e139c497943",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.0/openkal-image-0.5.0.tar.gz",
                },
                sha256 = "6b3a906cd150751c639c858c9536d10b38b51d25b1067529c50e345996344b0f",
            },
            ["0.4.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.5/openkal-image-0.4.5.tar.gz",
                },
                sha256 = "8ab1b47375a08908fb391e33aa5b92d90808531a9aec500de56ff54f46142f98",
            },
            ["0.4.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.4/openkal-image-0.4.4.tar.gz",
                },
                sha256 = "e16f9f5e04233be334fc89dcf5ce036050dc75abfb1781cf88279dab3918bb98",
            },
            ["0.4.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.3/openkal-image-0.4.3.tar.gz",
                },
                sha256 = "7b6100c9296b4aca1d07df178552307592327bee5912ae036726b6aa3afcf302",
            },
            ["0.4.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.2/openkal-image-0.4.2.tar.gz",
                },
                sha256 = "ee15f41bc1b0e50893ecb4bce9f1751285a75459b7954359f22848430313b6a7",
            },
            ["0.4.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.1/openkal-image-0.4.1.tar.gz",
                },
                sha256 = "4fbf944e61add86994daaaf0e2e1ba5a2e9c5cfc849d962059cf8ae7346ae25e",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.0/openkal-image-0.4.0.tar.gz",
                },
                sha256 = "2ffec55b912f22c3efefca4e9ad651ea0180c3d2495c8bc5413503b05524a92f",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.2/openkal-image-0.3.2.tar.gz",
                },
                sha256 = "2d9d259491e61a2a6c47661cd1dbb61fedeb562c1d6bc7941b606db870fa8345",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.1/openkal-image-0.3.1.tar.gz",
                },
                sha256 = "c5a294d71b446254ac59f9fcaf30df0de01705cb6a30d619188263822fdbaae0",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.0/openkal-image-0.3.0.tar.gz",
                },
                sha256 = "e807ab2327a5d313d6c5d1b59c0a85e8c43a409bca0d5f4b00629a3b198f231f",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.2.0/openkal-image-0.2.0.tar.gz",
                },
                sha256 = "03ea705c01b4e39a2b89956817e76a5bb7b94b4befaed6f68485bdfa105cb19a",
            },
            ["0.1.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.9/openkal-image-0.1.9.tar.gz",
                },
                sha256 = "5cef1fb2e647724998293a299377662310110646b2389b6aa9a4170253ddc10d",
            },
            ["0.1.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.8/openkal-image-0.1.8.tar.gz",
                },
                sha256 = "16cfe46581667fcaefeb288a43162f9e4e5393950f443ac7f09d6ddae313fcdd",
            },
            ["0.1.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.7/openkal-image-0.1.7.tar.gz",
                },
                sha256 = "cbe4971fd0f3ae4c3dc522d0e9ab361522670ddb90af5b64be46c362ac7ded52",
            },
            ["0.1.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.6/openkal-image-0.1.6.tar.gz",
                },
                sha256 = "0258983a10984f7b4597ed1e7dd08fb5b2dad436113574791bedc0ea2d1b002b",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.5/openkal-image-0.1.5.tar.gz",
                },
                sha256 = "5cd28c5bcebf7c4f0b9f69ea01e1e5d8f595ed148d485404ad367631c083aef8",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.4/openkal-image-0.1.4.tar.gz",
                },
                sha256 = "d9ec0dc0a78c2bdbd20f1420df510805ef3f019545cb5306393ca31765edf5ff",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.3/openkal-image-0.1.3.tar.gz",
                },
                sha256 = "eec70f276f973b1eb64b28773432489723866e38b6261edba24e137387099f23",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.2/openkal-image-0.1.2.tar.gz",
                },
                sha256 = "63768571a800f3acdad420e18c14ee1bc5142f77ef29dcf01841f40d8f1f9a25",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.1/openkal-image-0.1.1.tar.gz",
                },
                sha256 = "7b0056d62e1f297b937d63e9f59b5d82ec19f034a1286ec6ec44d6c834d5f0cc",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
        macosx = {
            ["0.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.6.1/openkal-image-0.6.1.tar.gz",
                },
                sha256 = "36b792acadf4423aa5b4a90a020bb4b3dddd085ae0239f7860d12a02db0bfd99",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.6.0/openkal-image-0.6.0.tar.gz",
                },
                sha256 = "12e9a22a664a6cf6149ea375bd21797479be5ba6e0b98b36ef5f83edc534ba2f",
            },
            ["0.5.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.5.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.5/openkal-image-0.5.5.tar.gz",
                },
                sha256 = "ba1dcc6f93ec43e7c292849d8877990822873625e37c4f5b3eff5f0c4b68e789",
            },
            ["0.5.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.4.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.4/openkal-image-0.5.4.tar.gz",
                },
                sha256 = "84bc86cabd61459c202d348ffc5dcf91dd2585c351029794fefabbb839a8cf0a",
            },
            ["0.5.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.3/openkal-image-0.5.3.tar.gz",
                },
                sha256 = "8b44ad29f0ba44d3e51e5c4c0a17f48ff6d61f8d3dee5fac6ee3b17dda355fbe",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.2/openkal-image-0.5.2.tar.gz",
                },
                sha256 = "110b5c871fdf8120281be1b4398ec80ba79f9e863d99980e33d8f3bb3397f5a3",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.1/openkal-image-0.5.1.tar.gz",
                },
                sha256 = "10c4cae4dd2b46bf242332bb2150ceb34f6f084a452aec5d6a949e139c497943",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.0/openkal-image-0.5.0.tar.gz",
                },
                sha256 = "6b3a906cd150751c639c858c9536d10b38b51d25b1067529c50e345996344b0f",
            },
            ["0.4.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.5/openkal-image-0.4.5.tar.gz",
                },
                sha256 = "8ab1b47375a08908fb391e33aa5b92d90808531a9aec500de56ff54f46142f98",
            },
            ["0.4.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.4/openkal-image-0.4.4.tar.gz",
                },
                sha256 = "e16f9f5e04233be334fc89dcf5ce036050dc75abfb1781cf88279dab3918bb98",
            },
            ["0.4.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.3/openkal-image-0.4.3.tar.gz",
                },
                sha256 = "7b6100c9296b4aca1d07df178552307592327bee5912ae036726b6aa3afcf302",
            },
            ["0.4.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.2/openkal-image-0.4.2.tar.gz",
                },
                sha256 = "ee15f41bc1b0e50893ecb4bce9f1751285a75459b7954359f22848430313b6a7",
            },
            ["0.4.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.1/openkal-image-0.4.1.tar.gz",
                },
                sha256 = "4fbf944e61add86994daaaf0e2e1ba5a2e9c5cfc849d962059cf8ae7346ae25e",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.0/openkal-image-0.4.0.tar.gz",
                },
                sha256 = "2ffec55b912f22c3efefca4e9ad651ea0180c3d2495c8bc5413503b05524a92f",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.2/openkal-image-0.3.2.tar.gz",
                },
                sha256 = "2d9d259491e61a2a6c47661cd1dbb61fedeb562c1d6bc7941b606db870fa8345",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.1/openkal-image-0.3.1.tar.gz",
                },
                sha256 = "c5a294d71b446254ac59f9fcaf30df0de01705cb6a30d619188263822fdbaae0",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.0/openkal-image-0.3.0.tar.gz",
                },
                sha256 = "e807ab2327a5d313d6c5d1b59c0a85e8c43a409bca0d5f4b00629a3b198f231f",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.2.0/openkal-image-0.2.0.tar.gz",
                },
                sha256 = "03ea705c01b4e39a2b89956817e76a5bb7b94b4befaed6f68485bdfa105cb19a",
            },
            ["0.1.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.9/openkal-image-0.1.9.tar.gz",
                },
                sha256 = "5cef1fb2e647724998293a299377662310110646b2389b6aa9a4170253ddc10d",
            },
            ["0.1.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.8/openkal-image-0.1.8.tar.gz",
                },
                sha256 = "16cfe46581667fcaefeb288a43162f9e4e5393950f443ac7f09d6ddae313fcdd",
            },
            ["0.1.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.7/openkal-image-0.1.7.tar.gz",
                },
                sha256 = "cbe4971fd0f3ae4c3dc522d0e9ab361522670ddb90af5b64be46c362ac7ded52",
            },
            ["0.1.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.6/openkal-image-0.1.6.tar.gz",
                },
                sha256 = "0258983a10984f7b4597ed1e7dd08fb5b2dad436113574791bedc0ea2d1b002b",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.5/openkal-image-0.1.5.tar.gz",
                },
                sha256 = "5cd28c5bcebf7c4f0b9f69ea01e1e5d8f595ed148d485404ad367631c083aef8",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.4/openkal-image-0.1.4.tar.gz",
                },
                sha256 = "d9ec0dc0a78c2bdbd20f1420df510805ef3f019545cb5306393ca31765edf5ff",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.3/openkal-image-0.1.3.tar.gz",
                },
                sha256 = "eec70f276f973b1eb64b28773432489723866e38b6261edba24e137387099f23",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.2/openkal-image-0.1.2.tar.gz",
                },
                sha256 = "63768571a800f3acdad420e18c14ee1bc5142f77ef29dcf01841f40d8f1f9a25",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.1/openkal-image-0.1.1.tar.gz",
                },
                sha256 = "7b0056d62e1f297b937d63e9f59b5d82ec19f034a1286ec6ec44d6c834d5f0cc",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
        windows = {
            ["0.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.6.1/openkal-image-0.6.1.tar.gz",
                },
                sha256 = "36b792acadf4423aa5b4a90a020bb4b3dddd085ae0239f7860d12a02db0bfd99",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.6.0/openkal-image-0.6.0.tar.gz",
                },
                sha256 = "12e9a22a664a6cf6149ea375bd21797479be5ba6e0b98b36ef5f83edc534ba2f",
            },
            ["0.5.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.5.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.5/openkal-image-0.5.5.tar.gz",
                },
                sha256 = "ba1dcc6f93ec43e7c292849d8877990822873625e37c4f5b3eff5f0c4b68e789",
            },
            ["0.5.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.4.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.4/openkal-image-0.5.4.tar.gz",
                },
                sha256 = "84bc86cabd61459c202d348ffc5dcf91dd2585c351029794fefabbb839a8cf0a",
            },
            ["0.5.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.3/openkal-image-0.5.3.tar.gz",
                },
                sha256 = "8b44ad29f0ba44d3e51e5c4c0a17f48ff6d61f8d3dee5fac6ee3b17dda355fbe",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.2/openkal-image-0.5.2.tar.gz",
                },
                sha256 = "110b5c871fdf8120281be1b4398ec80ba79f9e863d99980e33d8f3bb3397f5a3",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.1/openkal-image-0.5.1.tar.gz",
                },
                sha256 = "10c4cae4dd2b46bf242332bb2150ceb34f6f084a452aec5d6a949e139c497943",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.5.0/openkal-image-0.5.0.tar.gz",
                },
                sha256 = "6b3a906cd150751c639c858c9536d10b38b51d25b1067529c50e345996344b0f",
            },
            ["0.4.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.5/openkal-image-0.4.5.tar.gz",
                },
                sha256 = "8ab1b47375a08908fb391e33aa5b92d90808531a9aec500de56ff54f46142f98",
            },
            ["0.4.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.4/openkal-image-0.4.4.tar.gz",
                },
                sha256 = "e16f9f5e04233be334fc89dcf5ce036050dc75abfb1781cf88279dab3918bb98",
            },
            ["0.4.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.3/openkal-image-0.4.3.tar.gz",
                },
                sha256 = "7b6100c9296b4aca1d07df178552307592327bee5912ae036726b6aa3afcf302",
            },
            ["0.4.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.2/openkal-image-0.4.2.tar.gz",
                },
                sha256 = "ee15f41bc1b0e50893ecb4bce9f1751285a75459b7954359f22848430313b6a7",
            },
            ["0.4.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.1/openkal-image-0.4.1.tar.gz",
                },
                sha256 = "4fbf944e61add86994daaaf0e2e1ba5a2e9c5cfc849d962059cf8ae7346ae25e",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.4.0/openkal-image-0.4.0.tar.gz",
                },
                sha256 = "2ffec55b912f22c3efefca4e9ad651ea0180c3d2495c8bc5413503b05524a92f",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.2/openkal-image-0.3.2.tar.gz",
                },
                sha256 = "2d9d259491e61a2a6c47661cd1dbb61fedeb562c1d6bc7941b606db870fa8345",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.1/openkal-image-0.3.1.tar.gz",
                },
                sha256 = "c5a294d71b446254ac59f9fcaf30df0de01705cb6a30d619188263822fdbaae0",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.3.0/openkal-image-0.3.0.tar.gz",
                },
                sha256 = "e807ab2327a5d313d6c5d1b59c0a85e8c43a409bca0d5f4b00629a3b198f231f",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.2.0/openkal-image-0.2.0.tar.gz",
                },
                sha256 = "03ea705c01b4e39a2b89956817e76a5bb7b94b4befaed6f68485bdfa105cb19a",
            },
            ["0.1.9"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.9/openkal-image-0.1.9.tar.gz",
                },
                sha256 = "5cef1fb2e647724998293a299377662310110646b2389b6aa9a4170253ddc10d",
            },
            ["0.1.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.8/openkal-image-0.1.8.tar.gz",
                },
                sha256 = "16cfe46581667fcaefeb288a43162f9e4e5393950f443ac7f09d6ddae313fcdd",
            },
            ["0.1.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.7/openkal-image-0.1.7.tar.gz",
                },
                sha256 = "cbe4971fd0f3ae4c3dc522d0e9ab361522670ddb90af5b64be46c362ac7ded52",
            },
            ["0.1.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.6/openkal-image-0.1.6.tar.gz",
                },
                sha256 = "0258983a10984f7b4597ed1e7dd08fb5b2dad436113574791bedc0ea2d1b002b",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.5/openkal-image-0.1.5.tar.gz",
                },
                sha256 = "5cd28c5bcebf7c4f0b9f69ea01e1e5d8f595ed148d485404ad367631c083aef8",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.4/openkal-image-0.1.4.tar.gz",
                },
                sha256 = "d9ec0dc0a78c2bdbd20f1420df510805ef3f019545cb5306393ca31765edf5ff",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.3/openkal-image-0.1.3.tar.gz",
                },
                sha256 = "eec70f276f973b1eb64b28773432489723866e38b6261edba24e137387099f23",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.2/openkal-image-0.1.2.tar.gz",
                },
                sha256 = "63768571a800f3acdad420e18c14ee1bc5142f77ef29dcf01841f40d8f1f9a25",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.1/openkal-image-0.1.1.tar.gz",
                },
                sha256 = "7b0056d62e1f297b937d63e9f59b5d82ec19f034a1286ec6ec44d6c834d5f0cc",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
    },

    mcpp = "*/tools/mcpp.toml",
}
