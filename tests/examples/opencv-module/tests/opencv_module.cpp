// Public opencv module package end-to-end assertion: import-only consumption
// (`import opencv.cv;`), pinned version, Mat/imgproc ops (incl. the
// replacement operator surface: Size comparison via != crosses the module
// boundary — the v0.0.1 regression scenario), PNG+JPEG codec roundtrips,
// videoio registry. Linux-only (see mcpp.toml).
#if defined(__linux__) || defined(__APPLE__) || defined(_WIN32)
import std;
import opencv.cv;

int main() {
    if (cv::getVersionString() != "5.0.0") return 1;

    cv::Mat img(64, 64, cv::CV_8UC3, cv::Scalar(30, 60, 90));
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
    std::println("OpenCV {} module package ok", cv::getVersionString());
    return 0;
}
#else
int main() { return 0; }
#endif
