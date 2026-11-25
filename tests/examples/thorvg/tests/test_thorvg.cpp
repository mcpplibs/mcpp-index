#include <thorvg.h>

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <vector>

// TVG_STATIC must arrive from compat.thorvg so Windows static builds do not mark APIs dllimport.
#ifndef TVG_STATIC
#error "TVG_STATIC did not propagate from compat.thorvg to consumer"
#endif

// Verify private ThorVG internals do not leak onto the consumer include path.
#if __has_include("tvgCommon.h") || __has_include("tvgSwCommon.h") || __has_include("tvgLottieLoader.h")
#error "compat.thorvg leaked private internal headers into consumer include path"
#endif

namespace {

int g_failures = 0;

void Check(bool ok, const char* label) {
    std::printf("%-62s %s\n", label, ok ? "ok" : "FAILED");
    if (!ok) {
        ++g_failures;
    }
}

} // namespace

int main() {
    const auto init_res = tvg::Initializer::init(0);
    Check(init_res == tvg::Result::Success, "Initializer::init(0) succeeds");

    uint32_t maj = 0, min = 0, mic = 0;
    const char* ver = tvg::Initializer::version(&maj, &min, &mic);
    Check(ver != nullptr && std::strcmp(ver, "1.1.3") == 0 && maj == 1 && min == 1 && mic == 3,
          "Initializer::version reports 1.1.3");

    // Positive 1: Software rasterizer Shape draw into uint32_t ABGR8888 pixel buffer.
    {
        constexpr uint32_t kW = 100;
        constexpr uint32_t kH = 100;
        std::vector<uint32_t> pixels(kW * kH, 0u);

        std::unique_ptr<tvg::SwCanvas> canvas(tvg::SwCanvas::gen());
        Check(canvas != nullptr, "SwCanvas::gen() returns non-null");
        if (canvas) {
            Check(canvas->target(pixels.data(), kW, kW, kH, tvg::ColorSpace::ABGR8888) == tvg::Result::Success,
                  "SwCanvas::target() succeeds");
            auto* shape = tvg::Shape::gen();
            Check(shape != nullptr, "Shape::gen() returns non-null");
            if (shape) {
                Check(shape->appendRect(20.0f, 20.0f, 60.0f, 60.0f) == tvg::Result::Success,
                      "Shape::appendRect() succeeds");
                Check(shape->fill(255, 0, 0, 255) == tvg::Result::Success, "Shape::fill() succeeds");
                Check(canvas->add(shape) == tvg::Result::Success, "SwCanvas::add(shape) succeeds");
                Check(canvas->draw(true) == tvg::Result::Success, "SwCanvas::draw(true) succeeds");
                Check(canvas->sync() == tvg::Result::Success, "SwCanvas::sync() succeeds");

                const uint32_t center = pixels[50 * kW + 50];
                const uint32_t corner = pixels[5 * kW + 5];
                Check(center == 0xff0000ffu && corner == 0u,
                      "Shape renders red ABGR8888 pixel at center and 0 at corner");
            }
        }
    }

    // Positive 2: Lottie animation JSON decode + SwCanvas rasterization + frame seek.
    {
        static constexpr char kMotionJson[] =
            R"({"v":"5.7.4","fr":60,"ip":0,"op":60,"w":100,"h":100,"nm":"Moving circle","ddd":0,"assets":[],"layers":[{"ddd":0,"ind":1,"ty":4,"nm":"Circle","sr":1,"ks":{"o":{"a":0,"k":100},"r":{"a":0,"k":0},"p":{"a":1,"k":[{"t":0,"s":[20,50,0],"e":[80,50,0],"o":{"x":0.333,"y":0.333},"i":{"x":0.667,"y":0.667}},{"t":60,"s":[80,50,0]}]},"a":{"a":0,"k":[0,0,0]},"s":{"a":0,"k":[100,100,100]}},"shapes":[{"ty":"el","p":{"a":0,"k":[0,0]},"s":{"a":0,"k":[20,20]},"d":1,"nm":"Ellipse"},{"ty":"fl","c":{"a":0,"k":[1,0,0,1]},"o":{"a":0,"k":100},"r":1,"nm":"Red"}],"ip":0,"op":60,"st":0,"bm":0}]})";

        constexpr uint32_t kW = 100;
        constexpr uint32_t kH = 100;
        std::vector<uint32_t> pixels(kW * kH, 0u);

        std::unique_ptr<tvg::Animation> anim(tvg::Animation::gen());
        std::unique_ptr<tvg::SwCanvas> canvas(tvg::SwCanvas::gen());
        Check(anim != nullptr && canvas != nullptr, "Animation::gen() and SwCanvas::gen() succeed");
        if (anim && canvas) {
            auto* picture = anim->picture();
            Check(picture != nullptr, "Animation::picture() returns non-null");
            const auto load_res = picture->load(
                kMotionJson, static_cast<uint32_t>(sizeof(kMotionJson) - 1), "lottie", nullptr, true);
            Check(load_res == tvg::Result::Success, "Lottie Picture::load() succeeds");
            float pw = 0.0f, ph = 0.0f;
            Check(picture->size(&pw, &ph) == tvg::Result::Success && pw == 100.0f && ph == 100.0f,
                  "Lottie Picture::size() reports 100x100");
            Check(anim->totalFrame() > 0.0f && anim->duration() > 0.0f,
                  "Lottie totalFrame() and duration() are positive");

            Check(canvas->target(pixels.data(), kW, kW, kH, tvg::ColorSpace::ABGR8888) == tvg::Result::Success,
                  "SwCanvas::target() for Lottie succeeds");
            Check(canvas->add(picture) == tvg::Result::Success, "SwCanvas::add(lottie picture) succeeds");
            Check(canvas->update() == tvg::Result::Success, "SwCanvas::update() for frame 0 succeeds");
            Check(canvas->draw(true) == tvg::Result::Success, "SwCanvas::draw(true) for frame 0 succeeds");
            Check(canvas->sync() == tvg::Result::Success, "SwCanvas::sync() for frame 0 succeeds");
            Check(pixels[50 * kW + 20] == 0xff0000ffu && pixels[50 * kW + 50] == 0u,
                  "Lottie frame 0 renders circle at (20,50) and transparent at (50,50)");

            Check(anim->frame(30.0f) == tvg::Result::Success, "Animation::frame(30) succeeds");
            Check(canvas->update() == tvg::Result::Success, "SwCanvas::update() for frame 30 succeeds");
            Check(canvas->draw(true) == tvg::Result::Success, "SwCanvas::draw(true) for frame 30 succeeds");
            Check(canvas->sync() == tvg::Result::Success, "SwCanvas::sync() for frame 30 succeeds");
            Check(pixels[50 * kW + 50] == 0xff0000ffu && pixels[50 * kW + 20] == 0u,
                  "Lottie frame 30 renders circle at (50,50) and transparent at (20,50)");
        }
    }

    // Negative: malformed Lottie JSON and empty payload must be rejected.
    {
        std::unique_ptr<tvg::Animation> bad_anim(tvg::Animation::gen());
        Check(bad_anim != nullptr, "Negative test Animation::gen() succeeds");
        if (bad_anim) {
            static constexpr char kBadJson[] = "{invalid lottie json";
            const auto bad_res = bad_anim->picture()->load(
                kBadJson, static_cast<uint32_t>(sizeof(kBadJson) - 1), "lottie", nullptr, true);
            Check(bad_res != tvg::Result::Success, "Malformed Lottie JSON returns non-Success");

            const auto empty_res = bad_anim->picture()->load("", 0, "lottie", nullptr, true);
            Check(empty_res == tvg::Result::InvalidArguments, "Empty Lottie payload returns InvalidArguments");
        }
    }

    const auto term_res = tvg::Initializer::term();
    Check(term_res == tvg::Result::Success, "Initializer::term() succeeds");

    std::printf("\n%d check(s) failed\n", g_failures);
    return g_failures == 0 ? 0 : 1;
}
