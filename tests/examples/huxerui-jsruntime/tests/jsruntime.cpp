// Headless C++23 module consumer test for huxerui.jsruntime.
// Verifies package resolution, embedded QuickJS + TSX runtime.js execution,
// host callbacks, interrupt handling, and diagnostic capture across modules.
import std;
import huxerui.jsruntime;
import huxerui.jsruntime.quickjs;

namespace {

bool Expect(bool condition, std::string_view message) {
  if (!condition) {
    std::println("FAIL: {}", message);
    return false;
  }
  return true;
}

bool TestQuickJs() {
  namespace qjs = huxerui::quickjs;

  {
    qjs::Runtime rt;
    qjs::Context ctx(rt);

    auto reg = ctx.SetGlobalFunction(
        "addHost",
        [](qjs::Context& c, std::span<const qjs::Value> args) -> qjs::Value {
          if (args.size() < 2) {
            return c.Number(0.0);
          }
          auto a = args[0].ToNumber();
          auto b = args[1].ToNumber();
          if (!a.Succeeded() || !b.Succeeded()) {
            return c.Number(0.0);
          }
          return c.Number(a.Value() + b.Value());
        },
        2
    );
    if (!Expect(reg.Succeeded(), "SetGlobalFunction(addHost) succeeded")) {
      return false;
    }

    {
      auto eval_ok = ctx.Evaluate("addHost(19, 23)", "pos_eval.js");
      if (!Expect(eval_ok.Succeeded(), "QuickJS positive evaluation succeeded")) {
        return false;
      }
      auto val_i32 = eval_ok.Value().ToInt32();
      if (!Expect(val_i32.Succeeded() && val_i32.Value() == 42, "addHost(19, 23) == 42")) {
        return false;
      }

      auto json = ctx.ParseJson(R"({"name":"huxerui","ver":5})", "pos.json");
      if (!Expect(json.Succeeded(), "ParseJson succeeded")) {
        return false;
      }
      auto ver = json.Value().GetProperty("ver");
      if (!Expect(ver.Succeeded(), "GetProperty(ver) succeeded")) {
        return false;
      }
      auto ver_i32 = ver.Value().ToInt32();
      if (!Expect(ver_i32.Succeeded() && ver_i32.Value() == 5, "json.ver == 5")) {
        return false;
      }
    }

    {
      auto syntax_err = ctx.Evaluate("function (", "neg_syntax.js");
      if (!Expect(!syntax_err.Succeeded(), "QuickJS syntax error rejected")) {
        return false;
      }
      if (!Expect(syntax_err.Error().Code() == qjs::ErrorCode::Syntax,
                  "QuickJS syntax failure has ErrorCode::Syntax")) {
        return false;
      }

      auto ref_err = ctx.Evaluate("missingGlobalSymbol + 1", "neg_ref.js");
      if (!Expect(!ref_err.Succeeded(), "QuickJS ReferenceError rejected")) {
        return false;
      }
      if (!Expect(ref_err.Error().Code() == qjs::ErrorCode::Exception,
                  "QuickJS ReferenceError has ErrorCode::Exception")) {
        return false;
      }
    }
  }

  {
    qjs::RuntimeOptions interrupt_opts;
    interrupt_opts.should_interrupt = [] { return true; };
    qjs::Runtime interrupt_rt(interrupt_opts);
    qjs::Context interrupt_ctx(interrupt_rt);
    auto interrupted = interrupt_ctx.Evaluate("1 + 1", "neg_interrupt.js");
    if (!Expect(!interrupted.Succeeded(), "QuickJS interrupted execution rejected")) {
      return false;
    }
    if (!Expect(interrupted.Error().Code() == qjs::ErrorCode::Interrupted,
                "QuickJS interrupted failure has ErrorCode::Interrupted")) {
      return false;
    }
  }

  std::println("QuickJS checks passed");
  return true;
}

bool TestTsxRuntime() {
  namespace tsx = huxerui::tsx;
  namespace qjs = huxerui::quickjs;

  bool saw_boot_log = false;
  std::optional<tsx::Diagnostic> latest_diag;

  tsx::RuntimeOptions opts;
  opts.on_log = [&saw_boot_log](tsx::LogLevel level, std::string_view msg) {
    if (level == tsx::LogLevel::Info && msg == "tsx-boot-ok") {
      saw_boot_log = true;
    }
  };
  opts.on_diagnostic = [&latest_diag](const tsx::Diagnostic& diag) {
    latest_diag = diag;
  };

  tsx::Runtime rt(std::move(opts));
  constexpr std::string_view kValidBundle = R"(
    import { mount, h, Column, Text } from "@huxerui/tsx";
    globalThis.__answer = 6 * 7;
    console.info("tsx-boot-ok");
    mount(() => h(Column, null, h(Text, null, "hello-huxerui-0.5.5")));
  )";

  auto load_ok = rt.Load(kValidBundle, "app-v1.js");
  if (!Expect(load_ok.Succeeded(), "TSX valid @huxerui/tsx bundle Load() succeeded")) {
    return false;
  }
  if (!Expect(!rt.LastDiagnostic().has_value() && !latest_diag.has_value(),
              "TSX valid Load() produced no diagnostics")) {
    return false;
  }
  if (!Expect(saw_boot_log, "TSX console.info forwarded through embedded runtime.js")) {
    return false;
  }

  {
    auto ans = rt.Evaluate("globalThis.__answer", "check.js");
    if (!Expect(ans.Succeeded(), "TSX Evaluate() succeeded")) {
      return false;
    }
    auto ans_i32 = ans.Value().ToInt32();
    if (!Expect(ans_i32.Succeeded() && ans_i32.Value() == 42, "globalThis.__answer == 42")) {
      return false;
    }
  }

  auto root_view = rt.Root();
  (void)root_view;

  constexpr std::string_view kReloadBundle = R"(
    import { mount, h, Column, Text } from "@huxerui/tsx";
    globalThis.__reloaded = 99;
    mount(() => h(Column, null, h(Text, null, "reloaded")));
  )";
  auto reload_ok = rt.Reload(kReloadBundle, "app-v2.js");
  if (!Expect(reload_ok.Succeeded(), "TSX Reload() succeeded")) {
    return false;
  }
  {
    auto rel = rt.Evaluate("globalThis.__reloaded", "check_reload.js");
    if (!Expect(rel.Succeeded(), "TSX post-Reload Evaluate() succeeded")) {
      return false;
    }
    auto rel_i32 = rel.Value().ToInt32();
    if (!Expect(rel_i32.Succeeded() && rel_i32.Value() == 99, "globalThis.__reloaded == 99")) {
      return false;
    }
  }

  tsx::Runtime bad_rt;
  auto bad_load = bad_rt.Load("throw new Error('intentional-load-failure');", "bad.js");
  if (!Expect(!bad_load.Succeeded(), "TSX negative throwing bundle rejected")) {
    return false;
  }
  if (!Expect(bad_load.Error().Code() == qjs::ErrorCode::Exception,
              "TSX throwing bundle returns ErrorCode::Exception")) {
    return false;
  }
  auto diag1 = bad_rt.LastDiagnostic();
  if (!Expect(diag1.has_value() && diag1->phase == tsx::DiagnosticPhase::Load,
              "TSX LastDiagnostic records DiagnosticPhase::Load")) {
    return false;
  }

  auto bad_eval = bad_rt.Evaluate("invalid((syntax", "bad_eval.js");
  if (!Expect(!bad_eval.Succeeded(), "TSX negative Evaluate() syntax error rejected")) {
    return false;
  }
  auto diag2 = bad_rt.LastDiagnostic();
  if (!Expect(diag2.has_value() && diag2->phase == tsx::DiagnosticPhase::Evaluation,
              "TSX LastDiagnostic records DiagnosticPhase::Evaluation")) {
    return false;
  }

  std::println("TSX runtime checks passed");
  return true;
}

} // namespace

int main() {
  if (!TestQuickJs()) {
    return 1;
  }
  if (!TestTsxRuntime()) {
    return 1;
  }
  return 0;
}
