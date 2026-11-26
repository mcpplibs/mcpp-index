import std;
import huxerui.archive;

namespace {

using huxerui::Bytes;
using huxerui::File;
using huxerui::IoResult;
using namespace huxerui::archive;

struct TempDirGuard {
    std::filesystem::path path;
    ~TempDirGuard() {
        std::error_code ec;
        std::filesystem::remove_all(path, ec);
    }
};

bool Check(bool cond, std::string_view label, int& failures) {
    if (!cond) {
        std::cerr << "FAIL: " << label << '\n';
        ++failures;
        return false;
    }
    return true;
}

template <class T>
std::optional<T> UnwrapArchive(ArchiveResult<T> result, std::string_view op, int& failures) {
    if (!result.Succeeded()) {
        std::cerr << "FAIL: " << op << ": " << result.Error().message << '\n';
        ++failures;
        return std::nullopt;
    }
    return std::move(result).Value();
}

bool UnwrapArchiveVoid(ArchiveResult<void> result, std::string_view op, int& failures) {
    if (!result.Succeeded()) {
        std::cerr << "FAIL: " << op << ": " << result.Error().message << '\n';
        ++failures;
        return false;
    }
    return true;
}

template <class T>
std::optional<T> UnwrapIo(IoResult<T> result, std::string_view op, int& failures) {
    if (!result.Succeeded()) {
        std::cerr << "FAIL: " << op << ": " << result.Error().message << '\n';
        ++failures;
        return std::nullopt;
    }
    return std::move(result).Value();
}

Bytes MakePayload(std::size_t size) {
    Bytes data(size);
    std::uint32_t state = 0x12345678u;
    for (auto& b : data) {
        state = state * 1664525u + 1013904223u;
        b = static_cast<std::byte>((state >> 24) ^ (state >> 16));
    }
    return data;
}

} // namespace

int main() {
    int failures = 0;

    const auto stamp = std::chrono::steady_clock::now().time_since_epoch().count();
    const auto rand_val = std::random_device{}();
    const std::filesystem::path temp_path =
        std::filesystem::temp_directory_path() /
        ("huxerui-archive-module-smoke-" + std::to_string(stamp) + "-" + std::to_string(rand_val));
    std::error_code ec;
    if (!std::filesystem::create_directories(temp_path, ec) || ec) {
        std::cerr << "FAIL: could not create temp directory: " << ec.message() << '\n';
        return 1;
    }
    TempDirGuard guard{temp_path};

    const File root(temp_path.string());
    const File src_dir(root, "src");
    const File empty_sub(src_dir, "empty");
    const File payload_file(src_dir, "payload.bin");
    const File unpack_root(root, "unpack");
    Check(src_dir.CreateDirectory(), "create src_dir", failures);
    Check(empty_sub.CreateDirectory(), "create empty_sub", failures);
    Check(unpack_root.CreateDirectory(), "create unpack_root", failures);

    const Bytes payload = MakePayload(128 * 1024 + 37);
    Check(payload_file.WriteBytes(payload), "write payload file", failures);

    // 1. Out-of-line gzip & zstd stream compression + decompression round-trip.
    for (const CompressionFormat fmt : {CompressionFormat::Gzip, CompressionFormat::Zstd}) {
        const std::string tag = (fmt == CompressionFormat::Gzip) ? "gzip" : "zstd";
        const File compressed(root, "stream." + tag);
        const File restored(root, "restored." + tag);

        auto in_plain = UnwrapIo(payload_file.OpenRead(), tag + " OpenRead plain", failures);
        auto out_comp = UnwrapIo(compressed.OpenWrite(), tag + " OpenWrite compressed", failures);
        if (in_plain && out_comp) {
            auto comp_bytes = UnwrapArchive(
                CompressStream(std::move(*in_plain), std::move(*out_comp), fmt),
                tag + " CompressStream",
                failures
            );
            Check(comp_bytes.has_value() && *comp_bytes > 0, tag + " compressed size > 0", failures);
        }

        auto in_comp = UnwrapIo(compressed.OpenRead(), tag + " OpenRead compressed", failures);
        auto out_rest = UnwrapIo(restored.OpenWrite(), tag + " OpenWrite restored", failures);
        if (in_comp && out_rest) {
            auto decomp_bytes = UnwrapArchive(
                DecompressStream(std::move(*in_comp), std::move(*out_rest), fmt),
                tag + " DecompressStream",
                failures
            );
            Check(decomp_bytes.has_value() && *decomp_bytes == payload.size(),
                  tag + " decompressed size == payload size", failures);
        }

        if (auto actual = UnwrapIo(restored.ReadBytes(), tag + " ReadBytes restored", failures)) {
            Check(*actual == payload, tag + " byte round-trip equality", failures);
        }

        // Verify truncated stream error reporting.
        if (auto comp_raw = UnwrapIo(compressed.ReadBytes(), tag + " ReadBytes compressed", failures)) {
            if (Check(!comp_raw->empty(), tag + " compressed non-empty", failures)) {
                Bytes truncated = *comp_raw;
                truncated.pop_back();
                const File trunc_file(root, "trunc." + tag);
                const File trunc_out(root, "trunc_out." + tag);
                Check(trunc_file.WriteBytes(truncated), tag + " write truncated", failures);
                auto in_trunc = UnwrapIo(trunc_file.OpenRead(), tag + " OpenRead trunc", failures);
                auto out_trunc = UnwrapIo(trunc_out.OpenWrite(), tag + " OpenWrite trunc", failures);
                if (in_trunc && out_trunc) {
                    auto bad = DecompressStream(std::move(*in_trunc), std::move(*out_trunc), fmt);
                    Check(!bad.Succeeded() && bad.Error().code == ArchiveErrorCode::InvalidData,
                          tag + " truncated stream returns InvalidData", failures);
                }
            }
        }
    }

    // 2. Out-of-line ArchiveWriter + ArchiveReader round-trip across ZIP, TAR, TAR.GZ, TAR.ZST.
    const std::array<ArchiveFormat, 4> formats{
        ArchiveFormat::Zip,
        ArchiveFormat::Tar,
        ArchiveFormat::TarGzip,
        ArchiveFormat::TarZstd,
    };
    for (std::size_t i = 0; i < formats.size(); ++i) {
        const std::string idx = std::to_string(i);
        const File archive_file(root, "test-" + idx + ".arc");
        const std::string mem_entry = "meta/hello.txt";
        const std::string_view mem_text = "Hello from huxerui.archive module!\n";
        const Bytes mem_bytes(
            reinterpret_cast<const std::byte*>(mem_text.data()),
            reinterpret_cast<const std::byte*>(mem_text.data() + mem_text.size())
        );

        auto writer_opt = UnwrapArchive(ArchiveWriter::Create(archive_file, formats[i]), "ArchiveWriter::Create", failures);
        if (writer_opt) {
            UnwrapArchiveVoid(writer_opt->AddEntry(mem_entry, mem_bytes), "AddEntry mem", failures);
            UnwrapArchiveVoid(writer_opt->AddEntry("data/blob.bin", payload), "AddEntry blob", failures);
            UnwrapArchiveVoid(writer_opt->AddDirectory("explicit-dir/"), "AddDirectory", failures);
            UnwrapArchiveVoid(writer_opt->AddPath("tree", src_dir), "AddPath", failures);
            UnwrapArchiveVoid(writer_opt->Finish(), "Finish", failures);
        }

        auto reader_opt = UnwrapArchive(ArchiveReader::Open(archive_file), "ArchiveReader::Open", failures);
        if (reader_opt) {
            auto entries_opt = UnwrapArchive(reader_opt->ListEntries(), "ListEntries", failures);
            Check(entries_opt.has_value() && entries_opt->size() == 6, "ListEntries count == 6", failures);

            auto read_mem = UnwrapArchive(reader_opt->ReadEntry(mem_entry), "ReadEntry mem", failures);
            Check(read_mem.has_value() && *read_mem == mem_bytes, "ReadEntry mem byte equality", failures);

            auto read_blob = UnwrapArchive(reader_opt->ReadEntry("data/blob.bin"), "ReadEntry blob", failures);
            Check(read_blob.has_value() && *read_blob == payload, "ReadEntry blob byte equality", failures);

            const File single_out(root, "single-" + idx + ".bin");
            UnwrapArchiveVoid(reader_opt->ExtractEntry("tree/payload.bin", single_out), "ExtractEntry", failures);
            if (auto single_bytes = UnwrapIo(single_out.ReadBytes(), "ReadBytes single", failures)) {
                Check(*single_bytes == payload, "ExtractEntry byte equality", failures);
            }

            const File full_out(unpack_root, idx);
            Check(full_out.CreateDirectory(), "create full_out", failures);
            UnwrapArchiveVoid(reader_opt->ExtractAll(full_out), "ExtractAll", failures);
            Check(File(File(full_out, "tree"), "empty").IsDirectory(), "ExtractAll empty subdir", failures);
            if (auto full_bytes = UnwrapIo(File(File(full_out, "tree"), "payload.bin").ReadBytes(), "ReadBytes full", failures)) {
                Check(*full_bytes == payload, "ExtractAll byte equality", failures);
            }
        }
    }

    // 3. CreateArchive / ExtractArchive high-level helpers round-trip.
    const File helper_zip(root, "helper.zip");
    const File helper_out(unpack_root, "helper");
    Check(helper_out.CreateDirectory(), "create helper_out", failures);
    UnwrapArchiveVoid(CreateArchive(src_dir, helper_zip), "CreateArchive ZIP", failures);
    UnwrapArchiveVoid(ExtractArchive(helper_zip, helper_out), "ExtractArchive ZIP", failures);
    const File helper_payload(File(helper_out, "src"), "payload.bin");
    if (auto helper_bytes = UnwrapIo(helper_payload.ReadBytes(), "ReadBytes helper", failures)) {
        Check(*helper_bytes == payload, "CreateArchive/ExtractArchive byte equality", failures);
    }

    const bool ok = (failures == 0);
    std::cout << "archive module_smoke: " << (ok ? "ok" : "FAILED") << '\n';
    return ok ? 0 : 1;
}
