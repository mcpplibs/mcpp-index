import std;
import huxerui;
import huxerui.lottie;

namespace motion = huxerui::lottie;

namespace {

constexpr std::string_view kMotionJson =
    R"({"v":"5.7.4","fr":60,"ip":0,"op":60,"w":100,"h":100,"nm":"Moving circle","ddd":0,"assets":[],"layers":[{"ddd":0,"ind":1,"ty":4,"nm":"Circle","sr":1,"ks":{"o":{"a":0,"k":100},"r":{"a":0,"k":0},"p":{"a":1,"k":[{"t":0,"s":[20,50,0],"e":[80,50,0],"o":{"x":0.333,"y":0.333},"i":{"x":0.667,"y":0.667}},{"t":60,"s":[80,50,0]}]},"a":{"a":0,"k":[0,0,0]},"s":{"a":0,"k":[100,100,100]}},"shapes":[{"ty":"el","p":{"a":0,"k":[0,0]},"s":{"a":0,"k":[20,20]},"d":1,"nm":"Ellipse"},{"ty":"fl","c":{"a":0,"k":[1,0,0,1]},"o":{"a":0,"k":100},"r":1,"nm":"Red"}],"ip":0,"op":60,"st":0,"bm":0}]})";

std::function<huxerui::View()> g_root;
huxerui::View RootView() { return g_root(); }

void Require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string{message});
    }
}

template <class Ex, class Fn>
void RequireThrows(Fn&& fn, std::string_view message) {
    bool caught = false;
    try {
        fn();
    } catch (const Ex&) {
        caught = true;
    }
    Require(caught, message);
}

huxerui::RawAsset MakeJsonAsset(std::string_view text) {
    return huxerui::RawAsset::CopyBytes(
        std::as_bytes(std::span(text.data(), text.size())), "application/json");
}

std::vector<std::shared_ptr<huxerui::ExternalTexture>> CollectTextures(const huxerui::RenderNode* root) {
    std::vector<std::shared_ptr<huxerui::ExternalTexture>> textures;
    auto visit = [&](auto&& self, const huxerui::RenderNode* node) -> void {
        if (!node) return;
        for (const auto* sequence : {&node->content, &node->foreground}) {
            for (const auto& command : sequence->Commands()) {
                if (const auto* image = std::get_if<huxerui::DrawExternalTextureCommand>(&command)) {
                    textures.push_back(image->texture);
                }
            }
        }
        for (const auto* child : node->children) {
            self(self, child);
        }
    };
    visit(visit, root);
    return textures;
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
        UpdateWindowLifecycleState(huxerui::WindowLifecycleState::Active);
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
        return now_seconds_;
    }

    void AdvanceClock(double delta_seconds) {
        now_seconds_ += delta_seconds;
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

    bool Step(std::chrono::milliseconds timeout) {
        std::function<void()> cb;
        bool build_frame = false;
        {
            std::unique_lock lock(mutex_);
            if (callbacks_.empty() && !frame_requested_) {
                cv_.wait_for(lock, timeout, [this] {
                    return !callbacks_.empty() || frame_requested_;
                });
            }
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
            (void)BuildFrame();
        }
        return true;
    }

    void Pump(std::chrono::milliseconds timeout = std::chrono::milliseconds{20}) {
        while (Step(std::chrono::milliseconds{0})) {}
        if (Step(timeout)) {
            while (Step(std::chrono::milliseconds{0})) {}
        }
    }

private:
    std::mutex mutex_;
    std::condition_variable cv_;
    std::deque<std::function<void()>> callbacks_;
    bool frame_requested_ = false;
    double now_seconds_ = 0.0;
};

} // namespace

int main() {
    try {
        // 1. Public types, defaults, equality, and variant controls from import huxerui.lottie.
        const motion::LottiePlayback default_play{};
        Require(default_play.playing && default_play.iterations == 1 &&
                    default_play.speed == 1.0 && default_play.restart == 0,
                "LottiePlayback default fields mismatch");
        Require(default_play == motion::LottiePlayback{}, "LottiePlayback equality failed");
        Require(motion::LottieProgress{0.25} == motion::LottieProgress{0.25},
                "LottieProgress equality failed");

        const huxerui::RawAsset valid_asset = MakeJsonAsset(kMotionJson);
        const motion::LottieSource src_asset = valid_asset;
        const motion::LottieSource src_res = huxerui::RawResource("app", "raw/motion.json");
        const motion::LottieSource src_file = huxerui::File("missing.json");
        Require(std::holds_alternative<huxerui::RawAsset>(src_asset), "LottieSource RawAsset");
        Require(std::holds_alternative<huxerui::RawResource>(src_res), "LottieSource RawResource");
        Require(std::holds_alternative<huxerui::File>(src_file), "LottieSource File");
        const motion::LottieControl ctrl_play = default_play;
        const motion::LottieControl ctrl_prog = motion::LottieProgress{0.5};
        Require(std::holds_alternative<motion::LottiePlayback>(ctrl_play), "LottieControl playback");
        Require(std::holds_alternative<motion::LottieProgress>(ctrl_prog), "LottieControl progress");

        // Negative 1: Composing Lottie() without motion::Install in application_hooks throws std::logic_error.
        {
            g_root = [&]() -> huxerui::View {
                return motion::Lottie(valid_asset);
            };
            const huxerui::Application missing_install_app(RootView);
            HeadlessPlatform platform;
            platform.Start(missing_install_app);
            platform.SetWindowMetrics({.viewport = {240.0F, 240.0F}});
            RequireThrows<std::logic_error>(
                [&] { (void)platform.BuildFrame(); },
                "Composing Lottie() without Install must throw std::logic_error");
        }
        std::cout << "PASS negative: missing Install throws std::logic_error on BuildFrame\n";

        // Negative 2: Invalid playback speed and non-finite progress throw std::invalid_argument on BuildFrame.
        for (const double bad_speed :
             {0.0, -1.0, 1001.0, std::numeric_limits<double>::infinity()}) {
            g_root = [&]() -> huxerui::View {
                return motion::Lottie(valid_asset, motion::LottiePlayback{.speed = bad_speed});
            };
            const huxerui::Application bad_app(RootView, {.application_hooks = {motion::Install}});
            HeadlessPlatform platform;
            platform.Start(bad_app);
            platform.SetWindowMetrics({.viewport = {240.0F, 240.0F}});
            RequireThrows<std::invalid_argument>(
                [&] { (void)platform.BuildFrame(); },
                "invalid playback speed must throw std::invalid_argument");
        }
        for (const double bad_progress :
             {std::numeric_limits<double>::quiet_NaN(),
              std::numeric_limits<double>::infinity()}) {
            g_root = [&]() -> huxerui::View {
                return motion::Lottie(valid_asset, motion::LottieProgress{bad_progress});
            };
            const huxerui::Application bad_app(RootView, {.application_hooks = {motion::Install}});
            HeadlessPlatform platform;
            platform.Start(bad_app);
            platform.SetWindowMetrics({.viewport = {240.0F, 240.0F}});
            RequireThrows<std::invalid_argument>(
                [&] { (void)platform.BuildFrame(); },
                "non-finite progress must throw std::invalid_argument");
        }
        std::cout << "PASS negative: invalid speed & non-finite progress throw std::invalid_argument\n";

        // 2. Full ThorVG-backed async load, render, completion, and decode/resource errors.
        huxerui::State<motion::LottieSource> source;
        huxerui::State<motion::LottieControl> control;
        int loaded_count = 0;
        int completed_count = 0;
        motion::LottieMetadata last_metadata{};
        std::vector<motion::LottieError> errors;

        g_root = [&]() -> huxerui::View {
            return motion::Lottie(source, control)
                .On<motion::LottieEvents::Loaded>([&](const motion::LottieMetadata& info) {
                    last_metadata = info;
                    ++loaded_count;
                })
                .On<motion::LottieEvents::Completed>([&] { ++completed_count; })
                .On<motion::LottieEvents::Failed>([&](const motion::LottieError& err) {
                    errors.push_back(err);
                })
                .With(huxerui::Frame{.width = 160.0F, .height = 160.0F});
        };

        const huxerui::Application app(
            RootView,
            {.application_hooks = {
                 motion::Install,
                 [&](huxerui::ApplicationContext& ctx) {
                     RequireThrows<std::logic_error>(
                         [&] { motion::Install(ctx); },
                         "duplicate motion::Install must throw std::logic_error");
                     source = huxerui::State<motion::LottieSource>(valid_asset);
                     control = huxerui::State<motion::LottieControl>(
                         motion::LottiePlayback{.playing = true, .iterations = 1, .speed = 2.0});
                 }}});

        HeadlessPlatform platform;
        platform.Start(app);
        platform.SetWindowMetrics({.viewport = {240.0F, 240.0F}});
        (void)platform.BuildFrame();

        const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds{10};
        while (loaded_count < 1 && errors.empty() && std::chrono::steady_clock::now() < deadline) {
            platform.Pump();
        }
        Require(errors.empty(), errors.empty() ? "" : ("unexpected load error: " + errors.front().message));
        Require(loaded_count == 1, "expected LottieEvents::Loaded");
        Require(last_metadata.frames == 60 && last_metadata.duration == 1.0 &&
                    last_metadata.size.width == 100.0F && last_metadata.size.height == 100.0F,
                "loaded LottieMetadata mismatch");
        std::cout << "PASS positive: Loaded frames=" << last_metadata.frames
                  << " duration=" << last_metadata.duration << "s\n";

        while (completed_count < 1 && errors.empty() && std::chrono::steady_clock::now() < deadline) {
            platform.AdvanceClock(0.05);
            (void)platform.BuildFrame();
            platform.Pump(std::chrono::milliseconds{10});
            std::this_thread::sleep_for(std::chrono::milliseconds{1});
        }
        Require(completed_count == 1, "expected LottieEvents::Completed after playback");
        const auto textures = CollectTextures(platform.BuildFrame().render_frame.scene.root);
        Require(textures.size() == 1 && textures[0] && textures[0]->Revision() > 0,
                "expected published ExternalTexture frame");
        std::cout << "PASS positive: Completed emitted, texture revision=" << textures[0]->Revision() << '\n';

        // Positive LottieProgress seek control.
        const auto rev_before_seek = textures[0]->Revision();
        control = motion::LottieProgress{0.5};
        (void)platform.BuildFrame();
        while (textures[0]->Revision() == rev_before_seek && std::chrono::steady_clock::now() < deadline) {
            platform.Pump();
        }
        Require(textures[0]->Revision() > rev_before_seek, "LottieProgress did not render frame");
        std::cout << "PASS positive: LottieProgress seek published texture revision="
                  << textures[0]->Revision() << '\n';

        // Negative 3: Malformed JSON triggers LottieEvents::Failed at Stage::Decode.
        source = MakeJsonAsset("{invalid json");
        (void)platform.BuildFrame();
        while (errors.size() < 1 && std::chrono::steady_clock::now() < deadline) {
            platform.Pump();
        }
        Require(errors.size() == 1 && errors.back().stage == motion::LottieError::Stage::Decode,
                "expected Decode stage failure for malformed JSON");
        std::cout << "PASS negative: malformed JSON -> LottieError::Stage::Decode\n";

        // Negative 4: Empty RawAsset triggers LottieEvents::Failed at Stage::Resource.
        source = huxerui::RawAsset{};
        (void)platform.BuildFrame();
        while (errors.size() < 2 && std::chrono::steady_clock::now() < deadline) {
            platform.Pump();
        }
        Require(errors.size() == 2 && errors.back().stage == motion::LottieError::Stage::Resource,
                "expected Resource stage failure for empty RawAsset");
        std::cout << "PASS negative: empty RawAsset -> LottieError::Stage::Resource\n";

        std::cout << "lottie-consumer: all checks passed\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "FAIL: " << ex.what() << '\n';
        return 1;
    }
}
