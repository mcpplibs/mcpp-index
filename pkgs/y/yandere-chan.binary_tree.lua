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
-- 0.1.3 is `git archive` of the tag, uploaded as a release asset. It renames
-- the package namespace to `yandere-chan` (lowercase); the module names are
-- unchanged.
--
-- 0.1.0-0.1.2 are intentionally not listed: all three carry the old
-- `YandereChan2` namespace. 0.1.0 also predates the `<new>` includes that keep
-- the module interfaces well-formed under libc++; a libc++ module consumer
-- still needs `#include <new>` before importing (the test member does that).
--
-- Upstream tags are bare versions (`0.1.3`), so the xpm key carries the tag
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
            ["0.1.3"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.3/binary_tree-0.1.3.tar.gz",
                sha256 = "0f96a01f35e9073f2ab3ba94592b13bd161ad3033d15bb8cfb53aa2e43ef30ed",
            },
        },
        macosx = {
            ["0.1.3"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.3/binary_tree-0.1.3.tar.gz",
                sha256 = "0f96a01f35e9073f2ab3ba94592b13bd161ad3033d15bb8cfb53aa2e43ef30ed",
            },
        },
        windows = {
            ["0.1.3"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.3/binary_tree-0.1.3.tar.gz",
                sha256 = "0f96a01f35e9073f2ab3ba94592b13bd161ad3033d15bb8cfb53aa2e43ef30ed",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
