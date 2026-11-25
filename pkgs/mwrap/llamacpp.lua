-- Immutable upstream-aligned mwrap source release; GLOBAL and CN bytes are identical.
--
-- b10069.2 is a wrapper revision: its templates write the dependency selector
-- unquoted (`mcpplibs.mwrap.llamacpp = ...`); the quoted form is deprecated
-- since mcpp 2026.11.8.1 and removed in 2027.2.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "llamacpp",
    description = "llama.cpp-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/llama.cpp-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/llama.cpp-m/releases/download/${tag}/llama.cpp-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["b10069.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/releases/download/mwrap-b10069.2/llama.cpp-m-b10069.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-llamacpp/releases/download/b10069.2/llama.cpp-m-b10069.2.tar.gz",
                },
                sha256 = "f27377094656168a91f326af427580d7c9ebf22307e0c36f46cea009e5cd93d0",
            },
            ["b10069"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/releases/download/mwrap-b10069/llama.cpp-m-b10069.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-llamacpp/releases/download/b10069/llama.cpp-m-b10069.tar.gz",
                },
                sha256 = "a1cf4b70d833bf1edd50fb70355768d109956191aae15c13775341b71bffe2e6",
            },
        },
        macosx = {
            ["b10069.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/releases/download/mwrap-b10069.2/llama.cpp-m-b10069.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-llamacpp/releases/download/b10069.2/llama.cpp-m-b10069.2.tar.gz",
                },
                sha256 = "f27377094656168a91f326af427580d7c9ebf22307e0c36f46cea009e5cd93d0",
            },
            ["b10069"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/releases/download/mwrap-b10069/llama.cpp-m-b10069.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-llamacpp/releases/download/b10069/llama.cpp-m-b10069.tar.gz",
                },
                sha256 = "a1cf4b70d833bf1edd50fb70355768d109956191aae15c13775341b71bffe2e6",
            },
        },
        windows = {
            ["b10069.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/releases/download/mwrap-b10069.2/llama.cpp-m-b10069.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-llamacpp/releases/download/b10069.2/llama.cpp-m-b10069.2.tar.gz",
                },
                sha256 = "f27377094656168a91f326af427580d7c9ebf22307e0c36f46cea009e5cd93d0",
            },
            ["b10069"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/releases/download/mwrap-b10069/llama.cpp-m-b10069.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-llamacpp/releases/download/b10069/llama.cpp-m-b10069.tar.gz",
                },
                sha256 = "a1cf4b70d833bf1edd50fb70355768d109956191aae15c13775341b71bffe2e6",
            },
        },
    },
}
