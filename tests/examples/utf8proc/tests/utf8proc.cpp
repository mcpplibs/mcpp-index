#include <utf8proc.h>

#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <string_view>

namespace {

bool Expect(bool ok, const char* msg) {
  if (!ok) {
    std::cerr << "FAIL: " << msg << "\n";
  }
  return ok;
}

} // namespace

int main() {
  bool ok = true;

  const char* ver = utf8proc_version();
  ok &= Expect(ver != nullptr && std::string_view(ver).starts_with("2.10."), "version starts with 2.10.");
  std::cout << "utf8proc_version: " << (ver ? ver : "(null)") << "\n";

  // Decode + width + round-trip encode for ASCII and CJK codepoints.
  const std::string cjk = "\xE4\xB8\xAD"; // U+4E2D
  utf8proc_int32_t cp = 0;
  const auto n = utf8proc_iterate(reinterpret_cast<const utf8proc_uint8_t*>(cjk.data()),
                                  static_cast<utf8proc_ssize_t>(cjk.size()), &cp);
  ok &= Expect(n == 3 && cp == 0x4E2D, "utf8proc_iterate decodes U+4E2D");
  ok &= Expect(utf8proc_charwidth(cp) == 2, "utf8proc_charwidth(U+4E2D) == 2");
  ok &= Expect(utf8proc_charwidth('A') == 1, "utf8proc_charwidth('A') == 1");

  utf8proc_uint8_t encoded[4] = {};
  ok &= Expect(utf8proc_encode_char(0x1F600, encoded) == 4, "utf8proc_encode_char(U+1F600) == 4 bytes");

  // NFC normalization combines "e" + U+0301 into U+00E9 ("é").
  utf8proc_uint8_t* nfc = utf8proc_NFC(reinterpret_cast<const utf8proc_uint8_t*>("e\xCC\x81"));
  ok &= Expect(nfc != nullptr && std::strcmp(reinterpret_cast<const char*>(nfc), "\xC3\xA9") == 0,
               "utf8proc_NFC composes e + combining acute");
  std::free(nfc);

  // Stateful grapheme cluster check: base + combining mark stays in the same cluster.
  utf8proc_int32_t state = 0;
  ok &= Expect(!utf8proc_grapheme_break_stateful('e', 0x0301, &state),
               "combining mark stays inside grapheme cluster");

  // Negative check: invalid UTF-8 lead byte must report error (< 0).
  const utf8proc_uint8_t bad[1] = {0xFF};
  utf8proc_int32_t bad_cp = 0;
  ok &= Expect(utf8proc_iterate(bad, 1, &bad_cp) == UTF8PROC_ERROR_INVALIDUTF8 && bad_cp == -1,
               "negative: invalid UTF-8 returns UTF8PROC_ERROR_INVALIDUTF8");

  return ok ? 0 : 1;
}
