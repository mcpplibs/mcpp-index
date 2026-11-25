-- Immutable upstream-aligned mwrap source release (cgltf-m mwrap-1.15);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it vendors and links statically,
-- cgltf 1.15 (it embeds jsmn), is MIT: the package deploys its README and
-- LICENSE beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "cgltf",
    description = "cgltf-m: cgltf 1.15 (glTF 2.0 loader and writer: parsing, buffers, validation, accessors, node transforms) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/cgltf-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/cgltf-m/releases/download/${tag}/cgltf-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.15"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/cgltf-m/releases/download/mwrap-1.15/cgltf-m-1.15.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-cgltf/releases/download/1.15/cgltf-m-1.15.tar.gz",
                },
                sha256 = "242d90c65178d0746a25a22b375984bf95af19d9820f7d91b0fb32a06d51070b",
            },
        },
        macosx = {
            ["1.15"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/cgltf-m/releases/download/mwrap-1.15/cgltf-m-1.15.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-cgltf/releases/download/1.15/cgltf-m-1.15.tar.gz",
                },
                sha256 = "242d90c65178d0746a25a22b375984bf95af19d9820f7d91b0fb32a06d51070b",
            },
        },
        windows = {
            ["1.15"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/cgltf-m/releases/download/mwrap-1.15/cgltf-m-1.15.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-cgltf/releases/download/1.15/cgltf-m-1.15.tar.gz",
                },
                sha256 = "242d90c65178d0746a25a22b375984bf95af19d9820f7d91b0fb32a06d51070b",
            },
        },
    },
}
