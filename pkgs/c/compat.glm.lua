-- compat.glm — OpenGL Mathematics, the vector/matrix library graphics code is
-- written against.
--
-- Shape B, and the include root is the TARBALL ROOT rather than an `include/`
-- directory: upstream's headers live at `glm-1.0.2/glm/glm.hpp`, and the
-- spelling every consumer uses is `#include <glm/glm.hpp>`. So `include_dirs`
-- is `*` — the same call `compat.cjson` makes for a flat tarball, for the same
-- reason.
--
-- HEADER-ONLY IS THE DEFAULT AND WE KEEP IT. The tarball does carry one
-- compilable file, `glm/glm.cpp`, but it is not a source in the ordinary
-- sense: it exists only for upstream's optional `GLM_STATIC_LIBRARY` /
-- `GLM_BUILD_LIBRARY` mode, where it force-instantiates the templates into a
-- real archive. Compiling it here would buy nothing (nothing links against
-- those instantiations unless the consumer also defines the macro that makes
-- the headers declare rather than define) and would drag a C++ TU into a
-- package that otherwise has none. The anchor TU below stays C, like every
-- other header-only entry in this index.
--
-- The other 209 `.cpp` in the tarball are `test/` and `util/`; no glob here
-- can reach them, because none is written.
--
-- Consumers usually want two switches, and both are consumer-side rather than
-- ours: `GLM_FORCE_DEPTH_ZERO_TO_ONE` (Vulkan's clip space, where OpenGL's
-- -1..1 default is wrong) and `GLM_ENABLE_EXPERIMENTAL` (for the `gtx/`
-- headers). They are NOT set here on purpose — they change the meaning of the
-- types crossing a library boundary, so a package that decided them for
-- everyone would silently disagree with a consumer that decided otherwise.
--
-- License: upstream is dual "The Happy Bunny License OR MIT" (copying.txt).
-- Happy Bunny is MIT plus a no-harm clause and has no SPDX identifier, so the
-- MIT arm — the one every consumer takes — is what is declared.
--
-- CN mirror: `gitcode.com/mcpp-res/glm`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here, which is what lets one `sha256` serve both arms). GLOBAL stays the
-- default; CN is the fallback `mcpp self config --mirror CN` selects.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "glm",
    description = "OpenGL Mathematics — header-only vector and matrix library for graphics",
    licenses    = {"MIT"},
    repo        = "https://github.com/g-truc/glm",
    type        = "package",

    xpm = {
        linux = {
            ["1.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/g-truc/glm/archive/refs/tags/1.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glm/releases/download/1.0.2/glm-1.0.2.tar.gz",
                },
                sha256 = "19edf2e860297efab1c74950e6076bf4dad9de483826bc95e2e0f2c758a43f65",
            },
        },
        macosx = {
            ["1.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/g-truc/glm/archive/refs/tags/1.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glm/releases/download/1.0.2/glm-1.0.2.tar.gz",
                },
                sha256 = "19edf2e860297efab1c74950e6076bf4dad9de483826bc95e2e0f2c758a43f65",
            },
        },
        windows = {
            ["1.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/g-truc/glm/archive/refs/tags/1.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glm/releases/download/1.0.2/glm-1.0.2.tar.gz",
                },
                sha256 = "19edf2e860297efab1c74950e6076bf4dad9de483826bc95e2e0f2c758a43f65",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*" },
        generated_files = {
            ["mcpp_generated/glm_anchor.c"] =
                "int mcpp_compat_glm_anchor(void) { return 0; }\n",
        },
        sources      = { "mcpp_generated/glm_anchor.c" },
        targets      = { ["glm"] = { kind = "lib" } },
        deps         = { },
    },
}
