-- Form A descriptor: the godot-cpp module package ships its own mcpp.toml.
-- mcpp's default lookup finds <verdir>/*/mcpp.toml inside the GitHub source
-- tarball wrap.
--
-- The package is the thin C++23 module layer over godot-cpp's unchanged C++
-- API: `import godot_cpp;` re-exports the whole public `godot` namespace, so
-- code that used to open with a stack of `#include <godot_cpp/...>` opens with
-- one import and is otherwise the same. godot-cpp's sources and its
-- pre-generated GDExtension bindings arrive through the package's own
-- compat.godot-cpp dependency (1022-TU source build -- see
-- pkgs/c/compat.godot-cpp.lua).
--
-- Module name: ONE segment, `godot_cpp`, matching the library and the
-- `#include <godot_cpp/...>` root users already type. The dotted spelling is
-- reserved here for packages that expose several submodules (opencv.cv,
-- ffmpeg.av); this one has a single interface unit.
--
-- What the module cannot carry: MACROS. GDCLASS, GDREGISTER_CLASS,
-- GDVIRTUAL_*, D_METHOD, memnew/memdelete and the ERR_* family are
-- preprocessor constructs, and GDExtension code is written in them. The
-- package ships `<godot-cpp-m/macros.h>` for exactly that, to be included
-- next to the import; godot-cpp's headers sit in the module's global module
-- fragment, so the two spellings denote the same entities and mixing them is
-- well-formed. The package's own tests cover both shapes.
--
-- Also not re-exported (upstream's shape, not a wrapper choice): the internal
-- container templates HashMap/HashSet and their default hashers. Their inline
-- bodies reach `hash_murmur3_one_float/double`, which are `static` AND declare
-- an unnamed union -- and exposing a TU-local TYPE from a module interface is
-- a hard error, not the -Wexpose-global-module-tu-local warning. Extension
-- code uses Dictionary/Array/TypedArray; the headers still have the rest.
--
-- The version TRACKS UPSTREAM rather than counting the wrapper's own
-- iterations: 4.5.0 is the godot-cpp release it wraps, and the version
-- compat.godot-cpp carries, so the version tells a consumer the one thing
-- that matters -- which Godot they are targeting.
--
-- The name is `godot-cpp-m`, NOT `godot-cpp`, and that is load-bearing rather
-- than cosmetic. This package and its own compat.godot-cpp dependency are
-- always resolved together, and mcpp's installed-package lookup matches on
-- (name, version) WITHOUT the namespace: with both named `godot-cpp` at the
-- same version -- which "the version tracks upstream" guarantees -- resolving
-- this one lands on compat's unpacked directory and fails with "no mcpp.toml
-- at <verdir>/*/mcpp.toml". Reproducible with a namespace unrelated to either
-- package: leave a single <anything>-x-godot-cpp/4.5.0 in the store and the
-- resolution goes to it; remove it and the same descriptor installs fine. The
-- store DIRECTORIES are namespaced (ns-x-name) -- the lookup is not. Distinct
-- short names sidestep it, keep the version tracking upstream, and `-m`
-- matches the repository name. `import godot_cpp;` is unaffected.
--
-- Versions track upstream godot-cpp one for one, as compat.godot-cpp's do:
-- 10.0.0-rc1 binds Godot 4.6, 4.5.0 binds Godot 4.5.
--
-- 10.0.0-rc1 additionally ships a generated `hashfuncs.hpp` shim -- upstream's
-- header with `static` dropped from two functions -- without which GCC refuses
-- the module interface outright ("exposes TU-local entity 'union <unnamed>'",
-- a hard error no -W flag reaches). It is scoped to the package's own include
-- path, so compat.godot-cpp still compiles upstream's copy untouched. See the
-- package README.
--
-- CN tags carry an `-m` suffix: the gitcode mirror repo is shared with the
-- compat.godot-cpp archives, which already hold the bare-version tags.
--
-- Three platforms, one OS-neutral tarball: godot-cpp is portable C++ and
-- compat.godot-cpp covers all three.
package = {
    spec        = "1",
    name        = "godot-cpp-m",
    namespace   = "godotengine",
    description = "C++23 module package for godot-cpp (import godot_cpp) — Godot GDExtension API, C++ API unchanged",
    licenses    = {"MIT"},   -- module layer; upstream godot-cpp is MIT as well
    repo        = "https://github.com/mcpplibs/godot-cpp-m",
    type        = "package",

    xpm = {
        linux = {
            ["10.0.0-rc1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/archive/refs/tags/v10.0.0-rc1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/godot-cpp/releases/download/v10.0.0-rc1-m/godot-cpp-m-10.0.0-rc1.tar.gz",
                },
                sha256 = "895975f32456d821b1297dbd5298ea3e9b925b00557a187927f3dacf2f035220",
            },
            ["4.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/archive/refs/tags/v4.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/godot-cpp/releases/download/v4.5.0-m/godot-cpp-m-4.5.0.tar.gz",
                },
                sha256 = "d91794f46ec4a74c1f8c61c894efdecceaf54feff103b9b139fd6a8f16e43051",
            },
        },
        macosx = {
            ["10.0.0-rc1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/archive/refs/tags/v10.0.0-rc1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/godot-cpp/releases/download/v10.0.0-rc1-m/godot-cpp-m-10.0.0-rc1.tar.gz",
                },
                sha256 = "895975f32456d821b1297dbd5298ea3e9b925b00557a187927f3dacf2f035220",
            },
            ["4.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/archive/refs/tags/v4.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/godot-cpp/releases/download/v4.5.0-m/godot-cpp-m-4.5.0.tar.gz",
                },
                sha256 = "d91794f46ec4a74c1f8c61c894efdecceaf54feff103b9b139fd6a8f16e43051",
            },
        },
        windows = {
            ["10.0.0-rc1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/archive/refs/tags/v10.0.0-rc1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/godot-cpp/releases/download/v10.0.0-rc1-m/godot-cpp-m-10.0.0-rc1.tar.gz",
                },
                sha256 = "895975f32456d821b1297dbd5298ea3e9b925b00557a187927f3dacf2f035220",
            },
            ["4.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/archive/refs/tags/v4.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/godot-cpp/releases/download/v4.5.0-m/godot-cpp-m-4.5.0.tar.gz",
                },
                sha256 = "d91794f46ec4a74c1f8c61c894efdecceaf54feff103b9b139fd6a8f16e43051",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
