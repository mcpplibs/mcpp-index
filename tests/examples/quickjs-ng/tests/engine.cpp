// Behavioral test: JavaScript evaluated by the engine, checked by value.
//
// The package compiles four sources, and each group below needs one of them to
// be present and built with the right flags, so a missing or mis-built TU shows
// up as a wrong answer rather than only as a link error:
//
//   quickjs.c     evaluation, closures, exceptions, the promise job queue
//   dtoa.c        shortest round-trip number formatting (0.1 + 0.2, 5e-324)
//   libregexp.c   named groups, case-insensitive and sticky matching
//   libunicode.c  full case mapping, NFC normalization, script properties
//
// The expected strings are what the ECMAScript specification requires, written
// out by hand; none is computed by the code under test.
//
// The runtime is freed at the end. The package does not define NDEBUG, so
// JS_FreeRuntime asserts that no object is still alive (quickjs.c:2699) and an
// object this test forgot to free aborts it.

#ifdef __linux__

#include <quickjs.h>

#include <cstdio>
#include <cstring>
#include <string>

// The descriptor exposes quickjs.h alone. The engine's private headers sit next
// to it in the tarball and must not reach a consumer.
#if __has_include(<cutils.h>) || __has_include(<libregexp.h>)
#error "compat.quickjs-ng put the engine's private headers on the include path"
#endif

namespace {

int failures = 0;

std::string to_std_string(JSContext* ctx, JSValueConst v) {
    const char* s = JS_ToCString(ctx, v);
    std::string out = s ? s : "<ToCString failed>";
    JS_FreeCString(ctx, s);
    return out;
}

// Global code; the completion value of the last statement is the result.
std::string run_js(JSContext* ctx, const char* src) {
    JSValue v = JS_Eval(ctx, src, std::strlen(src), "<test>", JS_EVAL_TYPE_GLOBAL);
    std::string out;
    if (JS_IsException(v)) {
        JSValue exc = JS_GetException(ctx);
        out = "exception " + to_std_string(ctx, exc);
        JS_FreeValue(ctx, exc);
    } else {
        out = to_std_string(ctx, v);
    }
    JS_FreeValue(ctx, v);
    return out;
}

void expect(JSContext* ctx, const char* src, const char* want) {
    std::string got = run_js(ctx, src);
    if (got != want) {
        std::fprintf(stderr, "FAIL %s\n  want: %s\n  got:  %s\n", src, want, got.c_str());
        ++failures;
    }
}

}  // namespace

int main() {
    // The library and the header it was built from agree on the version.
    char header_version[32];
    std::snprintf(header_version, sizeof header_version, "%d.%d.%d%s",
                  QJS_VERSION_MAJOR, QJS_VERSION_MINOR, QJS_VERSION_PATCH, QJS_VERSION_SUFFIX);
    std::printf("QuickJS-ng %s\n", JS_GetVersion());
    if (std::strcmp(JS_GetVersion(), "0.17.0") != 0 ||
        std::strcmp(JS_GetVersion(), header_version) != 0) {
        std::fprintf(stderr, "FAIL version: library %s, header %s\n", JS_GetVersion(), header_version);
        ++failures;
    }

    JSRuntime* rt = JS_NewRuntime();
    JSContext* ctx = rt ? JS_NewContext(rt) : nullptr;
    if (ctx == nullptr) {
        std::fprintf(stderr, "FAIL could not create a runtime and context\n");
        return 1;
    }

    // quickjs.c
    expect(ctx, "const sq = [1, 2, 3].map(x => x * x); sq.reduce((a, b) => a + b, 0)", "14");
    expect(ctx, "(() => { let n = 0; const inc = () => ++n; inc(); inc(); return inc(); })()", "3");
    expect(ctx, "JSON.stringify({ a: [1, { b: null }], c: 'x' })", "{\"a\":[1,{\"b\":null}],\"c\":\"x\"}");
    expect(ctx, "throw new TypeError('boom')", "exception TypeError: boom");

    // dtoa.c
    expect(ctx, "String(0.1 + 0.2)", "0.30000000000000004");
    expect(ctx, "String(5e-324)", "5e-324");
    expect(ctx, "String(1e21)", "1e+21");
    expect(ctx, "(1.005).toFixed(2)", "1.00");
    expect(ctx, "(255).toString(16) + ' ' + parseFloat('2.5e-3') * 4", "ff 0.01");

    // libregexp.c
    expect(ctx, "const m = /(?<y>\\d{4})-(?<m>\\d{2})/.exec('on 2026-09'); m.groups.y + '/' + m.groups.m",
           "2026/09");
    expect(ctx, "'aXbxc'.split(/x/i).join(',')", "a,b,c");
    expect(ctx, "const re = /o/y; re.lastIndex = 1; re.test('foo') + ' ' + re.lastIndex", "true 2");

    // libunicode.c
    expect(ctx, "'straße'.toUpperCase()", "STRASSE");
    expect(ctx, "'\\u0041\\u030A'.normalize('NFC') === '\\u00C5'", "true");
    expect(ctx, "/^\\p{Script=Greek}+$/u.test('αβγ') + ' ' + /\\p{Script=Greek}/u.test('abc')", "true false");

    // quickjs.c, the job queue: a reaction runs only when the host drains it.
    expect(ctx, "var out = 'pending'; Promise.resolve(20).then(v => { out = 'resolved ' + (v + 1); }); out",
           "pending");
    JSContext* job_ctx = nullptr;
    int r;
    while ((r = JS_ExecutePendingJob(rt, &job_ctx)) > 0) {
    }
    if (r != 0) {
        std::fprintf(stderr, "FAIL a pending job threw\n");
        ++failures;
    }
    expect(ctx, "out", "resolved 21");

    JS_FreeContext(ctx);
    JS_FreeRuntime(rt);

    if (failures != 0) {
        std::fprintf(stderr, "%d check(s) failed\n", failures);
        return 1;
    }
    return 0;
}

#else

int main() { return 0; }   // compat.quickjs-ng declares linux only; nothing to assert here.

#endif
