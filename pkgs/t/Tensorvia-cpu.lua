-- Form A descriptor: the upstream repo ships its own mcpp.toml, so we omit
-- the `mcpp` field — mcpp default-look-up finds <verdir>/<repo-tag>/mcpp.toml
-- inside the GitHub tarball wrap.
package = {
    spec        = "1",
    namespace   = "aimol",
    name        = "aimol.Tensorvia-cpu",
    maintainers = {"Aimol-l"},
    description = "CPU backend of Tensorvia, ported to C++23 modules",
    licenses    = {"MIT"},
    repo        = "https://github.com/Aimol-l/Tensorvia-cpu",
    type        = "package",

    xpm = {
        linux   = {
            ['0.1.0'] = { url = "https://github.com/Aimol-l/Tensorvia-cpu/releases/download/v0.1.0/Tensorvia-cpu-0.1.0.tar.gz", sha256 = "d44dac5ba61940105aa028a2d56861758b7784f03d00971e566d2224b6523836" },
        },
        macosx  = {
            ['0.1.0'] = { url = "https://github.com/Aimol-l/Tensorvia-cpu/releases/download/v0.1.0/Tensorvia-cpu-0.1.0.tar.gz", sha256 = "d44dac5ba61940105aa028a2d56861758b7784f03d00971e566d2224b6523836" },
        },
        windows = {
            ['0.1.0'] = { url = "https://github.com/Aimol-l/Tensorvia-cpu/releases/download/v0.1.0/Tensorvia-cpu-0.1.0.tar.gz", sha256 = "d44dac5ba61940105aa028a2d56861758b7784f03d00971e566d2224b6523836" },
        },
    },
}
