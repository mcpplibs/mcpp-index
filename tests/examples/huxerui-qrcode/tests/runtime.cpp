// Headless C++23 module consumer test for huxerui.qrcode.
// Verifies vendored ZXing 3.1.1 + generated Version.h compilation, QR/1D/2D
// encode-SVG-rasterize-decode round-trips, HuxerUI view construction, and
// std::invalid_argument exceptions across the module boundary.
import std;
import huxerui.qrcode;

int main() {
    using namespace huxerui::qrcode;

    bool ok = true;
    const auto check = [&](bool cond, std::string_view label) {
        if (!cond) {
            std::cerr << "FAILED: " << label << '\n';
            ok = false;
        }
    };

    // 1. Format queries (out-of-line in src/codec.cpp)
    check(FormatName(BarcodeFormat::QRCode) == "QR Code", "FormatName(QRCode)");
    check(CanEncode(BarcodeFormat::QRCode), "CanEncode(QRCode)");
    check(CanDecode(BarcodeFormat::QRCode), "CanDecode(QRCode)");
    check(!CanEncode(BarcodeFormat::MicroQRCode), "!CanEncode(MicroQRCode)");
    check(CanDecode(BarcodeFormat::MicroQRCode), "CanDecode(MicroQRCode)");

    // 2. Encode QR Code -> SVG -> Rasterize -> Decode round-trip (out-of-line in src/codec.cpp)
    const std::string_view payload = "https://github.com/HuxerUI/Lib-QRCode";
    const Symbol symbol = Encode(payload, {
        .format = BarcodeFormat::QRCode,
        .qr_error_correction = ErrorCorrection::High,
        .quiet_zone = 4,
    });
    check(symbol.Format() == BarcodeFormat::QRCode, "symbol.Format() == QRCode");
    check(symbol.Width() > 0 && symbol.Width() == symbol.Height(), "square QR dimensions");
    check(symbol.Modules().size() == static_cast<std::size_t>(symbol.Width()) * symbol.Height(),
          "symbol.Modules().size()");
    check(!symbol.IsDark(0, 0), "quiet zone corner is light");

    const std::string svg = symbol.ToSvg({.scale = 4, .foreground = 0x112233, .background = 0xFFFFFF});
    check(svg.starts_with("<svg xmlns=\"http://www.w3.org/2000/svg\""), "SVG header");
    check(svg.ends_with("</svg>"), "SVG footer");
    check(svg.find("#112233") != std::string::npos, "SVG foreground color");

    const GrayImage raster = symbol.Rasterize(4);
    check(raster.width == symbol.Width() * 4 && raster.height == symbol.Height() * 4, "raster dimensions");

    const std::optional<DecodeResult> decoded = Decode(raster.View(), {.formats = {BarcodeFormat::QRCode}});
    check(decoded.has_value(), "Decode() returned result");
    if (decoded) {
        check(decoded->format == BarcodeFormat::QRCode, "decoded format == QRCode");
        check(decoded->text == payload, "decoded text matches payload");
        check(decoded->error_correction == "H", "decoded ECC == H");
        check(!decoded->bytes.empty(), "decoded bytes non-empty");
    }

    const std::vector<DecodeResult> all = DecodeAll(raster.View());
    check(all.size() == 1 && all[0].text == payload, "DecodeAll() matches single QR");

    // 3. Linear & 2D symbologies compiled from ZXing OLD writers + readers
    for (auto fmt : {BarcodeFormat::Code128, BarcodeFormat::DataMatrix, BarcodeFormat::Aztec, BarcodeFormat::PDF417}) {
        const Symbol sym = Encode("HUXERUI-2026", {.format = fmt});
        const GrayImage img = sym.Rasterize(3);
        const auto res = Decode(img.View(), {.formats = {fmt}});
        check(res.has_value() && res->format == fmt && res->text == "HUXERUI-2026", FormatName(fmt));
    }

    // 4. Out-of-line HuxerUI View constructors (src/qrcode.cpp + exported huxerui::View)
    const huxerui::View qr_view = QRCode(symbol, {
        .foreground = huxerui::Color::Black(),
        .background = huxerui::Color::White(),
    }).With(huxerui::Frame{.width = 200.0F, .height = 200.0F});
    check(static_cast<bool>(qr_view), "QRCode(Symbol) produced valid View");

    const huxerui::View bar_view = Barcode("HUXERUI-2026", {.format = BarcodeFormat::Code128})
        .With(huxerui::Frame{.width = 320.0F, .height = 100.0F});
    check(static_cast<bool>(bar_view), "Barcode(text) produced valid View");

    // 5. Exception paths across module boundary
    bool threw_empty = false;
    try {
        static_cast<void>(Encode(""));
    } catch (const std::invalid_argument&) {
        threw_empty = true;
    }
    check(threw_empty, "Encode(\"\") throws std::invalid_argument");

    bool threw_wrong_fmt = false;
    try {
        static_cast<void>(QRCode(Encode("123456", {.format = BarcodeFormat::Code128})));
    } catch (const std::invalid_argument&) {
        threw_wrong_fmt = true;
    }
    check(threw_wrong_fmt, "QRCode(Code128 symbol) throws std::invalid_argument");

    std::cout << "qrcode module_smoke: " << (ok ? "ok" : "FAILED") << '\n';
    return ok ? 0 : 1;
}
