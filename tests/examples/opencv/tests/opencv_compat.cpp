// compat.opencv end-to-end assertion: the source build must expose the
// five-module surface (Mat/imgproc ops, PNG codec roundtrip) AND the
// FFmpeg videoio backend pulled in through the compat.ffmpeg dependency —
// proven by a real mp4 encode -> decode roundtrip on linux + macOS, not just registry
// presence. Linux-only (see mcpp.toml).
#if defined(__linux__) || defined(__APPLE__)
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/videoio/registry.hpp>
#include <cstdio>
#include <string>
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

    if (!cv::videoio_registry::hasBackend(cv::CAP_FFMPEG)) return 5;
    const std::string path = "compat_opencv_roundtrip.mp4";
    {
        cv::VideoWriter w(path, cv::CAP_FFMPEG,
                          cv::VideoWriter::fourcc('m','p','4','v'), 25.0,
                          cv::Size(128, 128));
        if (!w.isOpened()) return 6;
        for (int i = 0; i < 10; i++) {
            cv::Mat f(128, 128, CV_8UC3, cv::Scalar(10 * i, 128, 255 - 10 * i));
            cv::putText(f, std::to_string(i), {8, 100},
                        cv::FONT_HERSHEY_SIMPLEX, 2.5, {255, 255, 255}, 3);
            w.write(f);
        }
    }
    cv::VideoCapture cap(path, cv::CAP_FFMPEG);
    if (!cap.isOpened()) return 7;
    int n = 0; cv::Mat f; double meanB0 = -1;
    while (cap.read(f)) { if (n == 0) meanB0 = cv::mean(f)[0]; n++; }
    std::remove(path.c_str());
    if (n != 10) return 8;
    if (meanB0 < 0 || meanB0 > 40) return 9;

    std::printf("compat.opencv %s ok: imgproc/imgcodecs + FFmpeg mp4 roundtrip (%zu backends)\n",
                cv::getVersionString().c_str(),
                cv::videoio_registry::getBackends().size());
    return 0;
}
#else
int main() { return 0; }
#endif
