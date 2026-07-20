// (file deliberately NOT named dnn.cpp: it would collide with the dep's
// modules/dnn/src/dnn.cpp — the #233 disambiguation misses test-target
// scan edges, same family as mcpp#240.)
// dnn feature assertion: blobFromImage produces a correctly-shaped and
// correctly-valued NCHW blob (exercises dnn core + the whole protobuf/mlas
// link closure), and an empty Net constructs. Linux-only (see mcpp.toml).
#if defined(__linux__) || defined(__APPLE__)
#include <opencv2/core.hpp>
#include <opencv2/dnn.hpp>
#include <cstdio>

int main() {
    cv::Mat img(32, 32, CV_8UC3, cv::Scalar(10, 20, 30));
    cv::Mat blob = cv::dnn::blobFromImage(img, 1.0 / 255.0, cv::Size(16, 16),
                                          cv::Scalar(), true, false);
    if (blob.dims != 4 || blob.size[0] != 1 || blob.size[1] != 3
        || blob.size[2] != 16 || blob.size[3] != 16) return 1;
    float v = blob.ptr<float>(0)[0];
    if (v < 0.117f || v > 0.118f) return 2;    // 30/255, channels swapped
    cv::dnn::Net net;
    if (!net.empty()) return 3;
    std::printf("dnn feature ok: blobFromImage 1x3x16x16, first=%f\n", v);
    return 0;
}
#else
int main() { return 0; }
#endif
