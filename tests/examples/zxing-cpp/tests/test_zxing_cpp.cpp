// Runtime roundtrip test — verify compat.zxing-cpp 3.1.1 creates, renders, and decodes barcodes
#include <ZXing/ZXingCpp.h>
#include <ZXing/ZXingC.h>
import std;

int main() {
    if (ZXing::Version() != "3.1.1") {
        std::println("unexpected ZXing::Version(): {}", ZXing::Version());
        return 1;
    }
    if (std::string_view(ZXing_Version()) != "3.1.1") {
        std::println("unexpected ZXing_Version(): {}", ZXing_Version());
        return 2;
    }

    auto qr = ZXing::CreateBarcodeFromText("hello mcpp zxing-cpp", ZXing::BarcodeFormat::QRCode);
    if (!qr.isValid()) {
        std::println("QR creation failed: {}", qr.error().msg());
        return 3;
    }
    auto img = ZXing::WriteBarcodeToImage(qr, ZXing::WriterOptions().scale(4));
    auto svg = ZXing::WriteBarcodeToSVG(qr, ZXing::WriterOptions().scale(4));
    if (!svg.contains("<svg")) {
        std::println("SVG output missing <svg tag");
        return 4;
    }
    auto decoded = ZXing::ReadBarcode(img);
    if (!decoded.isValid() || decoded.format() != ZXing::BarcodeFormat::QRCode ||
        decoded.text() != "hello mcpp zxing-cpp") {
        std::println("QR roundtrip failed: valid={} text={}", decoded.isValid(), decoded.text());
        return 5;
    }

    auto c128 = ZXing::CreateBarcodeFromText("MCPP-311", ZXing::BarcodeFormat::Code128);
    if (!c128.isValid()) {
        std::println("Code128 creation failed: {}", c128.error().msg());
        return 6;
    }
    auto img128 = ZXing::WriteBarcodeToImage(c128, ZXing::WriterOptions().scale(3));
    auto dec128 = ZXing::ReadBarcode(img128);
    if (!dec128.isValid() || dec128.format() != ZXing::BarcodeFormat::Code128 ||
        dec128.text() != "MCPP-311") {
        std::println("Code128 roundtrip failed: valid={} text={}", dec128.isValid(), dec128.text());
        return 7;
    }

    std::println("compat.zxing-cpp 3.1.1 roundtrip test: ok (QR svg={} bytes, Code128={})",
                 svg.size(), dec128.text());
    return 0;
}
