package = {
    spec = "1",
    namespace = "mpusz",
    name = "mp-units",
    description = "Physical quantities and units through the upstream mp_units C++ modules",
    licenses = { "MIT" },
    repo = "https://github.com/mpusz/mp-units",
    type = "package",
    xpm = {
        linux = {
            ["2.5.0"] = {
                url = "https://github.com/mpusz/mp-units/archive/refs/tags/v2.5.0.tar.gz",
                sha256 = "a6bd48bee699f11f0ed5b04b8c5006d15f76e6d898e058db3880554d2e47a400",
            },
        },
        macosx = {
            ["2.5.0"] = {
                url = "https://github.com/mpusz/mp-units/archive/refs/tags/v2.5.0.tar.gz",
                sha256 = "a6bd48bee699f11f0ed5b04b8c5006d15f76e6d898e058db3880554d2e47a400",
            },
        },
        windows = {
            ["2.5.0"] = {
                url = "https://github.com/mpusz/mp-units/archive/refs/tags/v2.5.0.tar.gz",
                sha256 = "a6bd48bee699f11f0ed5b04b8c5006d15f76e6d898e058db3880554d2e47a400",
            },
        },
    },
    mcpp = {
        language = "c++23",
        import_std = true,
        modules = { "mp_units.core", "mp_units.systems", "mp_units" },
        include_dirs = { "*/src/core/include", "*/src/systems/include" },
        -- 上游 import std 配置：标准格式化、关闭运行时契约；自然单位为实验特性，LLVM 22 下约束失败
        defines = {
            "MP_UNITS_IMPORT_STD",
            "MP_UNITS_API_STD_FORMAT=1",
            "MP_UNITS_API_CONTRACTS=0",
            "MP_UNITS_API_NATURAL_UNITS=0",
        },
        sources = {
            "*/src/core/mp-units-core.cppm",
            "*/src/systems/mp-units-systems.cppm",
            "*/src/mp-units.cppm",
        },
        -- 两个上游接口的 std 导入受 MP_UNITS_IMPORT_STD 守卫
        scan_overrides = {
            ["*/src/core/mp-units-core.cppm"] = {
                provides = { "mp_units.core" }, imports = { "std" },
            },
            ["*/src/systems/mp-units-systems.cppm"] = {
                provides = { "mp_units.systems" }, imports = { "mp_units.core", "std" },
            },
        },
        targets = { ["mp-units"] = { kind = "lib" } },
        deps = {},
        linux = {
            -- 暂不支持 GCC：GCC 16.1 导入该模块时报 recursive lazy load（mpusz/mp-units#717）
            requires = { "mcpp:c++-abi=libc++" },
        },
    },
}

import("xim.libxpkg.pkginfo")

function install()
    local wrap = "mp-units-" .. pkginfo.version()
    -- 上游接口以 .cpp 命名，复制为 .cppm 供 Clang 识别为模块接口
    for _, relative in ipairs({ "src/core/mp-units-core", "src/systems/mp-units-systems", "src/mp-units" }) do
        os.cp(path.join(wrap, relative .. ".cpp"), path.join(wrap, relative .. ".cppm"))
    end
    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    os.mv(wrap, path.join(prefix, wrap))
    return true
end
