// Asio's file I/O over the module surface: asio::stream_file writes and reads
// back through a coroutine, asio::random_access_file reads at an offset, and
// asio::file_base's open flags compose.
//
// These names are exported only where Asio has a file backend. For THIS
// package's configuration the condition is exactly Windows: the backend is IOCP
// (ASIO_HAS_WINDOWS_RANDOM_ACCESS_HANDLE), and the only other one Asio offers is
// io_uring, which this package does not enable. `ASIO_HAS_FILE` itself is
// unusable as the discriminator here — a macro does not cross a module boundary
// and a module consumer includes no Asio header, so it is always false in this
// TU no matter what the package was built with.
import std;
import asio;

#if defined(_WIN32)

int main() {
    namespace fs = std::filesystem;

    const auto path = (fs::temp_directory_path() / "mcpp_asio_module_file.bin").string();
    std::error_code rm;
    fs::remove(path, rm);

    constexpr std::string_view payload = "mcpp-asio-file";

    asio::io_context io;
    int failure = 0;

    asio::co_spawn(io, [&]() -> asio::awaitable<void> {
        // --- write through stream_file, composing three file_base flags ---
        {
            asio::stream_file out(co_await asio::this_coro::executor, path,
                                  asio::file_base::write_only
                                      | asio::file_base::create
                                      | asio::file_base::truncate);
            const auto written =
                co_await asio::async_write(out, asio::buffer(payload), asio::use_awaitable);
            if (written != payload.size()) { failure = 1; co_return; }
            out.close();
        }

        // --- read it back through stream_file ---
        {
            asio::stream_file in(co_await asio::this_coro::executor, path,
                                 asio::file_base::read_only);
            std::string got(payload.size(), '\0');
            const auto read =
                co_await asio::async_read(in, asio::buffer(got), asio::use_awaitable);
            if (read != payload.size() || got != payload) { failure = 2; co_return; }
        }

        // --- random_access_file reads at an offset, leaving no file position ---
        {
            asio::random_access_file ra(co_await asio::this_coro::executor, path,
                                        asio::file_base::read_only);
            std::string tail(5, '\0');   // "-file", offset 9
            const auto read = co_await ra.async_read_some_at(9, asio::buffer(tail),
                                                             asio::use_awaitable);
            if (read != 5 || tail != "-file") { failure = 3; co_return; }
        }
    }, asio::detached);

    io.run();
    fs::remove(path, rm);

    // The aliases are the basic_ templates with the default executor.
    static_assert(std::is_same_v<asio::stream_file, asio::basic_stream_file<>>);
    static_assert(std::is_same_v<asio::random_access_file,
                                 asio::basic_random_access_file<>>);
    static_assert(std::is_base_of_v<asio::file_base, asio::stream_file>);

    return failure;
}

#else

int main() {
    // No file backend in this configuration: asserting the names are absent is
    // not something a TU can do, so this leg only records that the test ran.
    std::println("asio module: file I/O not available in this configuration");
    return 0;
}

#endif
