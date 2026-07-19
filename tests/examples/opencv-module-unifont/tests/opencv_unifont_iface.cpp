// The "uni" FontFace only exists when opencv's unifont feature forwarded
// compat.opencv/unifont — CJK rendering through the module layer must ink.
// Linux-only (see mcpp.toml). Import-only (import std + opencv.cv): no textual
// headers, matching the ffmpeg-module member convention.
#if defined(__linux__) || defined(__APPLE__)
import std;
import opencv.cv;

int main() {
    cv::FontFace uni("uni");
    cv::Mat img(64, 256, cv::CV_8UC1, cv::Scalar(0));
    cv::putText(img, "中文字体", cv::Point(8, 44), cv::Scalar(255), uni, 28);
    int ink = cv::countNonZero(img);
    if (ink < 100) { std::println("opencv.unifont: CJK ink {} too low", ink); return 1; }
    std::println("opencv.unifont module ok: CJK putText ink={}", ink);
    return 0;
}
#else
int main() { return 0; }
#endif
