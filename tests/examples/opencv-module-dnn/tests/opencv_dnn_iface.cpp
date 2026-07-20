// The opencv.dnn MODULE interface (not textual headers) must expose the dnn
// surface when opencv is pulled with features=["dnn"] — proves the module-level
// dep/feat forward compiled src/dnn.cppm and built compat.opencv with dnn.
// Linux-only (see mcpp.toml). Not named dnn.cpp (would collide with the dep's
// modules/dnn/src/dnn.cpp — #240 family). Import-only (import std + the opencv
// modules): no textual headers, matching the ffmpeg-module member convention.
#if defined(__linux__) || defined(__APPLE__)
import std;
import opencv.cv;
import opencv.dnn;

int main() {
    cv::Mat img(32, 32, cv::CV_8UC3, cv::Scalar(10, 20, 30));
    cv::Mat blob = cv::dnn::blobFromImage(img, 1.0 / 255.0, cv::Size(16, 16),
                                          cv::Scalar(), true, false);
    if (blob.dims != 4 || blob.size[0] != 1 || blob.size[1] != 3
        || blob.size[2] != 16 || blob.size[3] != 16) return 1;
    float v = blob.ptr<float>(0)[0];
    if (v < 0.117f || v > 0.118f) return 2;   // 30/255, channels swapped
    cv::dnn::Net net;
    if (!net.empty()) return 3;
    std::println("opencv.dnn module ok: blobFromImage 1x3x16x16 first={}", v);
    return 0;
}
#else
int main() { return 0; }
#endif
