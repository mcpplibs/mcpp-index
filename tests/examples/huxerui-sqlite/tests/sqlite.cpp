import std;
import huxerui.sqlite;

namespace sqlite = huxerui::sqlite;

namespace {

struct Record {
    std::int64_t id = 0;
    std::string  name;
    double       score = 0.0;
    bool         active = true;
};

const sqlite::Table<Record> records{
    "records",
    sqlite::Column<&Record::id>{"id", sqlite::PrimaryKey{}, sqlite::AutoIncrement{}},
    sqlite::Column<&Record::name>{"name", sqlite::Unique{}},
    sqlite::Column<&Record::score>{"score"},
    sqlite::Column<&Record::active>{"active", sqlite::Default{true}},
};

const sqlite::Schema schema{1, records};

struct TestState {
    std::mutex  mutex;
    bool        finished = false;
    std::string error;

    void Finish(std::string message = {}) {
        std::lock_guard lock(mutex);
        finished = true;
        error = std::move(message);
    }
};

TestState* g_state = nullptr;
std::string g_db_path;

void Check(bool cond, std::string_view message) {
    if (!cond) {
        throw std::runtime_error(std::string{message});
    }
}

template <class T>
T Require(sqlite::Result<T> result, std::string_view op) {
    if (!result) {
        throw std::runtime_error(std::string{op} + ": " + result.Error().Message());
    }
    return std::move(*result);
}

void Require(sqlite::Result<void> result, std::string_view op) {
    if (!result) {
        throw std::runtime_error(std::string{op} + ": " + result.Error().Message());
    }
}

huxerui::Task<void> RunSmokeTest() {
    try {
        sqlite::Database db = Require(
            co_await sqlite::Database::OpenAsync(huxerui::File{g_db_path}, schema),
            "open database"
        );

        const sqlite::InsertResult inserted_ada = Require(
            co_await db.InsertAsync(records, Record{.name = "Ada", .score = 98.5, .active = true}),
            "insert Ada"
        );
        Check(inserted_ada.generated_primary_key.has_value(), "expected generated primary key for Ada");
        const std::int64_t ada_id = *inserted_ada.generated_primary_key;

        Require(
            co_await db.InsertManyAsync(
                records,
                std::vector<Record>{
                    Record{.name = "Grace", .score = 99.5, .active = true},
                    Record{.name = "Linus", .score = 87.0, .active = false},
                }
            ),
            "insert batch"
        );

        const std::optional<Record> found_ada = Require(
            co_await db.FindAsync(records, ada_id),
            "find Ada"
        );
        Check(found_ada.has_value(), "Ada must exist");
        Check(found_ada->name == "Ada", "Ada name mismatch");
        Check(found_ada->score == 98.5, "Ada score mismatch");
        Check(found_ada->active, "Ada active mismatch");

        const std::vector<Record> active_records = Require(
            co_await db.Select(records)
                .Where(records.Column<&Record::active>() == true)
                .OrderBy(records.Column<&Record::score>(), sqlite::SortDirection::Descending)
                .AllAsync(),
            "select active records"
        );
        Check(active_records.size() == 2, "expected 2 active records");
        Check(active_records[0].name == "Grace", "expected Grace first by descending score");
        Check(active_records[1].name == "Ada", "expected Ada second by descending score");

        Require(
            co_await db.UpdateFieldsAsync(
                records, ada_id, sqlite::Set(records.Column<&Record::score>(), 100.0)
            ),
            "update Ada score"
        );

        const std::vector<std::string> top_names = Require(
            co_await db.QueryAsync<std::string>(
                "SELECT name FROM records WHERE score >= ? ORDER BY score DESC",
                [](const sqlite::RowView& row) -> sqlite::Result<std::string> {
                    return row.Get<std::string>(0);
                },
                100.0
            ),
            "raw query"
        );
        Check(top_names.size() == 1 && top_names[0] == "Ada", "expected Ada as sole >=100.0 record");

        Require(co_await db.CloseAsync(), "close database");

        const auto after_close = co_await db.Select(records).CountAsync();
        Check(!after_close && after_close.Error().Code() == sqlite::ErrorCode::Closed,
              "expected ErrorCode::Closed after CloseAsync");

        g_state->Finish();
    } catch (const std::exception& ex) {
        g_state->Finish(ex.what());
    } catch (...) {
        g_state->Finish("unknown exception in module smoke test");
    }
}

huxerui::View SmokeApplication() {
    const huxerui::TaskScope tasks = huxerui::UseTaskScope();
    huxerui::Lifecycle([tasks] {
        tasks.Launch([]() -> huxerui::Task<void> { co_await RunSmokeTest(); });
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
    const auto stamp = std::chrono::steady_clock::now().time_since_epoch().count();
    const auto rand_val = std::random_device{}();
    g_db_path = (
        std::filesystem::temp_directory_path() /
        ("huxerui-sqlite-module-smoke-" + std::to_string(stamp) + "-" +
         std::to_string(rand_val) + ".sqlite3")
    ).string();

    TestState state;
    g_state = &state;

    {
        const huxerui::Application app{SmokeApplication};
        HeadlessPlatform platform;
        platform.Start(app);
        huxerui::UiWindow& window = platform;
        window.SetWindowMetrics({.viewport = {320.0F, 240.0F}});
        window.BuildFrame();

        const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds{10};
        while (true) {
            {
                std::lock_guard lock(state.mutex);
                if (state.finished) {
                    break;
                }
            }
            if (!platform.RunNext(window, deadline)) {
                state.Finish("timed out waiting for module smoke test");
                break;
            }
        }
    }

    std::error_code ec;
    for (const std::string_view suffix : {"", "-wal", "-shm", "-journal"}) {
        std::filesystem::remove(g_db_path + std::string{suffix}, ec);
        ec.clear();
    }

    bool ok = false;
    {
        std::lock_guard lock(state.mutex);
        ok = state.finished && state.error.empty();
        if (!ok) {
            std::cerr << "FAIL: " << (state.error.empty() ? "incomplete" : state.error) << "\n";
        }
    }
    return ok ? 0 : 1;
}
