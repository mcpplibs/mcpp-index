// Headless C++23 module consumer test for huxerui.pdf.
// Verifies package resolution, transitive huxerui.huxerui & compat.pdfium linking,
// minimal PDF 1.4 loading/rendering/PNG export, and malformed-PDF PdfException
// throwing across the C++23 module boundary.
import std;
import huxerui;
import huxerui.pdf;

namespace {

void Require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

constexpr std::string_view kMinimalPdf =
    "%PDF-1.4\n"
    "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n"
    "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n"
    "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 200 100] >>\nendobj\n"
    "xref\n0 4\n"
    "0000000000 65535 f \n"
    "0000000009 00000 n \n"
    "0000000058 00000 n \n"
    "0000000115 00000 n \n"
    "trailer\n<< /Size 4 /Root 1 0 R >>\n"
    "startxref\n186\n%%EOF\n";

} // namespace

int main() {
    try {
        using namespace huxerui::pdf;

        // 1. Version check
        const auto ver = Version();
        Require(ver == "0.2.1", "expected huxerui::pdf::Version() == \"0.2.1\"");
        std::cout << "PASS version: " << ver << '\n';

        // 2. Load valid minimal 1-page PDF 1.4 buffer
        const auto* raw_ptr = reinterpret_cast<const std::byte*>(kMinimalPdf.data());
        const std::span<const std::byte> pdf_bytes(raw_ptr, kMinimalPdf.size());
        const PdfDocument doc = PdfDocument::FromBytes(pdf_bytes);
        Require(doc.PageCount() == 1, "expected PageCount() == 1");
        const PageSize page_size = doc.Size(0);
        Require(page_size.width == 200.0 && page_size.height == 100.0,
                "expected Size(0) == 200x100");

        // 3. Render page 0 and verify non-zero RGBA dimensions and pixel buffer
        const PdfBitmap bitmap = doc.Render(0, RenderOptions{.width = 200});
        Require(bitmap.width == 200 && bitmap.height == 100,
                "expected rendered bitmap dimensions 200x100");
        Require(!bitmap.pixels.empty(), "expected non-empty RGBA pixel buffer");
        Require(bitmap.pixels.size() == static_cast<std::size_t>(bitmap.width) * bitmap.height * 4U,
                "expected tightly packed RGBA8 buffer");
        Require(bitmap.pixels[0] == 255 && bitmap.pixels[1] == 255
                    && bitmap.pixels[2] == 255 && bitmap.pixels[3] == 255,
                "expected default opaque white background pixel");
        const auto png = bitmap.ToPng();
        Require(png.size() > 8 && png[0] == std::byte{137} && png[1] == std::byte{'P'},
                "expected valid PNG output from PdfBitmap::ToPng()");

        // 4. Exercise public view/source/option types from pdf.h
        const PdfSource empty_source;
        Require(!empty_source.HasValue(), "expected default PdfSource::HasValue() == false");
        const PdfSource doc_source(doc);
        Require(doc_source.HasValue(), "expected PdfSource(PdfDocument)::HasValue() == true");
        const PdfOptions opts{.page = 0, .page_width = 200.0F, .zoom = 1.0F, .render_scale = 1.0F};
        Require(opts.page == 0 && opts.zoom == 1.0F, "expected PdfOptions fields");
        const PdfPageProperties page_props{};
        Require(page_props.fit == huxerui::ImageFit::Contain, "expected default PdfPageProperties::fit");
        const PdfSnapshot empty_snap{};
        Require(empty_snap.status == PdfStatus::Empty, "expected default PdfSnapshot::status");
        const PdfError sample_err{PdfErrorCode::Format, PdfErrorStage::Load, "bad"};
        Require(sample_err.stage == PdfErrorStage::Load, "expected PdfError fields");

        std::cout << "PASS positive: loaded 1-page PDF (" << page_size.width << "x" << page_size.height
                  << "), rendered " << bitmap.width << "x" << bitmap.height
                  << " (" << bitmap.pixels.size() << " RGBA bytes, " << png.size() << " PNG bytes)\n";

        // 5. Negative test: malformed bytes ("not-a-pdf") must throw PdfException
        constexpr std::string_view kBadPdf = "not-a-pdf";
        const std::span<const std::byte> bad_bytes(
            reinterpret_cast<const std::byte*>(kBadPdf.data()), kBadPdf.size());
        bool caught = false;
        try {
            const auto bad_doc = PdfDocument::FromBytes(bad_bytes);
            (void)bad_doc;
        } catch (const PdfException& ex) {
            caught = true;
            Require(ex.Code() == PdfErrorCode::Format,
                    "expected PdfErrorCode::Format for malformed PDF bytes");
            Require(ex.what() != nullptr && ex.what()[0] != '\0',
                    "expected non-empty PdfException::what()");
            std::cout << "PASS negative: caught PdfException (code="
                      << static_cast<int>(ex.Code()) << ", msg=\"" << ex.what() << "\")\n";
        }
        Require(caught, "expected PdfDocument::FromBytes(\"not-a-pdf\") to throw PdfException");

        std::cout << "PASS: all pdf-consumer checks succeeded\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "FAIL: " << ex.what() << '\n';
        return 1;
    }
}
