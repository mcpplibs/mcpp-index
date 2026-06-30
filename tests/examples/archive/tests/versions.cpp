// libarchive object lifecycle + version probes across all codecs.
#include <archive.h>
#include <archive_entry.h>
#include <bzlib.h>
#include <lz4.h>
#include <lzma.h>
#include <zlib.h>
#include <zstd.h>

int main() {
    archive* writer = archive_write_new();
    if (!writer) return 1;
    archive_write_free(writer);
    archive_entry* entry = archive_entry_new();
    if (!entry) return 2;
    archive_entry_free(entry);
    if (!archive_version_string()) return 3;
    if (!zlibVersion()) return 4;
    if (!BZ2_bzlibVersion()) return 5;
    if (LZ4_versionNumber() <= 0) return 6;
    if (ZSTD_versionNumber() == 0) return 7;
    if (lzma_version_number() == 0) return 8;
    return 0;
}
