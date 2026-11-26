import std;
import huxerui;
import huxerui.map;

namespace hm = huxerui::map;

namespace {

int checks = 0;

void Check(bool condition, std::string_view msg = "Map check failed") {
    ++checks;
    if (!condition) {
        throw std::runtime_error(std::string(msg) + " (#" + std::to_string(checks) + ")");
    }
}

void Reject(const std::function<void(hm::MapOptions&)>& change, std::string_view label) {
    hm::MapOptions options;
    change(options);
    bool rejected = false;
    try {
        hm::Validate(options);
    } catch (const std::invalid_argument&) {
        rejected = true;
    }
    Check(rejected, label);
}

} // namespace

int main() {
    try {
        // Positive + negative model & validation checks (matching upstream model_tests.cpp).
        hm::Validate(hm::MapOptions{});
        Check(!hm::PrivacyConsent{}.Granted(), "empty consent must not be granted");
        Check(!hm::PrivacyConsent{true, false, true}.Granted(), "partial consent must not be granted");
        Check(hm::PrivacyConsent{true, true, true}.Granted(), "full consent should be granted");

        Reject([](auto& o) { o.camera.zoom = std::numeric_limits<double>::quiet_NaN(); }, "NaN zoom");
        Reject([](auto& o) { o.camera.zoom = 2.9; }, "zoom below 3");
        Reject([](auto& o) { o.camera.zoom = 20.1; }, "zoom above 20");
        Reject([](auto& o) { o.camera.center.latitude = 90.1; }, "lat > 90");
        Reject([](auto& o) { o.camera.center.longitude = -180.1; }, "lon < -180");
        Reject([](auto& o) { o.camera.center.longitude = std::numeric_limits<double>::infinity(); }, "inf lon");
        Reject([](auto& o) { o.markers = {{"a"}, {"a"}}; }, "duplicate marker id");
        Reject([](auto& o) { o.markers = {{""}}; }, "empty marker id");
        Reject([](auto& o) { o.markers = {{"a", {-91, 0}}}; }, "marker lat < -90");
        Reject([](auto& o) { o.polylines = {{"line", {{0, 0}}}}; }, "polyline < 2 pts");
        Reject([](auto& o) { o.polylines = {{"line", {{0, 0}, {1, 1}}, 0}}; }, "polyline width 0");
        Reject([](auto& o) { o.polylines = {{"line", {{0, 0}, {1, 1}}, 129}}; }, "polyline width > 128");
        Reject([](auto& o) { o.polylines = {{"line", {{0, 0}, {91, 0}}}}; }, "polyline lat > 90");
        Reject([](auto& o) { o.polylines = {{"a", {{0, 0}, {1, 1}}}, {"a", {{0, 0}, {1, 1}}}}; }, "dup polyline id");
        Reject([](auto& o) { o.type = static_cast<hm::MapType>(99); }, "unknown map type");

        hm::MapOptions valid;
        valid.camera = {{-90, 180}, 20};
        valid.markers = {{"a", {90, -180}, "Title", "Subtitle"}};
        valid.polylines = {{"a", {{0, 0}, {1, 1}}, 128}};
        valid.privacy = {true, true, true};
        hm::Validate(valid);
        Check(valid == hm::MapOptions(valid), "MapOptions copy equality");

        // Negative provider check for MapView.
        bool bad_provider_rejected = false;
        try {
            (void)hm::MapView(static_cast<hm::Provider>(99), valid);
        } catch (const std::invalid_argument&) {
            bad_provider_rejected = true;
        }
        Check(bad_provider_rejected, "unknown provider rejected");

        // Unsupported desktop fallback views & event decoders.
        Check(!hm::IsSupported(hm::Provider::AMap), "AMap unsupported on desktop");
        Check(!hm::IsSupported(hm::Provider::Baidu), "Baidu unsupported on desktop");
        (void)hm::AMapView(valid);
        (void)hm::BaiduMapView(valid);
        Check(hm::MapEvents::Loaded::Name == "loaded", "MapEvents::Loaded name");

        const auto coord_ev = hm::CoordinateEvent::Decode(
            huxerui::PlatformPayload::Object{{"latitude", 39.9}, {"longitude", 116.4}});
        Check(coord_ev.coordinate.latitude == 39.9 && coord_ev.coordinate.longitude == 116.4,
              "CoordinateEvent::Decode");

        const auto cam_ev = hm::CameraEvent::Decode(huxerui::PlatformPayload::Object{
            {"center", huxerui::PlatformPayload::Object{{"latitude", 31.2}, {"longitude", 121.5}}},
            {"zoom", 14.0},
        });
        Check(cam_ev.camera.zoom == 14.0 && cam_ev.camera.center.latitude == 31.2, "CameraEvent::Decode");

        const auto err = hm::MapError::Decode(
            huxerui::PlatformPayload::Object{{"code", "auth"}, {"message", "missing key"}});
        Check(err.code == "auth" && err.message == "missing key", "MapError::Decode");

        std::cout << "huxerui.map verification PASSED (" << checks << " checks)\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "FAIL: " << ex.what() << '\n';
        return 1;
    }
}
