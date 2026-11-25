// Runtime roundtrip test — verify compat.pdfium 8165 creates, saves, reloads, and renders a PDF
#include <fpdfview.h>
#include <fpdf_edit.h>
#include <fpdf_save.h>
#include <cpp/fpdf_scopers.h>
import std;

namespace {

struct MemWriter {
    FPDF_FILEWRITE base;
    std::vector<unsigned char> bytes;
};

int write_block(FPDF_FILEWRITE* self, const void* data, unsigned long size) {
    auto* writer = reinterpret_cast<MemWriter*>(self);
    const auto* ptr = static_cast<const unsigned char*>(data);
    writer->bytes.insert(writer->bytes.end(), ptr, ptr + size);
    return 1;
}

} // namespace

int main() {
    FPDF_InitLibrary();

    std::vector<unsigned char> pdf_bytes;
    {
        ScopedFPDFDocument doc(FPDF_CreateNewDocument());
        if (!doc) {
            FPDF_DestroyLibrary();
            return 1;
        }
        ScopedFPDFPage page(FPDFPage_New(doc.get(), 0, 200.0, 100.0));
        if (!page) {
            FPDF_DestroyLibrary();
            return 2;
        }

        MemWriter writer{};
        writer.base.version = 1;
        writer.base.WriteBlock = &write_block;
        if (!FPDF_SaveAsCopy(doc.get(), &writer.base, 0)) {
            FPDF_DestroyLibrary();
            return 3;
        }
        pdf_bytes = std::move(writer.bytes);
    }

    if (pdf_bytes.size() <= 10 ||
        std::string_view(reinterpret_cast<const char*>(pdf_bytes.data()), 5) != "%PDF-") {
        FPDF_DestroyLibrary();
        return 4;
    }

    int page_count = 0;
    double width = 0.0;
    double height = 0.0;
    {
        ScopedFPDFDocument loaded(
            FPDF_LoadMemDocument(pdf_bytes.data(), static_cast<int>(pdf_bytes.size()), nullptr));
        if (!loaded) {
            FPDF_DestroyLibrary();
            return 5;
        }
        page_count = FPDF_GetPageCount(loaded.get());
        if (page_count != 1) {
            FPDF_DestroyLibrary();
            return 6;
        }
        ScopedFPDFPage loaded_page(FPDF_LoadPage(loaded.get(), 0));
        if (!loaded_page) {
            FPDF_DestroyLibrary();
            return 7;
        }
        width = FPDF_GetPageWidth(loaded_page.get());
        height = FPDF_GetPageHeight(loaded_page.get());
        if (width != 200.0 || height != 100.0) {
            FPDF_DestroyLibrary();
            return 8;
        }
        ScopedFPDFBitmap bmp(FPDFBitmap_Create(200, 100, 0));
        if (!bmp) {
            FPDF_DestroyLibrary();
            return 9;
        }
        if (!FPDFBitmap_FillRect(bmp.get(), 0, 0, 200, 100, 0xFFFFFFFF)) {
            FPDF_DestroyLibrary();
            return 10;
        }
        FPDF_RenderPageBitmap(bmp.get(), loaded_page.get(), 0, 0, 200, 100, 0, 0);
        if (FPDFBitmap_GetBuffer(bmp.get()) == nullptr) {
            FPDF_DestroyLibrary();
            return 11;
        }
    }

    FPDF_DestroyLibrary();
    std::println("compat.pdfium 8165 roundtrip test: ok (pdf={} bytes, pages={}, {}x{})",
                 pdf_bytes.size(), page_count, width, height);
    return 0;
}
