-- Form B inline descriptor for pybind11, a header-only library for creating
-- Python bindings from C++.
--
-- Python's headers and import library are supplied by the consumer's Python
-- installation. The companion build.mcpp test demonstrates how to discover
-- those platform-specific paths and add them to an mcpp build.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "pybind11",
    description = "Seamless operability between C++11 and Python",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/pybind/pybind11",
    type        = "package",

    xpm = {
        linux = {
            ["3.2.0"] = {
                url    = "https://github.com/pybind/pybind11/archive/6254086d96062249c5153c17eab6b4437dd1589f.tar.gz",
                sha256 = "4a77778750ae4bd27d29dd328902b03a7efb9c3468c6f23180fa39d80c05f635",
            },
        },
        macosx = {
            ["3.2.0"] = {
                url    = "https://github.com/pybind/pybind11/archive/6254086d96062249c5153c17eab6b4437dd1589f.tar.gz",
                sha256 = "4a77778750ae4bd27d29dd328902b03a7efb9c3468c6f23180fa39d80c05f635",
            },
        },
        windows = {
            ["3.2.0"] = {
                url    = "https://github.com/pybind/pybind11/archive/6254086d96062249c5153c17eab6b4437dd1589f.tar.gz",
                sha256 = "4a77778750ae4bd27d29dd328902b03a7efb9c3468c6f23180fa39d80c05f635",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/pybind11_anchor.c"] = [==[
int mcpp_pybind11_headers_anchor(void) { return 0; }
]==],
        },
        sources = { "mcpp_generated/pybind11_anchor.c" },
        targets = { ["pybind11"] = { kind = "lib" } },
        deps    = {},
    },
}
