import std;
import huxerui;
import huxerui.git;

namespace fs = std::filesystem;
namespace git = huxerui::git;

namespace {

void Require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

template <class T>
T RequireOk(git::GitResult<T> result, std::string_view op) {
    if (!result.Succeeded()) {
        throw std::runtime_error(std::string(op) + " failed: " + result.Error().message);
    }
    return std::move(result).Value();
}

void RequireReportOk(const git::WriteReport& report, std::string_view op) {
    if (report.issue) {
        throw std::runtime_error(std::string(op) + " failed: " + report.issue->message);
    }
}

struct AsyncState {
    std::mutex mutex;
    bool finished = false;
    std::string error;

    void Finish(std::string msg = {}) {
        std::lock_guard lock(mutex);
        finished = true;
        error = std::move(msg);
    }
};

AsyncState* g_state = nullptr;

huxerui::Task<void> RunChecks() {
    const fs::path temp_root = fs::temp_directory_path() / "mcpp_huxerui_git_smoke";
    std::error_code ec;
    fs::remove_all(temp_root, ec);
    fs::create_directories(temp_root, ec);
    try {
        git::GitService service;
        const git::Capabilities caps = service.GetCapabilities();
        Require(caps.local && caps.https, "expected local and https Git capabilities enabled");
        std::cout << "PASS positive: GitService::GetCapabilities() local+https verified\n";

        // Negative check: discovering a missing repository path fails cleanly.
        const auto missing = co_await service.DiscoverAsync(huxerui::File((temp_root / "missing").string()));
        Require(!missing.Succeeded() && !missing.Error().message.empty(),
                "expected DiscoverAsync on missing directory to fail");
        std::cout << "PASS negative: DiscoverAsync missing path rejected\n";

        // Positive check: init repository, set identity, stage, commit, and read commit details.
        const fs::path repo_dir = temp_root / "repo";
        fs::create_directories(repo_dir, ec);
        git::Repository repo = RequireOk(
            co_await service.InitAsync(huxerui::File(repo_dir.string())), "InitAsync");

        const auto set_id = co_await repo.SetIdentityAsync({"Test User", "test@example.com"});
        RequireReportOk(set_id.report, "SetIdentityAsync");

        const auto snap0 = RequireOk(co_await repo.InspectAsync(), "InspectAsync(unborn)");
        Require(snap0.head.kind == git::HeadKind::Unborn, "expected unborn HEAD in fresh repo");

        {
            std::ofstream out(repo_dir / "README.md", std::ios::binary);
            out << "hello huxerui.git\n";
            Require(out.good(), "failed to write README.md");
        }

        const auto status0 = RequireOk(co_await repo.StatusAsync(), "StatusAsync(untracked)");
        Require(std::ranges::any_of(status0.files, [](const git::FileStatus& f) {
                    return f.path == "README.md" && f.untracked;
                }),
                "expected untracked README.md in StatusAsync");

        const auto staged = co_await repo.StageFilesAsync({"README.md"});
        RequireReportOk(staged.report, "StageFilesAsync");
        Require(staged.index == git::WriteEffect::Changed, "expected index changed after StageFilesAsync");

        const auto status1 = RequireOk(co_await repo.StatusAsync(), "StatusAsync(staged)");
        Require(status1.commit.IsValid(), "expected valid CommitPrecondition");
        Require(std::ranges::any_of(status1.files, [](const git::FileStatus& f) {
                    return f.path == "README.md" && f.staged;
                }),
                "expected staged README.md in StatusAsync");

        const auto committed = co_await repo.CommitAsync({
            .expected = status1.commit,
            .message = "initial commit",
        });
        RequireReportOk(committed.report, "CommitAsync");
        Require(committed.created_commit.has_value() && committed.head == git::WriteEffect::Changed,
                "expected created commit and HEAD update");

        const auto details = RequireOk(
            co_await repo.ReadCommitAsync(*committed.created_commit), "ReadCommitAsync");
        Require(details.summary.subject == "initial commit", "commit subject mismatch");

        // Negative check: reusing stale CommitPrecondition after commit must fail cleanly.
        const auto stale = co_await repo.CommitAsync({
            .expected = status1.commit,
            .message = "stale commit",
            .allow_empty = true,
        });
        Require(stale.report.issue && stale.report.issue->code == git::ErrorCode::StaleSnapshot,
                "expected StaleSnapshot when committing with stale precondition");
        std::cout << "PASS positive+negative: Init/Stage/Commit/ReadCommit & StaleSnapshot verified\n";

        fs::remove_all(temp_root, ec);
        g_state->Finish();
    } catch (const std::exception& ex) {
        fs::remove_all(temp_root, ec);
        g_state->Finish(ex.what());
    } catch (...) {
        fs::remove_all(temp_root, ec);
        g_state->Finish("unknown exception in RunChecks");
    }
}

huxerui::View SmokeRoot() {
    const huxerui::TaskScope tasks = huxerui::UseTaskScope();
    huxerui::Lifecycle([tasks] {
        tasks.Launch([]() -> huxerui::Task<void> { co_await RunChecks(); });
    });
    return huxerui::Spacer();
}

class HeadlessPlatform final : public huxerui::UiWindow, public huxerui::Runtime {
public:
    HeadlessPlatform()
        : huxerui::Runtime([this](std::function<void()> cb) {
              {
                  std::lock_guard lock(mutex_);
                  callbacks_.push_back(std::move(cb));
              }
              cv_.notify_all();
          }) {}

    ~HeadlessPlatform() override {
        UiWindow::Retire();
        huxerui::Runtime::Retire();
    }

    void Start(const huxerui::Application& app) {
        InitializeApplication(app);
        InitializeWindow(*this, app.root_factory, app.options.window);
    }

    void OnRuntimeStopped() override {}

    void RequestFrameAt(double) override {
        {
            std::lock_guard lock(mutex_);
            frame_requested_ = true;
        }
        cv_.notify_all();
    }

    double Now() const noexcept override {
        return std::chrono::duration<double>(
                   std::chrono::steady_clock::now().time_since_epoch())
            .count();
    }

    huxerui::FontMetrics Metrics(const huxerui::Font&) override { return {}; }
    huxerui::TextRunMetrics MeasureRun(
        std::string_view, const huxerui::TextStyle&, const huxerui::TextShapingOptions&) override {
        return {};
    }
    huxerui::TextLayoutMetrics MeasureText(
        const huxerui::AttributedText&, const huxerui::TextStyle&, float,
        const huxerui::TextLayoutOptions&) override {
        return {};
    }

    bool RunNext(huxerui::UiWindow& window, std::chrono::steady_clock::time_point deadline) {
        std::function<void()> cb;
        bool build_frame = false;
        {
            std::unique_lock lock(mutex_);
            cv_.wait_until(lock, deadline, [this] {
                return !callbacks_.empty() || frame_requested_;
            });
            if (!callbacks_.empty()) {
                cb = std::move(callbacks_.front());
                callbacks_.pop_front();
            } else if (frame_requested_) {
                frame_requested_ = false;
                build_frame = true;
            } else {
                return false;
            }
        }
        if (cb) {
            cb();
        } else if (build_frame) {
            window.BuildFrame();
        }
        return true;
    }

private:
    std::mutex mutex_;
    std::condition_variable cv_;
    std::deque<std::function<void()>> callbacks_;
    bool frame_requested_ = false;
};

} // namespace

int main() {
    try {
        AsyncState state;
        g_state = &state;
        {
            const huxerui::Application app{
                SmokeRoot,
                {.application_hooks = {git::Install}},
            };
            HeadlessPlatform platform;
            platform.Start(app);
            huxerui::UiWindow& window = platform;
            window.SetWindowMetrics({.viewport = {320.0F, 240.0F}});
            window.BuildFrame();

            const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds{15};
            while (true) {
                {
                    std::lock_guard lock(state.mutex);
                    if (state.finished) {
                        break;
                    }
                }
                if (!platform.RunNext(window, deadline)) {
                    state.Finish("timed out waiting for git checks");
                    break;
                }
            }
        }
        std::lock_guard lock(state.mutex);
        Require(state.finished && state.error.empty(),
                state.error.empty() ? "git checks did not complete" : state.error);
        std::cout << "PASS: all git-consumer checks succeeded\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "FAIL: " << ex.what() << '\n';
        return 1;
    }
}
