package = {
    spec        = "1",
    namespace   = "taskflow",
    name        = "taskflow",
    description = "Taskflow CPU task graphs through the upstream tf C++ module",
    licenses    = { "MIT" },
    repo        = "https://github.com/taskflow/taskflow",
    type        = "package",

    xpm = {
        linux = {
            ["4.1.0"] = {
                url = "https://github.com/taskflow/taskflow/archive/refs/tags/v4.1.0.tar.gz",
                sha256 = "2107f90e315e48a676922010b036357ff2b0c6b9160ce17fa9396e5860b1d715",
            },
        },
        macosx = {
            ["4.1.0"] = {
                url = "https://github.com/taskflow/taskflow/archive/refs/tags/v4.1.0.tar.gz",
                sha256 = "2107f90e315e48a676922010b036357ff2b0c6b9160ce17fa9396e5860b1d715",
            },
        },
        windows = {
            ["4.1.0"] = {
                url = "https://github.com/taskflow/taskflow/archive/refs/tags/v4.1.0.tar.gz",
                sha256 = "2107f90e315e48a676922010b036357ff2b0c6b9160ce17fa9396e5860b1d715",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        modules      = { "tf" },
        include_dirs = { "*" },
        -- CUDA 入口同样提供 tf 主模块，与 CPU 入口不能同时编译
        sources = {
            "*/modules/tf.core.cppm",
            "*/modules/tf.algorithm.cppm",
            "*/modules/tf.utility.cppm",
            "*/modules/tf.cppm",
        },
        targets = { ["taskflow"] = { kind = "lib" } },
        deps = {},
        linux = {
            -- 模块编译选项须与消费者一致，线程依赖在最终链接时满足
            ldflags = { "-pthread" },
        },
    },
}

import("xim.libxpkg.pkginfo")

function install()
    local wrap = "taskflow-" .. pkginfo.version()
    local function patch(relative, before, after)
        local source = path.join(wrap, relative)
        local content = assert(io.readfile(source), "taskflow.taskflow: cannot read " .. source)
        local pattern = before:gsub("(%W)", "%%%1")
        local patched, count = content:gsub(pattern, function() return after end)
        assert(count == 1, "taskflow.taskflow: expected exactly one match in " .. source)
        io.writefile(source, patched)
    end

    -- 4.1.0 的模块导出表包含两个在该版本头文件中不存在的名字
    for _, name in ipairs({ "HasGraph", "ProfileData" }) do
        patch("modules/tf.core.cppm", "    using tf::" .. name .. ";\n", "")
    end

    -- 主接口的重复头声明会遮蔽 GCC 从分区导出的类型，版本声明随 core 导出
    patch("modules/tf.core.cppm", "module;\n", "module;\n#include <taskflow/taskflow.hpp>\n")
    patch("modules/tf.core.cppm", "export namespace tf {\n",
        "export namespace tf {\n    using tf::version;\n")
    patch("modules/tf.cppm", "#include <taskflow/taskflow.hpp>\n", "")
    patch("modules/tf.cppm", "export import :algorithm;\nexport import :core;",
        "export import :core;\nexport import :algorithm;")

    -- iterator.hpp 使用 std::max，但 libc++ 的间接包含不提供它
    patch("modules/tf.utility.cppm", "module;\n", "module;\n#include <algorithm>\n")

    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    os.mv(wrap, path.join(prefix, wrap))
    return true
end
