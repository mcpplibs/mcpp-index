// compat.pcre2 — exercised the way glib's GRegex uses it.
//
// WHAT THIS ASSERTS AND WHY EACH ONE IS HERE
//
// The failures worth catching in a regex engine are not "it did not link".
// They are the ones where the library builds, links, runs, and gives a subtly
// wrong answer because a probe macro said something untrue. Each check below
// names a specific decision in the descriptor:
//
//   compile + match      the sources really were compiled, not just linked
//   \p{Han} / \X         SUPPORT_UNICODE, i.e. that pcre2_ucd.c's tables are in
//   PCRE2_UTF            that UTF-8 mode works, which is all glib ever uses
//   the character tables that pcre2_chartables.c.dist was compiled, and in the
//                        C locale — the file the descriptor does NOT let a
//                        `pcre2_dftables` run produce from the build machine
//   pcre2_config(JIT)    that JIT is OFF and SAYS so, rather than crashing
//   capture groups       pcre2_substring_*, which glib's g_match_info_fetch is

#ifdef __linux__

// ⚠️ REQUIRED BEFORE THE HEADER, and pcre2.h says so with an #error if it is
// missing. The header uses it to choose which of the three code-unit widths to
// declare, and this package builds the 8-bit one. glib does exactly this in
// gregex.c.
#define PCRE2_CODE_UNIT_WIDTH 8
#include <pcre2.h>

#include <cstdio>
#include <cstring>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-60s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

// Compile a pattern and report whether it matched, so each case below is one
// line. `subject` is UTF-8 throughout, which is the only encoding glib uses.
bool matches(const char *pattern, const char *subject, uint32_t options = 0)
{
    int err = 0;
    PCRE2_SIZE off = 0;
    pcre2_code *re = pcre2_compile(reinterpret_cast<PCRE2_SPTR>(pattern),
                                   PCRE2_ZERO_TERMINATED, options, &err, &off, nullptr);
    if (re == nullptr) {
        PCRE2_UCHAR buf[256];
        pcre2_get_error_message(err, buf, sizeof buf);
        std::printf("   compile failed at %zu: %s\n", off, reinterpret_cast<char *>(buf));
        return false;
    }
    pcre2_match_data *md = pcre2_match_data_create_from_pattern(re, nullptr);
    const int rc = pcre2_match(re, reinterpret_cast<PCRE2_SPTR>(subject),
                               std::strlen(subject), 0, 0, md, nullptr);
    pcre2_match_data_free(md);
    pcre2_code_free(re);
    return rc > 0;
}

} // namespace

int main()
{
    // ── 1. the version the descriptor names ──────────────────────────────
    char ver[64] = {};
    pcre2_config(PCRE2_CONFIG_VERSION, ver);
    std::printf("   pcre2 %s\n", ver);
    check(std::strncmp(ver, "10.44", 5) == 0,
          "pcre2_config reports 10.44, the version the descriptor names");

    // ── 2. it compiles and matches at all ────────────────────────────────
    check(matches("^a+b$", "aaab"), "compile and match a trivial pattern");
    check(!matches("^a+b$", "aaac"), "…and decline one that does not match");

    // ── 3. SUPPORT_UNICODE ───────────────────────────────────────────────
    // \p{...} is a compile-time ERROR without SUPPORT_UNICODE, not a silent
    // mismatch — which is the good case: it fails loudly. The descriptor
    // defines the macro (never as 0; pcre2 tests it with #ifdef).
    check(matches("\\p{Han}", "漢", PCRE2_UTF | PCRE2_UCP),
          "\\p{Han} matches a Han character — SUPPORT_UNICODE is on");
    check(!matches("\\p{Han}", "a", PCRE2_UTF | PCRE2_UCP),
          "…and does not match a Latin one");

    // \X is an extended grapheme cluster: "é" written as e + U+0301 is ONE
    // grapheme and two code points. This distinguishes real UCD tables from a
    // build that merely accepted the syntax.
    check(matches("^\\X$", "e\xCC\x81", PCRE2_UTF),
          "\\X treats e + combining acute as one grapheme cluster");

    // ── 4. UTF-8 mode ────────────────────────────────────────────────────
    // Without PCRE2_UTF, "." matches one BYTE; with it, one code point. A
    // three-byte character therefore distinguishes the two modes exactly.
    check(matches("^.$", "漢", PCRE2_UTF), "with PCRE2_UTF, `.` is one code point");
    check(!matches("^.$", "漢"), "…and without it, one byte — so a 3-byte char does not match");

    // ── 5. the character tables ──────────────────────────────────────────
    // `\w` and `[[:alpha:]]` consult pcre2_chartables.c, which upstream would
    // otherwise produce by RUNNING pcre2_dftables against the build machine's
    // locale. The descriptor compiles upstream's C-locale `.dist` instead, so
    // these answers cannot depend on where the package was built.
    //
    // The discriminating case is the second one: in a C locale, byte 0xE9
    // (é in Latin-1) is NOT alphabetic. In an fr_FR.ISO-8859-1 locale it is.
    check(matches("^\\w+$", "abc_123"), "\\w accepts letters, digits and underscore");
    check(!matches("^[[:alpha:]]$", "\xE9"),
          "…and byte 0xE9 is not alphabetic, i.e. the tables are C-locale");

    // ── 6. JIT is off, and says so ───────────────────────────────────────
    // The descriptor compiles pcre2_jit_compile.c without SUPPORT_JIT, so the
    // entry points exist as stubs. A consumer that checks — glib does — takes
    // the interpreter path. The failure this catches is the other one: a build
    // that claims JIT and then has no code behind it.
    uint32_t jit = 0;
    pcre2_config(PCRE2_CONFIG_JIT, &jit);
    std::printf("   pcre2_config(JIT) = %u\n", jit);
    check(jit == 0, "pcre2_config reports JIT off, matching the descriptor");

    int err = 0;
    PCRE2_SIZE off = 0;
    pcre2_code *re = pcre2_compile(reinterpret_cast<PCRE2_SPTR>("(\\w+)@(\\w+)"),
                                   PCRE2_ZERO_TERMINATED, 0, &err, &off, nullptr);
    check(re != nullptr, "compile a pattern with capture groups");
    if (re != nullptr) {
        // The JIT stub must FAIL CLEANLY rather than crash or pretend.
        const int jrc = pcre2_jit_compile(re, PCRE2_JIT_COMPLETE);
        std::printf("   pcre2_jit_compile = %d (PCRE2_ERROR_JIT_BADOPTION is %d)\n",
                    jrc, PCRE2_ERROR_JIT_BADOPTION);
        check(jrc != 0, "…and pcre2_jit_compile declines instead of crashing");

        // ── 7. capture groups, which is g_match_info_fetch ───────────────
        pcre2_match_data *md = pcre2_match_data_create_from_pattern(re, nullptr);
        const char *subject = "user@example";
        const int rc = pcre2_match(re, reinterpret_cast<PCRE2_SPTR>(subject),
                                   std::strlen(subject), 0, 0, md, nullptr);
        check(rc == 3, "match yields two capture groups plus the whole match");
        if (rc == 3) {
            PCRE2_SIZE len = 0;
            PCRE2_UCHAR buf[64] = {};
            len = sizeof buf;
            pcre2_substring_copy_bynumber(md, 1, buf, &len);
            std::printf("   group 1 = %s\n", reinterpret_cast<char *>(buf));
            check(std::strcmp(reinterpret_cast<char *>(buf), "user") == 0,
                  "…and group 1 is the text before the @");
        }
        pcre2_match_data_free(md);
        pcre2_code_free(re);
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
