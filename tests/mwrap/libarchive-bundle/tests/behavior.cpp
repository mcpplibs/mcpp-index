// The installed libarchive wrapper: archives written to memory in three formats
// and read back with their formats detected, and an entry's metadata.
import std;
import mcpplibs.mwrap.libarchive;

namespace la = mcpplibs::mwrap::libarchive::macros;

static std::string write(const char* format, const char* filter, const std::string& data) {
    std::string out(1 << 18, '\0');
    std::size_t used = 0;
    archive* a = archive_write_new();
    archive_write_set_format_by_name(a, format);
    if (filter) archive_write_add_filter_by_name(a, filter);
    archive_write_open_memory(a, out.data(), out.size(), &used);
    archive_entry* e = archive_entry_new();
    archive_entry_set_pathname(e, "dir/file.txt");
    archive_entry_set_filetype(e, la::AE_IFREG);
    archive_entry_set_perm(e, 0640);
    archive_entry_set_size(e, static_cast<la_int64_t>(data.size()));
    archive_write_header(a, e);
    archive_write_data(a, data.data(), data.size());
    archive_entry_free(e);
    archive_write_free(a);
    out.resize(used);
    return out;
}

int main() {
    const std::string data(3000, 'a');
    for (auto [format, filter, expected] : {std::tuple{"ustar", "gzip", "POSIX ustar format"},
                                            std::tuple{"zip", static_cast<const char*>(nullptr), "ZIP"},
                                            std::tuple{"7zip", static_cast<const char*>(nullptr), "7-Zip"}}) {
        const std::string bytes = write(format, filter, data);
        archive* a = archive_read_new();
        archive_read_support_filter_all(a);
        archive_read_support_format_all(a);
        archive_entry* e;
        if (archive_read_open_memory(a, bytes.data(), bytes.size()) != la::ARCHIVE_OK
            || archive_read_next_header(a, &e) != la::ARCHIVE_OK) return 1;
        std::string back(static_cast<std::size_t>(archive_entry_size(e)), '\0');
        archive_read_data(a, back.data(), back.size());
        const bool ok = back == data && std::string_view(archive_entry_pathname(e)) == "dir/file.txt"
            && (archive_entry_perm(e) & 0777) == 0640 && std::string_view(archive_format_name(a)).starts_with(expected);
        std::println("{}: {} bytes, {}", format, bytes.size(), archive_format_name(a));
        archive_read_free(a);
        if (!ok) return 2;
    }
    return archive_version_number() == la::ARCHIVE_VERSION_NUMBER ? 0 : 3;
}
