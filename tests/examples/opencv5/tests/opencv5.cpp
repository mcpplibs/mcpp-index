// compat.opencv5 end-to-end assertion: the source build must expose the
// five-module surface — Mat/imgproc ops, PNG+JPEG codec roundtrips, the
// videoio registry — and report the pinned version. Linux-only (see
// mcpp.toml).
#ifdef __linux__
#include <opencv2/core.hpp>
#include <opencv2/core/utility.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/videoio/registry.hpp>

int main() {
    if (cv::getVersionString() != "5.0.0") return 1;

    cv::Mat img(64, 64, CV_8UC3, cv::Scalar(30, 60, 90));
    cv::circle(img, {32, 32}, 20, {255, 255, 255}, -1);
    cv::Mat big, gray;
    cv::resize(img, big, {128, 128}, 0, 0, cv::INTER_CUBIC);
    cv::cvtColor(big, gray, cv::COLOR_BGR2GRAY);
    if (gray.size() != cv::Size(128, 128)) return 2;

    for (const char* ext : { ".png", ".jpg" }) {
        std::vector<unsigned char> buf;
        if (!cv::imencode(ext, big, buf)) return 3;
        cv::Mat back = cv::imdecode(buf, cv::IMREAD_COLOR);
        if (back.empty() || back.size() != big.size()) return 4;
    }

    if (cv::videoio_registry::getBackends().empty()) return 5;
    return 0;
}
#else
int main() { return 0; }   // package is linux-only for now
#endif
