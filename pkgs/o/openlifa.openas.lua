-- openlifa.openas --- the openas specification, an OpenLifa standard, and the
-- C++ modules that declare it.
--
-- Actors and what they do with a system: who did it and for whom (the actor
-- and its delegation), the effect class of a verb, grants under a system's cap
-- and the decision for one request, and the envelope a run is reported in.
-- The modules are `openas` and `openas.conformance`, named for the
-- specification rather than the organization that publishes it.
--
-- No `deps`. Standard library only.
package = {
    spec        = "1",
    namespace   = "openlifa",
    name        = "openas",
    description = "openas: actors, effects, grants and the run envelope --- an OpenLifa specification and its C++ modules",
    licenses    = {"Apache-2.0", "CC-BY-SA-4.0"},
    repo        = "https://github.com/openlifa/openas",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/openlifa/openas/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = "https://github.com/openlifa/openas/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "110f135810ec5f0878373e1bda336e04054a3805859b068b76af5e7aebf9b647",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = "https://github.com/openlifa/openas/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "110f135810ec5f0878373e1bda336e04054a3805859b068b76af5e7aebf9b647",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = "https://github.com/openlifa/openas/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "110f135810ec5f0878373e1bda336e04054a3805859b068b76af5e7aebf9b647",
            },
        },
    },
}
