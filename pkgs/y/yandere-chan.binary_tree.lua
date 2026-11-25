-- yandere-chan.binary_tree — Intrusive and owning binary tree library with
-- C++23 module wrappers.
--
-- Form A: the release tarball carries the package's own `mcpp.toml` at its
-- root (`binary_tree-<version>/mcpp.toml`), and that manifest is the build: it
-- declares the header library (`include_dirs = ["."]`), the three module
-- wrappers `Yc.intrusive_binary_tree` / `Yc.binary_tree` /
-- `Yc.parent_aware_binary_tree`, and the lib root `src/binary_tree.cppm` that
-- re-exports them for `import binary_tree;`. The `mcpp` field is therefore the
-- wrapper-directory pointer, not an inline Form B descriptor.
--
-- 0.1.4 is `git archive` of the tag, uploaded as a release asset. Besides the
-- `yandere-chan` namespace it exports the global `operator new` / `operator
-- delete` using-declarations from all three module interfaces, so a libc++
-- consumer does not need `#include <new>`: clang's combined `-fmodule-output`
-- build does not make the module's GMF `<new>` visible to importers, and
-- libc++'s `allocator_traits::construct` looks placement new up at
-- instantiation (llvm/llvm-project#218246).
--
-- 0.1.0-0.1.3 are intentionally not listed: all four carry the old
-- `YandereChan2` namespace, and 0.1.0-0.1.3 predate the exported
-- `operator new`/`operator delete` declarations.
--
-- Upstream tags are bare versions (`0.1.4`), so the xpm key carries the tag
-- verbatim and autoupdate's tag pattern is `${version}`.
--
-- No mcpp-res mirror is configured yet (no CN access): the plain-string GLOBAL
-- url is the documented fallback for CN consumers until a maintainer creates
-- the mirror.
package = {
    spec        = "1",
    namespace   = "yandere-chan",
    name        = "binary_tree",
    description = "Intrusive and owning binary tree library, with C++23 module wrappers",
    licenses    = {"MIT"},
    repo        = "https://github.com/YandereChan2/binary_tree",
    type        = "package",
    maintainers = {"YandereChan2"},

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/YandereChan2/binary_tree/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.1.4"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.4/binary_tree-0.1.4.tar.gz",
                sha256 = "e7bd88adaa156219d87db05cbe4bc0dd5447ee7c7736f138f0870ebdfa706853",
            },
        },
        macosx = {
            ["0.1.4"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.4/binary_tree-0.1.4.tar.gz",
                sha256 = "e7bd88adaa156219d87db05cbe4bc0dd5447ee7c7736f138f0870ebdfa706853",
            },
        },
        windows = {
            ["0.1.4"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.4/binary_tree-0.1.4.tar.gz",
                sha256 = "e7bd88adaa156219d87db05cbe4bc0dd5447ee7c7736f138f0870ebdfa706853",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
