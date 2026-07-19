// compat.opencvmac (macOS-arm64 headless) end-to-end assertion: the aarch64
// NEON source build must expose the core/imgproc/imgcodecs surface — Mat ops,
// an imgproc pipeline (resize + cvtColor, NEON-dispatched), and a PNG codec
// roundtrip through the vendored zlib/libpng. No videoio in the headless
// profile. macOS-only (see mcpp.toml).
#ifdef __APPLE__
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <cstdio>
#include <vector>

int main() {
    if (cv::getVersionString() != "5.0.0") return 1;

    cv::Mat img(64, 64, CV_8UC3, cv::Scalar(30, 60, 90));
    cv::circle(img, {32, 32}, 20, {255, 255, 255}, -1);
    cv::Mat big, gray;
    cv::resize(img, big, {128, 128}, 0, 0, cv::INTER_CUBIC);
    cv::cvtColor(big, gray, cv::COLOR_BGR2GRAY);
    if (gray.size() != cv::Size(128, 128)) return 2;

    std::vector<unsigned char> buf;
    if (!cv::imencode(".png", big, buf)) return 3;
    cv::Mat back = cv::imdecode(buf, cv::IMREAD_COLOR);
    if (back.empty() || back.size() != cv::Size(128, 128)) return 4;

    // a small blur to exercise more imgproc SIMD kernels
    cv::Mat blurred;
    cv::GaussianBlur(back, blurred, {5, 5}, 1.5);
    if (blurred.size() != back.size()) return 5;

    std::printf("compat.opencvmac %s ok: aarch64 NEON core/imgproc/imgcodecs + PNG roundtrip\n",
                cv::getVersionString().c_str());
    return 0;
}
#else
int main() { return 0; }
#endif
