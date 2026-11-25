-- compat.zxing-cpp — ZXing-C++ multi-format 1D/2D barcode reader and writer library.
-- Source build from upstream release asset (which includes bundled libzint for
-- modern writers alongside libzueci and the core C++/C barcode engine).
--
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "zxing-cpp",
    description = "ZXing-C++ — multi-format 1D/2D barcode reader and writer library in C++ (with bundled libzint and C API)",
    licenses    = { "Apache-2.0", "BSD-3-Clause" },
    repo        = "https://github.com/zxing-cpp/zxing-cpp",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/zxing-cpp/zxing-cpp/releases/download/${tag}/zxing-cpp-${version}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["3.1.1"] = {
                url    = "https://github.com/zxing-cpp/zxing-cpp/releases/download/v3.1.1/zxing-cpp-3.1.1.tar.gz",
                sha256 = "c3c02c29c0b519de7bd4e25b376e606e87f0761befd1282815642a2246613d14",
            },
        },
        macosx = {
            ["3.1.1"] = {
                url    = "https://github.com/zxing-cpp/zxing-cpp/releases/download/v3.1.1/zxing-cpp-3.1.1.tar.gz",
                sha256 = "c3c02c29c0b519de7bd4e25b376e606e87f0761befd1282815642a2246613d14",
            },
        },
        windows = {
            ["3.1.1"] = {
                url    = "https://github.com/zxing-cpp/zxing-cpp/releases/download/v3.1.1/zxing-cpp-3.1.1.tar.gz",
                sha256 = "c3c02c29c0b519de7bd4e25b376e606e87f0761befd1282815642a2246613d14",
            },
        },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c99",
        include_dirs  = { "mcpp_generated", "*/core/src" },
        license_files = { "*/LICENSE" },

        -- Snapshot of core/Version.h.in for 3.1.1 (readers + new bundled-libzint
        -- writers + C API) plus installed-style `<ZXing/...>` forwarding headers.
        generated_files = {
            ["mcpp_generated/Version.h"] = [=[
#pragma once

#define ZXING_READERS
#define ZXING_WRITERS

#define ZXING_ENABLE_1D 1
#define ZXING_ENABLE_AZTEC 1
#define ZXING_ENABLE_DATAMATRIX 1
#define ZXING_ENABLE_MAXICODE 1
#define ZXING_ENABLE_PDF417 1
#define ZXING_ENABLE_QRCODE 1

#define ZXING_USE_ZINT

#define ZXING_VERSION_MAJOR 3
#define ZXING_VERSION_MINOR 1
#define ZXING_VERSION_PATCH 1
#define ZXING_VERSION_SUFFIX ""
#define ZXING_VERSION_STR "3.1.1"
]=],
            ["mcpp_generated/ZXing/Barcode.h"]       = "#pragma once\n#include <Barcode.h>\n",
            ["mcpp_generated/ZXing/BarcodeFormat.h"] = "#pragma once\n#include <BarcodeFormat.h>\n",
            ["mcpp_generated/ZXing/CharacterSet.h"]  = "#pragma once\n#include <CharacterSet.h>\n",
            ["mcpp_generated/ZXing/ContentType.h"]   = "#pragma once\n#include <ContentType.h>\n",
            ["mcpp_generated/ZXing/CreateBarcode.h"] = "#pragma once\n#include <CreateBarcode.h>\n",
            ["mcpp_generated/ZXing/Error.h"]         = "#pragma once\n#include <Error.h>\n",
            ["mcpp_generated/ZXing/GTIN.h"]          = "#pragma once\n#include <GTIN.h>\n",
            ["mcpp_generated/ZXing/ImageView.h"]     = "#pragma once\n#include <ImageView.h>\n",
            ["mcpp_generated/ZXing/Point.h"]         = "#pragma once\n#include <Point.h>\n",
            ["mcpp_generated/ZXing/Quadrilateral.h"] = "#pragma once\n#include <Quadrilateral.h>\n",
            ["mcpp_generated/ZXing/ReadBarcode.h"]   = "#pragma once\n#include <ReadBarcode.h>\n",
            ["mcpp_generated/ZXing/ReaderOptions.h"] = "#pragma once\n#include <ReaderOptions.h>\n",
            ["mcpp_generated/ZXing/Version.h"]       = "#pragma once\n#include <Version.h>\n",
            ["mcpp_generated/ZXing/WriteBarcode.h"]  = "#pragma once\n#include <WriteBarcode.h>\n",
            ["mcpp_generated/ZXing/ZXVersion.h"]     = "#pragma once\n#include <ZXVersion.h>\n",
            ["mcpp_generated/ZXing/ZXingC.h"]        = "#pragma once\n#include <ZXingC.h>\n",
            ["mcpp_generated/ZXing/ZXingCpp.h"]      = "#pragma once\n#include <ZXingCpp.h>\n",
        },

        sources = {
            -- Common C++ sources (ZXING_READERS + ZXING_WRITERS=ON + ZXING_C_API=ON;
            -- excludes legacy ZXING_WRITERS_OLD units).
            "*/core/src/Barcode.cpp",
            "*/core/src/BarcodeFormat.cpp",
            "*/core/src/BinaryBitmap.cpp",
            "*/core/src/BitArray.cpp",
            "*/core/src/BitMatrix.cpp",
            "*/core/src/BitMatrixIO.cpp",
            "*/core/src/BitSource.cpp",
            "*/core/src/CharacterSet.cpp",
            "*/core/src/ConcentricFinder.cpp",
            "*/core/src/Content.cpp",
            "*/core/src/CreateBarcode.cpp",
            "*/core/src/ECI.cpp",
            "*/core/src/Error.cpp",
            "*/core/src/GlobalHistogramBinarizer.cpp",
            "*/core/src/GridSampler.cpp",
            "*/core/src/GTIN.cpp",
            "*/core/src/HRI.cpp",
            "*/core/src/HybridBinarizer.cpp",
            "*/core/src/JSON.cpp",
            "*/core/src/LocalGrid.cpp",
            "*/core/src/MultiFormatReader.cpp",
            "*/core/src/PerspectiveTransform.cpp",
            "*/core/src/ReadBarcode.cpp",
            "*/core/src/ReedSolomon.cpp",
            "*/core/src/ResultPoint.cpp",
            "*/core/src/TextDecoder.cpp",
            "*/core/src/TextEncoder.cpp",
            "*/core/src/Utf.cpp",
            "*/core/src/WhiteRectDetector.cpp",
            "*/core/src/WriteBarcode.cpp",
            "*/core/src/ZXingC.cpp",
            "*/core/src/ZXingCpp.cpp",

            -- Readers: Aztec
            "*/core/src/aztec/AZDecoder.cpp",
            "*/core/src/aztec/AZDetector.cpp",
            "*/core/src/aztec/AZReader.cpp",

            -- Readers: DataMatrix
            "*/core/src/datamatrix/DMBitLayout.cpp",
            "*/core/src/datamatrix/DMDataBlock.cpp",
            "*/core/src/datamatrix/DMDecoder.cpp",
            "*/core/src/datamatrix/DMDetector.cpp",
            "*/core/src/datamatrix/DMReader.cpp",
            "*/core/src/datamatrix/DMVersion.cpp",

            -- Readers: MaxiCode
            "*/core/src/maxicode/MCBitMatrixParser.cpp",
            "*/core/src/maxicode/MCDecoder.cpp",
            "*/core/src/maxicode/MCReader.cpp",

            -- Readers: 1D
            "*/core/src/oned/ODCodabarReader.cpp",
            "*/core/src/oned/ODCode39Reader.cpp",
            "*/core/src/oned/ODCode93Reader.cpp",
            "*/core/src/oned/ODCode128Reader.cpp",
            "*/core/src/oned/ODDataBarCommon.cpp",
            "*/core/src/oned/ODDataBarExpandedBitDecoder.cpp",
            "*/core/src/oned/ODDataBarExpandedReader.cpp",
            "*/core/src/oned/ODDataBarLimitedReader.cpp",
            "*/core/src/oned/ODDataBarReader.cpp",
            "*/core/src/oned/ODDXFilmEdgeReader.cpp",
            "*/core/src/oned/ODITFReader.cpp",
            "*/core/src/oned/ODMultiUPCEANReader.cpp",
            "*/core/src/oned/ODReader.cpp",
            "*/core/src/oned/ODTelepenReader.cpp",
            "*/core/src/oned/ODUPCEANCommon.cpp",

            -- Readers: PDF417
            "*/core/src/pdf417/MicroPDFReader.cpp",
            "*/core/src/pdf417/PDF417.cpp",
            "*/core/src/pdf417/PDFBarcodeValue.cpp",
            "*/core/src/pdf417/PDFBoundingBox.cpp",
            "*/core/src/pdf417/PDFCodewordDecoder.cpp",
            "*/core/src/pdf417/PDFDecoder.cpp",
            "*/core/src/pdf417/PDFDetectionResult.cpp",
            "*/core/src/pdf417/PDFDetectionResultColumn.cpp",
            "*/core/src/pdf417/PDFDetector.cpp",
            "*/core/src/pdf417/PDFReader.cpp",
            "*/core/src/pdf417/PDFScanningDecoder.cpp",
            "*/core/src/pdf417/ZXBigInteger.cpp",

            -- Readers: QRCode
            "*/core/src/qrcode/QRBitMatrixParser.cpp",
            "*/core/src/qrcode/QRCodecMode.cpp",
            "*/core/src/qrcode/QRDataBlock.cpp",
            "*/core/src/qrcode/QRDecoder.cpp",
            "*/core/src/qrcode/QRDetector.cpp",
            "*/core/src/qrcode/QRErrorCorrectionLevel.cpp",
            "*/core/src/qrcode/QRFormatInformation.cpp",
            "*/core/src/qrcode/QRReader.cpp",
            "*/core/src/qrcode/QRVersion.cpp",

            -- Bundled C libraries: libzueci + libzint
            "*/core/src/libzueci/zueci.c",
            "*/core/src/libzint/2of5inter.c",
            "*/core/src/libzint/2of5inter_based.c",
            "*/core/src/libzint/aztec.c",
            "*/core/src/libzint/codabar.c",
            "*/core/src/libzint/code.c",
            "*/core/src/libzint/code128.c",
            "*/core/src/libzint/common.c",
            "*/core/src/libzint/dmatrix.c",
            "*/core/src/libzint/dxfilmedge.c",
            "*/core/src/libzint/eci.c",
            "*/core/src/libzint/filemem.c",
            "*/core/src/libzint/general_field.c",
            "*/core/src/libzint/gs1.c",
            "*/core/src/libzint/large.c",
            "*/core/src/libzint/library.c",
            "*/core/src/libzint/maxicode.c",
            "*/core/src/libzint/medical.c",
            "*/core/src/libzint/output.c",
            "*/core/src/libzint/pdf417.c",
            "*/core/src/libzint/qr.c",
            "*/core/src/libzint/raster.c",
            "*/core/src/libzint/reedsol.c",
            "*/core/src/libzint/rss.c",
            "*/core/src/libzint/stubs.c",
            "*/core/src/libzint/svg.c",
            "*/core/src/libzint/telepen.c",
            "*/core/src/libzint/upcean.c",
            "*/core/src/libzint/vector.c",
        },

        -- core/src/librscpp/poly.h calls std::abs(int) without including <cstdlib>;
        -- libc++ 23 no longer supplies it transitively (same fix as compat.godot-cpp).
        cxxflags = { "-DZXING_INTERNAL", "-include", "cstdlib" },
        cflags   = { "-DZXING_INTERNAL", "-DZINT_NO_PNG", "-DZUECI_EMBED_NO_TO_ECI" },

        -- Keep `*/core/src/libzint` private to this package's own TUs
        -- (base-level private_include_dirs is inert; declare in each platform).
        linux = {
            include_dirs         = { "*/core/src/libzint" },
            private_include_dirs = { "*/core/src/libzint" },
        },
        macosx = {
            include_dirs         = { "*/core/src/libzint" },
            private_include_dirs = { "*/core/src/libzint" },
        },
        windows = {
            include_dirs         = { "*/core/src/libzint" },
            private_include_dirs = { "*/core/src/libzint" },
            cxxflags             = { "-D_CRT_SECURE_NO_WARNINGS", "-D_CRT_NONSTDC_NO_WARNINGS", "-DNOMINMAX" },
            cflags               = { "-D_CRT_SECURE_NO_WARNINGS", "-D_CRT_NONSTDC_NO_WARNINGS" },
        },

        targets = { ["zxing-cpp"] = { kind = "lib" } },
        deps    = {},
    },
}
