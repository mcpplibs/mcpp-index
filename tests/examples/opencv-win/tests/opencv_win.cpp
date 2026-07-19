// compat.opencv windows-x86_64 CORE end-to-end: mcpp clang-MSVC source build of
// core/imgproc/imgcodecs — Mat ops, imgproc, PNG codec roundtrip — x86_64 SIMD
// dispatch, headless. videoio is macOS/linux-only for now (see mcpp.toml). win-only.
#ifdef _WIN32
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
    if (cv::imdecode(buf, cv::IMREAD_COLOR).empty()) return 4;
    std::printf("compat.opencv 5.0.0 windows ok: core/imgproc/imgcodecs (x86_64 SIMD, headless)\n");
    return 0;
}
#else
int main() { return 0; }
#endif
