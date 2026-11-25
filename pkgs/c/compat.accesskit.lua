-- compat.accesskit — AccessKit's C bindings (accesskit-c), prebuilt: a UI
-- describes its tree once and AccessKit serves it to each platform's
-- assistive technology — UI Automation on Windows, NSAccessibility on macOS,
-- AT-SPI on Linux (a screen reader, a magnifier, voice control).
--
-- THE LIBRARY IS RUST, SO ITS RELEASE IS THE ARTIFACT. Building it here would
-- need a Rust toolchain in the recipe; upstream's release archive carries the
-- header and a static library for every platform it supports, built from the
-- tagged source by its own CI. This descriptor exposes the header and links the
-- static library of the host's platform, with the system libraries upstream's
-- own `accesskit-config.cmake` names for each.
--
-- WHAT IS NOT COVERED: upstream ships no Linux arm64 build, and this version
-- links macOS arm64 and Windows x86_64 (the x86_64 Mac and arm64 Windows
-- libraries are in the archive too, but the index states one library path per
-- platform). A consumer that wants AccessKit there gates its use by platform.
--
-- One archive for all three platforms (about 64 MB): the paths below reach into
-- its `accesskit-c-0.23.1/` wrap layer; mcpp rewrites a relative `-L` to the
-- package's own directory.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "accesskit",
    description = "AccessKit C bindings (prebuilt static library): one accessibility tree served to UIA, NSAccessibility and AT-SPI",
    licenses    = {"MIT", "Apache-2.0"},
    repo        = "https://github.com/AccessKit/accesskit-c",
    type        = "package",

    -- A new release is found and fetched by the updater; the library paths
    -- below name the archive's versioned wrap layer, so its candidate build
    -- says when they need the new version too.
    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/AccessKit/accesskit-c/releases/download/${tag}/accesskit-c-${version}.zip",
        },
    },

    xpm = {
        linux = {
            ["0.23.1"] = {
                url    = "https://github.com/AccessKit/accesskit-c/releases/download/0.23.1/accesskit-c-0.23.1.zip",
                sha256 = "35b7ca8a6f1e038b5da35e1e9e5a0adaed9bfcf21e1496d29598fbbadcc7043f",
            },
            ["latest"] = { ref = "0.23.1" },
        },
        macosx = {
            ["0.23.1"] = {
                url    = "https://github.com/AccessKit/accesskit-c/releases/download/0.23.1/accesskit-c-0.23.1.zip",
                sha256 = "35b7ca8a6f1e038b5da35e1e9e5a0adaed9bfcf21e1496d29598fbbadcc7043f",
            },
            ["latest"] = { ref = "0.23.1" },
        },
        windows = {
            ["0.23.1"] = {
                url    = "https://github.com/AccessKit/accesskit-c/releases/download/0.23.1/accesskit-c-0.23.1.zip",
                sha256 = "35b7ca8a6f1e038b5da35e1e9e5a0adaed9bfcf21e1496d29598fbbadcc7043f",
            },
            ["latest"] = { ref = "0.23.1" },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/accesskit_anchor.c"] = "int mcpp_compat_accesskit_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/accesskit_anchor.c" },
        targets = { ["accesskit"] = { kind = "lib" } },
        deps    = {},
        -- The static library and what upstream's accesskit-config.cmake links beside it.
        linux = {
            ldflags = { "-Laccesskit-c-0.23.1/lib/linux/x86_64/static", "-l:libaccesskit.a", "-static-libgcc", "-lm" },
        },
        macosx = {
            ldflags = { "-Laccesskit-c-0.23.1/lib/macos/arm64/static", "-laccesskit",
                        "-framework", "AppKit", "-framework", "Foundation", "-framework", "CoreFoundation", "-lobjc", "-lc++" },
        },
        windows = {
            ldflags = { "-Laccesskit-c-0.23.1/lib/windows/x86_64/msvc/static", "-laccesskit",
                        "-lbcrypt", "-lntdll", "-lpropsys", "-lruntimeobject", "-luiautomationcore", "-luserenv", "-lws2_32" },
        },
    },
}
