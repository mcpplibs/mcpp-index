import std;
import mcpplibs.mwrap.opencv;

int main() {
    namespace types = mcpplibs::mwrap::opencv::macros;
    if (cv::getBuildInformation().find("WEBP: YES") == std::string::npos) return 8;
    cv::Mat image(8, 8, types::CV_8UC4, cv::Scalar(20, 80, 160, 180));
    image.at<cv::Vec4b>(0, 0) = cv::Vec4b(7, 19, 23, 0);
    std::vector<uchar> bytes;
    if (!cv::imencode(".webp", image, bytes,
        {cv::IMWRITE_WEBP_LOSSLESS_MODE, cv::IMWRITE_WEBP_LOSSLESS_PRESERVE_COLOR})) return 1;
    auto decoded = cv::imdecode(bytes, cv::IMREAD_UNCHANGED);
    if (decoded.empty() || decoded.type() != image.type() || decoded.size() != image.size() ||
        cv::norm(decoded, image, cv::NORM_INF) != 0) return 2;

    cv::Animation animation(2);
    animation.frames = {cv::Mat(8, 8, types::CV_8UC4, cv::Scalar(20, 80, 160, 180)),
                        cv::Mat(8, 8, types::CV_8UC4, cv::Scalar(100, 40, 70, 200))};
    animation.durations = {80, 120};
    if (!cv::imencodeanimation(".webp", animation, bytes, {cv::IMWRITE_WEBP_QUALITY, 101})) return 3;
    cv::Animation restored;
    if (!cv::imdecodeanimation(bytes, restored) || restored.loop_count != 2 ||
        restored.durations != animation.durations || restored.frames.size() != 2) return 4;
    for (int frame = 0; frame < 2; ++frame)
        if (restored.frames[frame].type() != animation.frames[frame].type() ||
            restored.frames[frame].size() != animation.frames[frame].size() ||
            cv::norm(restored.frames[frame], animation.frames[frame], cv::NORM_INF) != 0) return 5;

    const std::string xmp = "<x:xmpmeta xmlns:x='adobe:ns:meta/'>archive</x:xmpmeta>";
    cv::Mat chunk(1, static_cast<int>(xmp.size()), types::CV_8U, const_cast<char*>(xmp.data()));
    const std::vector<int> kinds{cv::IMAGE_METADATA_XMP};
    const std::vector<cv::Mat> metadata{chunk};
    if (!cv::imencodeWithMetadata(".webp", animation.frames[0], kinds, metadata, bytes,
        {cv::IMWRITE_WEBP_LOSSLESS_MODE, cv::IMWRITE_WEBP_LOSSLESS_ON})) return 6;
    std::vector<int> decoded_kinds;
    std::vector<cv::Mat> decoded_metadata;
    decoded = cv::imdecodeWithMetadata(bytes, decoded_kinds, decoded_metadata, cv::IMREAD_UNCHANGED);
    if (decoded.empty() || decoded_kinds != kinds || decoded_metadata.size() != 1 ||
        decoded_metadata[0].total() != xmp.size() ||
        std::memcmp(decoded_metadata[0].data, xmp.data(), xmp.size()) != 0) return 7;
    std::println("OpenCV WebP archive: lossless alpha, animation and XMP metadata passed");
}
