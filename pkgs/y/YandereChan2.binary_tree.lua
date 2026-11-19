-- YandereChan2.binary_tree — Intrusive and owning binary tree library with
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
-- 0.1.2 is `git archive` of the tag, uploaded as a release asset (same bytes
-- as the 0.1.2 release download). The autoupdate template below uses the tag
-- archive instead; a new version needs no uploaded asset for the updater to
-- compute its sha.
--
-- 0.1.0 and 0.1.1 are intentionally not listed. A libc++ module consumer
-- (clang + libc++) could not instantiate insert/emplace because placement new
-- was not declared: 0.1.0 had no <new> include at all, and 0.1.1 put it after
-- <memory>, too late for libc++'s allocator_traits/construct_at definition.
-- 0.1.2 includes <new> before <memory> in the owning headers and in the global
-- module fragments.
--
-- Upstream tags are bare versions (`0.1.2`), so the xpm key carries the tag
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
            ["0.1.2"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.2/binary_tree-0.1.2.tar.gz",
                sha256 = "4c537f68af5cddd0e6e3c28aae5663414cd68c609eeb26513694c5e2c1e8fa21",
            },
        },
        macosx = {
            ["0.1.2"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.2/binary_tree-0.1.2.tar.gz",
                sha256 = "4c537f68af5cddd0e6e3c28aae5663414cd68c609eeb26513694c5e2c1e8fa21",
            },
        },
        windows = {
            ["0.1.2"] = {
                url    = "https://github.com/YandereChan2/binary_tree/releases/download/0.1.2/binary_tree-0.1.2.tar.gz",
                sha256 = "4c537f68af5cddd0e6e3c28aae5663414cd68c609eeb26513694c5e2c1e8fa21",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
