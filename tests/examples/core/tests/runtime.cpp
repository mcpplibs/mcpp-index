// Faithful migration of smoke_compat_core.sh: gtest + ftxui + lua + mbedtls +
// OpenGL/KHR headers. main() comes from the gtest "main" feature.
#include <array>
#include <cstddef>
#include <string>

#include <GL/gl.h>
#include <KHR/khrplatform.h>
#include <ftxui/dom/elements.hpp>
#include <ftxui/screen/screen.hpp>
#include <gtest/gtest.h>
#include <mbedtls/sha256.h>
#include <psa/crypto.h>

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
    if (!(out[0] == 0xba && out[1] == 0x78 && out[30] == 0x15 && out[31] == 0xad)) {
        return false;
    }

    if (psa_crypto_init() != PSA_SUCCESS) {
        return false;
    }

    // RFC 4231 Test Case 2 (HMAC-SHA256) exercises psa_mac_compute() / mbedtls_psa_mac_compute().
    const unsigned char hmac_key[] = {'J', 'e', 'f', 'e'};
    const unsigned char hmac_msg[] = "what do ya want for nothing?";
    constexpr std::array<unsigned char, 32> expected_mac = {
        0x5b, 0xdc, 0xc1, 0x46, 0xbf, 0x60, 0x75, 0x4e,
        0x6a, 0x04, 0x24, 0x26, 0x08, 0x95, 0x75, 0xc7,
        0x5a, 0x00, 0x3f, 0x08, 0x9d, 0x27, 0x39, 0x83,
        0x9d, 0xec, 0x58, 0xb9, 0x64, 0xec, 0x38, 0x43,
    };

    psa_key_attributes_t attrs = PSA_KEY_ATTRIBUTES_INIT;
    psa_set_key_usage_flags(&attrs, PSA_KEY_USAGE_SIGN_MESSAGE);
    psa_set_key_algorithm(&attrs, PSA_ALG_HMAC(PSA_ALG_SHA_256));
    psa_set_key_type(&attrs, PSA_KEY_TYPE_HMAC);
    psa_set_key_bits(&attrs, sizeof(hmac_key) * 8);

    mbedtls_svc_key_id_t key_id = MBEDTLS_SVC_KEY_ID_INIT;
    if (psa_import_key(&attrs, hmac_key, sizeof(hmac_key), &key_id) != PSA_SUCCESS) {
        psa_reset_key_attributes(&attrs);
        return false;
    }
    psa_reset_key_attributes(&attrs);

    std::array<unsigned char, 32> mac{};
    std::size_t mac_len = 0;
    const psa_status_t mac_rc = psa_mac_compute(
        key_id, PSA_ALG_HMAC(PSA_ALG_SHA_256),
        hmac_msg, sizeof(hmac_msg) - 1,
        mac.data(), mac.size(), &mac_len);
    const psa_status_t destroy_rc = psa_destroy_key(key_id);
    if (mac_rc != PSA_SUCCESS || destroy_rc != PSA_SUCCESS) {
        return false;
    }
    return mac_len == expected_mac.size() && mac == expected_mac;
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
