// unifont feature assertion: the "uni" builtin font face only exists when
// compat.opencv was built with HAVE_UNIFONT (drawing_text.cpp gates the
// builtinFontData entry), so its usability IS the feature probe; CJK
// rendering through it must produce real ink. Linux-only (see mcpp.toml).
#if defined(__linux__) || defined(__APPLE__)
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <cstdio>

int main() {
    cv::FontFace uni("uni");
    cv::Mat img(64, 256, CV_8UC1, cv::Scalar(0));
    cv::putText(img, "中文字体", cv::Point(8, 44), cv::Scalar(255), uni, 28);
    int ink = cv::countNonZero(img);
    if (ink < 100) {
        std::printf("unifont: CJK ink %d too low — font not embedded?\n", ink);
        return 1;
    }
    std::printf("unifont ok: CJK putText ink=%d\n", ink);
    return 0;
}
#else
int main() { return 0; }
#endif
