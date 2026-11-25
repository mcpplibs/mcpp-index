import std;
import mcpplibs.mwrap.lua;

using namespace mcpplibs::mwrap::lua::macros;

namespace {
int add(lua_State* L) {
    lua_pushinteger(L, luaL_checkinteger(L, 1) + luaL_checkinteger(L, 2));
    return 1;
}
int counter(lua_State* L) {
    lua_pushinteger(L, lua_tointeger(L, lua_upvalueindex(1)) + 1);
    lua_copy(L, -1, lua_upvalueindex(1));
    return 1;
}
}  // namespace

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    lua_register(L, "add", add);
    lua_pushinteger(L, 0);
    lua_pushcclosure(L, counter, 1);
    lua_setglobal(L, "count");
    // A chunk calling a C function and a closure; the result read back.
    if (luaL_dostring(L, "count(); return add(40, count()), _VERSION")) return 1;
    if (lua_tointeger(L, -2) != 42 || std::string_view(lua_tostring(L, -1)) != LUA_VERSION) return 2;
    lua_pop(L, 2);
    // An error through lua_pcall, with its message.
    if (luaL_loadstring(L, "return add('x', 1)") != LUA_OK || lua_pcall(L, 0, 1, 0) != LUA_ERRRUN) return 3;
    if (!std::string_view(lua_tostring(L, -1)).contains("bad argument #1")) return 4;
    lua_pop(L, 1);
    // Userdata with a metatable from the registry.
    luaL_newmetatable(L, "Box");
    lua_pop(L, 1);
    *static_cast<double*>(lua_newuserdatauv(L, sizeof(double), 0)) = 2.5;
    luaL_setmetatable(L, "Box");
    if (*static_cast<double*>(luaL_checkudata(L, -1, "Box")) != 2.5) return 5;
    lua_close(L);
    std::println("lua-embed: ok ({})", LUA_RELEASE);
    return 0;
}
