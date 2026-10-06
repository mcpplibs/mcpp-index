-- 本检查以最小模块片段验证真实安装钩子的匹配边界，不访问网络或改动安装目录
local descriptor = arg[1] or "pkgs/o/odygrd.quill.lua"
local guard = "#if !defined(__INTEL_COMPILER)\n"
local declaration = "export module quill;\n"
local fixture = "module;\n" .. guard .. "#endif\n" .. declaration

local function run(content)
    local output, output_path
    local mutations = 0
    local function mutate() mutations = mutations + 1 end
    local env = setmetatable({
        import = function(name) assert(name == "xim.libxpkg.pkginfo") end,
        pkginfo = {
            version = function() return "13.0.0" end,
            install_dir = function() return "test-prefix" end,
        },
        path = { join = function(...) return table.concat({...}, "/") end },
        io = {
            readfile = function(path)
                assert(path == "quill-13.0.0/src/quill.cc")
                return content
            end,
            writefile = function(path, value)
                output_path, output = path, value
                mutate()
            end,
        },
        os = { tryrm = mutate, mkdir = mutate, mv = mutate },
    }, { __index = _G })
    assert(loadfile(descriptor, "t", env))()
    local ok, result = pcall(env.install)
    return ok, result, output, output_path, mutations
end

local ok, result, lf, path = run(fixture)
assert(ok and result == true, "LF input must install")
assert(path == "quill-13.0.0/src/quill.cppm", "module interface output path")
local crlf_ok, crlf_result, crlf = run((fixture:gsub("\n", "\r\n")))
assert(crlf_ok and crlf_result == true and crlf == lf, "CRLF and LF must generate identical output")
assert(not lf:find("\r", 1, true), "generated content must use normalized newlines")
assert(lf:find("defined(__i386__) || defined(__x86_64__)", 1, true), "x86 headers need an architecture guard")
local module_position = assert(lf:find(declaration, 1, true))
for _, header in ipairs({ "<mach/thread_act.h>", "<unistd.h>", "<fcntl.h>", "<charconv>" }) do
    local position = assert(lf:find("#include " .. header, 1, true), "missing global header " .. header)
    assert(position < module_position, "system headers must precede the module declaration")
end

local function rejects(content, expected)
    local accepted, message, _, _, mutations = run(content)
    assert(not accepted and tostring(message):find(expected, 1, true), expected)
    assert(mutations == 0, "invalid input must fail before writing or replacing installed files")
end

rejects(nil, "cannot read")
rejects("module;\n" .. guard .. "#endif\n", "expected exactly one module declaration")
rejects(fixture .. declaration, "expected exactly one module declaration")
rejects("module;\n" .. declaration, "expected exactly one patch match")
rejects(fixture .. guard .. "#endif\n", "expected exactly one patch match")
print("Quill install hook: LF/CRLF and five invalid-input cases passed")
