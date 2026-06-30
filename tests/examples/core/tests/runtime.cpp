// Faithful migration of smoke_compat_core.sh: gtest + ftxui + lua + mbedtls +
// OpenGL/KHR headers. main() comes from the gtest "main" feature.
#include <array>
#include <string>

#include <GL/gl.h>
#include <KHR/khrplatform.h>
#include <ftxui/dom/elements.hpp>
#include <ftxui/screen/screen.hpp>
#include <gtest/gtest.h>
#include <mbedtls/sha256.h>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
}

static bool check_ftxui() {
    using namespace ftxui;
    Element document = hbox({text("compat"), separator(), text("ftxui")});
    Screen screen = Screen::Create(Dimension::Fit(document), Dimension::Fit(document));
    Render(screen, document);
    const std::string rendered = screen.ToString();
    return rendered.find("compat") != std::string::npos &&
           rendered.find("ftxui") != std::string::npos;
}
static bool check_lua() {
    lua_State* state = luaL_newstate();
    if (!state) return false;
    luaL_openlibs(state);
    const int rc = luaL_dostring(state, "return 20 + 22");
    const bool ok = rc == LUA_OK && lua_isinteger(state, -1) && lua_tointeger(state, -1) == 42;
    lua_close(state);
    return ok;
}
static bool check_mbedtls() {
    const unsigned char input[] = "abc";
    std::array<unsigned char, 32> out{};
    mbedtls_sha256(input, 3, out.data(), 0);
    return out[0] == 0xba && out[1] == 0x78 && out[30] == 0x15 && out[31] == 0xad;
}
static bool check_opengl_headers() {
    return GL_TEXTURE_2D == 0x0DE1 && static_cast<khronos_uint32_t>(1) == 1;
}

TEST(CompatGTest, BasicAssertion) { EXPECT_EQ(2 + 2, 4); }
TEST(CompatCore, UpstreamHeadersAndMinimalRuntime) {
    EXPECT_TRUE(check_ftxui());
    EXPECT_TRUE(check_lua());
    EXPECT_TRUE(check_mbedtls());
    EXPECT_TRUE(check_opengl_headers());
}
