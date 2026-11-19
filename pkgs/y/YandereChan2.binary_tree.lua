-- YandereChan2.binary_tree — Intrusive and owning binary tree library with
-- C++23 module wrappers.
--
-- Form A: the tag tarball carries the package's own `mcpp.toml` at its root
-- (`binary_tree-<version>/mcpp.toml`), and that manifest is the build: it
-- declares the header library (`include_dirs = ["."]`), the three module
-- wrappers `Yc.intrusive_binary_tree` / `Yc.binary_tree` /
-- `Yc.parent_aware_binary_tree`, and the lib root `src/binary_tree.cppm` that
-- re-exports them for `import binary_tree;`. The `mcpp` field is therefore the
-- wrapper-directory pointer, not an inline Form B descriptor.
--
-- Upstream tags are bare versions (`0.1.0`), so the xpm key carries the tag
-- verbatim and autoupdate's tag pattern is `${version}`.
--
-- No mcpp-res mirror is configured yet (no CN access): the plain-string GLOBAL
-- url is the documented fallback for CN consumers until a maintainer creates
-- the mirror.
package = {
    spec        = "1",
    namespace   = "YandereChan2",
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
            ["0.1.0"] = {
                url    = "https://github.com/YandereChan2/binary_tree/archive/refs/tags/0.1.0.tar.gz",
                sha256 = "30bf78e87e958b2147de62e154ea01d3149efafa47ae17b67395e8ae3faf7937",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = "https://github.com/YandereChan2/binary_tree/archive/refs/tags/0.1.0.tar.gz",
                sha256 = "30bf78e87e958b2147de62e154ea01d3149efafa47ae17b67395e8ae3faf7937",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = "https://github.com/YandereChan2/binary_tree/archive/refs/tags/0.1.0.tar.gz",
                sha256 = "30bf78e87e958b2147de62e154ea01d3149efafa47ae17b67395e8ae3faf7937",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
