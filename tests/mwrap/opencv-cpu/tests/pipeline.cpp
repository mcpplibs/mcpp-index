import std;
import mcpplibs.mwrap.opencv;

int main() {
    namespace types = mcpplibs::mwrap::opencv::macros;
    cv::Mat color(8, 12, types::CV_8UC3, cv::Scalar(20, 80, 160)), gray;
    cv::cvtColor(color, gray, cv::COLOR_BGR2GRAY);
    if (gray.rows != 8 || gray.cols != 12 || gray.type() != types::CV_8UC1) return 1;
    if (cv::norm(gray, cv::Mat(8, 12, types::CV_8UC1, cv::Scalar(97)), cv::NORM_INF) != 0) return 2;
    std::vector<uchar> bytes;
    if (!cv::imencode(".png", gray, bytes) || bytes.empty()) return 3;
    const auto decoded = cv::imdecode(bytes, cv::IMREAD_UNCHANGED);
    if (decoded.empty() || decoded.size() != gray.size() ||
        cv::norm(decoded, gray, cv::NORM_INF) != 0) return 4;
    if (cv::saturate_cast<unsigned>(-1) != 0 ||
        cv::saturate_cast<uchar>(static_cast<ushort>(256)) != 255 ||
        cv::saturate_cast<uint64>(1.8) != 2) return 5;
    const int first = 7, second = 7;
    if (&cv::min(first, second) != &first || &cv::max(first, second) != &first) return 6;
    if (!cv::imencode(".jpg", gray, bytes)) return 8;
    const auto jpeg = cv::imdecode(bytes, cv::IMREAD_UNCHANGED);
    if (jpeg.empty() || jpeg.size() != gray.size() ||
        cv::norm(jpeg, gray, cv::NORM_INF) > 2) return 9;
    const auto value = cv::makePtr<int>(19);
    if (*value != 19) return 7;
    // Exercise the qualified SDK names restored in the indexed candidate.
    using FpState = cv::details::FPDenormalsModeState;
    static_assert(sizeof(FpState) == 64);
    static_assert(std::is_same_v<decltype(&cv::details::saveFPDenormalsState), int (*)(FpState&)>);
    static_assert(std::is_same_v<decltype(&cv::details::restoreFPDenormalsState), bool (*)(const FpState&)>);
    FpState before{}, after{};
    cv::details::saveFPDenormalsState(before);
    {
        cv::details::FPDenormalsIgnoreHintScope scope(true);
    }
    cv::details::saveFPDenormalsState(after);
    for (int i = 0; i < 16; ++i)
        if (before.reserved[i] != after.reserved[i]) return 10;
    std::println("OpenCV {} archive: exact gray pixels, PNG/JPEG roundtrips and scalar contracts passed",
                 cv::getVersionString());
}
