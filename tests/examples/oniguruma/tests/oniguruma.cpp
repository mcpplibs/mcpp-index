#include <oniguruma.h>

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

  const char* ver = onig_version();
  std::cout << "oniguruma version: " << (ver ? ver : "(null)") << "\n";
  ok &= Expect(ver != nullptr && std::string_view(ver) == "6.9.10", "onig_version is 6.9.10");

  OnigEncoding encs[] = {ONIG_ENCODING_UTF8};
  if (!Expect(onig_initialize(encs, sizeof(encs) / sizeof(encs[0])) == ONIG_NORMAL, "onig_initialize")) {
    return 1;
  }

  // Negative check: malformed regex pattern fails cleanly.
  const std::string bad_pat = "[unclosed";
  regex_t* bad_reg = nullptr;
  OnigErrorInfo einfo{};
  const int bad_r = onig_new(&bad_reg,
                             reinterpret_cast<const OnigUChar*>(bad_pat.data()),
                             reinterpret_cast<const OnigUChar*>(bad_pat.data() + bad_pat.size()),
                             ONIG_OPTION_DEFAULT, ONIG_ENCODING_UTF8, ONIG_SYNTAX_DEFAULT, &einfo);
  ok &= Expect(bad_r != ONIG_NORMAL && bad_reg == nullptr, "negative: invalid pattern rejected");

  // Positive check: compile UTF-8 pattern and extract capture groups.
  const std::string pat = "(hello)-([[:alpha:]]+)";
  regex_t* reg = nullptr;
  const int rc = onig_new(&reg,
                          reinterpret_cast<const OnigUChar*>(pat.data()),
                          reinterpret_cast<const OnigUChar*>(pat.data() + pat.size()),
                          ONIG_OPTION_DEFAULT, ONIG_ENCODING_UTF8, ONIG_SYNTAX_DEFAULT, &einfo);
  ok &= Expect(rc == ONIG_NORMAL && reg != nullptr, "onig_new valid pattern");

  if (reg) {
    OnigRegion* region = onig_region_new();
    const std::string text = "__hello-world__";
    const auto* begin = reinterpret_cast<const OnigUChar*>(text.data());
    const auto* end = begin + text.size();
    const int pos = onig_search(reg, begin, end, begin, end, region, ONIG_OPTION_NONE);
    ok &= Expect(pos == 2, "match offset == 2");
    ok &= Expect(region->num_regs == 3, "3 capture regions");
    if (region->num_regs == 3) {
      const std::string cap1(text.substr(region->beg[1], region->end[1] - region->beg[1]));
      const std::string cap2(text.substr(region->beg[2], region->end[2] - region->beg[2]));
      ok &= Expect(cap1 == "hello" && cap2 == "world", "capture groups match");
    }

    // Negative check: non-matching string returns ONIG_MISMATCH.
    const std::string nomatch = "12345";
    const auto* nbegin = reinterpret_cast<const OnigUChar*>(nomatch.data());
    const int npos = onig_search(reg, nbegin, nbegin + nomatch.size(),
                                 nbegin, nbegin + nomatch.size(), region, ONIG_OPTION_NONE);
    ok &= Expect(npos == ONIG_MISMATCH, "negative: non-matching input returns ONIG_MISMATCH");

    onig_region_free(region, 1);
    onig_free(reg);
  }

  onig_end();
  return ok ? 0 : 1;
}
