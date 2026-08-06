-- Dear ImGui 的 C++23 module 层。上游是 ocornut/imgui,本包只是在它之上加模块。
--
-- 由 `mcpplibs:imgui@0.0.6` 迁来。旧条目(pkgs/i/imgui.lua)冻结保留,老消费者
-- 继续解析得到,新版本只在这里发布。
--
-- `imgui.app` 是 imgui-m 发明的 facade,不属于上游,因此收在 `app` feature 后;
-- backends 属于上游(上游自己就发 backends/imgui_impl_glfw.cpp),默认给。
-- 命名空间说的是这个库是谁的,不是谁打的包;版本说的是你拿到的是哪一版上游。
-- 规则与全生态迁移表:mcpp-index#163。
--
-- `mcpplibs` 是 mcpp 的**默认命名空间**(`kDefaultNamespace`),裸名就落在那里 ——
-- 它不是"上游是谁"的答案。因此上游库迁到上游 org 名下,消费者写限定名。
package = {
    spec        = "1",
    namespace   = "ocornut",
    name        = "imgui",
    description = "Dear ImGui 1.92.8 core and GLFW/OpenGL3 backend modules for mcpp (import imgui.core;)",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/imgui-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.8"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/1.92.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8/imgui-m-1.92.8.tar.gz",
                },
                sha256 = "dec31c8317cd9216097789f6cde1295616f8a0a7568037b9e6c84db01fcc4f7f",
            },
        },
        macosx = {
            ["1.92.8"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/1.92.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8/imgui-m-1.92.8.tar.gz",
                },
                sha256 = "dec31c8317cd9216097789f6cde1295616f8a0a7568037b9e6c84db01fcc4f7f",
            },
        },
        windows = {
            ["1.92.8"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/1.92.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8/imgui-m-1.92.8.tar.gz",
                },
                sha256 = "dec31c8317cd9216097789f6cde1295616f8a0a7568037b9e6c84db01fcc4f7f",
            },
        },
    },

    -- (无 `mcpp` 字段 —— 默认查找会命中 <verdir>/*/mcpp.toml)
}
