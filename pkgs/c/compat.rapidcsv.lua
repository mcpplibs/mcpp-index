-- Form B inline descriptor for rapidcsv, a CSV parser delivered as a single
-- header. Upstream's CMake target is INTERFACE-only and exposes `src/`, so a
-- small C anchor gives mcpp a buildable library target while consumers use
-- `#include <rapidcsv.h>`.
--
-- `include_dirs = {"*/src"}` is NOT `{"*"}`: the header lives in `src/` inside
-- the archive's `rapidcsv-<ver>/` wrap layer, and the leading `*` absorbs that
-- wrap layer. Pointing at the tarball root instead would still compile the
-- anchor below -- and would still build every consumer that never includes a
-- rapidcsv header -- while `<rapidcsv.h>` failed to resolve. That is why the
-- package is exercised by a consumer test holding a real assertion, not by
-- `mcpp build`.
--
-- There is nothing to gate: the library is one header, and a header-only
-- optional part cannot be hidden behind a feature (the include root is shared).
--
-- No CN mirror yet -- the url stays a plain string (the documented fallback
-- when there is no `mcpp-res` access). Adding the mirror later only rewrites
-- `url` into `{ GLOBAL = …, CN = … }`; the sha256 does not change.
--
-- Upstream targets C++11 and later, but this package is built by mcpp, whose
-- supported standard starts at C++20: the anchor uses C++23 and consumers
-- remain free to compile the header in whatever mode they choose.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "rapidcsv",
    description = "Fast CSV parser — single-header document/column/cell access (header-only)",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/d99kris/rapidcsv",
    type        = "package",

    xpm = {
        linux = {
            ["9.07"] = {
                url    = "https://github.com/d99kris/rapidcsv/archive/refs/tags/v9.07.tar.gz",
                sha256 = "442c1d60080171fcd621d0578eb9dc03ad77781b1f4e35e7f6cd6271e4c3072e",
            },
        },
        macosx = {
            ["9.07"] = {
                url    = "https://github.com/d99kris/rapidcsv/archive/refs/tags/v9.07.tar.gz",
                sha256 = "442c1d60080171fcd621d0578eb9dc03ad77781b1f4e35e7f6cd6271e4c3072e",
            },
        },
        windows = {
            ["9.07"] = {
                url    = "https://github.com/d99kris/rapidcsv/archive/refs/tags/v9.07.tar.gz",
                sha256 = "442c1d60080171fcd621d0578eb9dc03ad77781b1f4e35e7f6cd6271e4c3072e",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/src" },
        generated_files = {
            ["mcpp_generated/rapidcsv_anchor.c"] = [==[
int mcpp_compat_rapidcsv_headers_anchor(void) { return 0; }
]==],
        },
        sources = { "mcpp_generated/rapidcsv_anchor.c" },
        targets = { ["rapidcsv"] = { kind = "lib" } },
        deps    = {},
    },
}
