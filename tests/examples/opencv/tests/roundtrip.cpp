// compat.opencv end-to-end assertion across core + imgproc + imgcodecs, linked
// against the static libs built from source by the package's install() CMake hook.
// Linux-only (see mcpp.toml); off-Linux this is a no-op main so `mcpp test
// --workspace` is clean on macOS/Windows.
#if defined(__linux__) || defined(__APPLE__)
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <vector>

int main() {
    // core: construct a 4x4 BGR image, solid blue (B=255).
    cv::Mat bgr(4, 4, CV_8UC3, cv::Scalar(255, 0, 0));
    if (bgr.rows != 4 || bgr.cols != 4 || bgr.channels() != 3) return 1;

    // imgproc: BGR->GRAY. Blue luma = round(0.114*255) = 29.
    cv::Mat gray;
    cv::cvtColor(bgr, gray, cv::COLOR_BGR2GRAY);
    if (gray.channels() != 1) return 2;
    if (gray.at<unsigned char>(0, 0) != 29) return 3;

    // imgcodecs: encode gray to PNG in memory, decode back, assert round-trip.
    std::vector<unsigned char> buf;
    if (!cv::imencode(".png", gray, buf) || buf.empty()) return 4;
    cv::Mat back = cv::imdecode(buf, cv::IMREAD_GRAYSCALE);
    if (back.empty() || back.rows != 4 || back.cols != 4) return 5;
    if (back.at<unsigned char>(0, 0) != 29) return 6;

    return 0;
}
#else
int main() { return 0; }  // compat.opencv is Linux-only for now; no-op elsewhere
#endif
