import std;
import mcpplibs.mwrap.quickjs_ng;

using namespace mcpplibs::mwrap::quickjs_ng;
using namespace mcpplibs::mwrap::quickjs_ng::macros;

namespace {
JSValue add(JSContext* ctx, JSValueConst, int argc, JSValueConst* argv) {
    std::int64_t a = 0, b = 0;
    if (argc < 2 || JS_ToInt64(ctx, &a, argv[0]) || JS_ToInt64(ctx, &b, argv[1])) return JS_ThrowTypeError(ctx, "add(a, b)");
    return JS_NewInt64(ctx, a + b);
}
constexpr JSCFunctionListEntry table[] = {
    JS_CFUNC_DEF("add", 2, add),
    JS_PROP_STRING_DEF("name", "maths", JS_PROP_CONFIGURABLE),
};
std::string text(JSContext* ctx, JSValueConst v) {
    const char* s = JS_ToCString(ctx, v);
    std::string out = s ? s : "";
    JS_FreeCString(ctx, s);
    return out;
}
}  // namespace

int main() {
    JSRuntime* rt = JS_NewRuntime();
    JSContext* ctx = JS_NewContext(rt);
    JSValue global = JS_GetGlobalObject(ctx);
    JSValue maths = JS_NewObject(ctx);
    if (JS_SetPropertyFunctionList(ctx, maths, table, 2) != 0) return 1;
    JS_SetPropertyStr(ctx, global, "maths", maths);
    JS_FreeValue(ctx, global);
    // A script calling the table's C function.
    constexpr std::string_view code = "`${maths.name}: ${maths.add(40, 2)}`";
    JSValue v = JS_Eval(ctx, code.data(), code.size(), "<code>", JS_EVAL_TYPE_GLOBAL);
    if (JS_IsException(v) || text(ctx, v) != "maths: 42") return 2;
    JS_FreeValue(ctx, v);
    // An exception, with its message.
    constexpr std::string_view bad = "maths.add('x')";
    v = JS_Eval(ctx, bad.data(), bad.size(), "<bad>", JS_EVAL_TYPE_GLOBAL);
    if (!JS_IsException(v)) return 3;
    JSValue e = JS_GetException(ctx);
    if (text(ctx, e) != "TypeError: add(a, b)") return 4;
    JS_FreeValue(ctx, e);
    // A promise, settled by running the jobs.
    constexpr std::string_view promise = "Promise.resolve(20).then(x => x * 2 + 2)";
    v = JS_Eval(ctx, promise.data(), promise.size(), "<promise>", JS_EVAL_TYPE_GLOBAL);
    for (JSContext* job = nullptr; JS_IsJobPending(rt);) JS_ExecutePendingJob(rt, &job);
    if (JS_PromiseState(ctx, v) != JS_PROMISE_FULFILLED) return 5;
    JSValue r = JS_PromiseResult(ctx, v);
    if (text(ctx, r) != "42") return 6;
    JS_FreeValue(ctx, r);
    JS_FreeValue(ctx, v);
    std::println("quickjs-embed: ok (QuickJS-ng {})", JS_GetVersion());
    JS_FreeContext(ctx);
    JS_FreeRuntime(rt);
    return JS_VALUE_GET_TAG(JS_UNDEFINED) == JS_TAG_UNDEFINED ? 0 : 7;
}
