// Surface/smoke coverage: exported types, completion tokens, and vocabulary
// types are usable across the module boundary.
import std;
import asio;

int main() {
    // --- buffer / address (existing) ---
    std::array<char, 4> src{'m', 'c', 'p', 'p'};
    asio::const_buffer cb = asio::buffer(src);
    if (cb.size() != 4) return 1;

    std::string dst(4, '\0');
    asio::mutable_buffer mb = asio::buffer(dst);
    std::memcpy(mb.data(), cb.data(), cb.size());
    if (dst != "mcpp") return 2;

    asio::ip::address_v4 loopback = asio::ip::address_v4::loopback();
    if (loopback.to_string() != "127.0.0.1") return 3;

    asio::ip::tcp::endpoint ep(loopback, 8080);
    if (ep.port() != 8080) return 4;

    // --- execution context hierarchy ---
    if (!std::is_base_of_v<asio::execution_context, asio::io_context>) return 5;
    if (!std::is_base_of_v<asio::execution_context, asio::system_context>) return 6;
    if (!std::is_base_of_v<asio::execution_context, asio::thread_pool>) return 7;

    // --- executors ---
    static_assert(std::is_class_v<asio::any_io_executor>);
    static_assert(std::is_class_v<asio::system_executor>);

    // --- error_code typedef ---
    static_assert(std::is_same_v<asio::error_code, std::error_code>);

    // --- cancellation_type (scoped enum) ---
    static_assert(std::is_enum_v<asio::cancellation_type>);
    if (static_cast<int>(asio::cancellation_type::all) == 0) return 8;
    if (static_cast<int>(asio::cancellation_type::terminal) == 0) return 9;

    // --- signal / timer types ---
    static_assert(std::is_class_v<asio::signal_set>);
    static_assert(std::is_class_v<asio::system_timer>);

    // --- completion token variables ---
    asio::io_context surface_io;
    // detached — compile test for the constexpr variable and its usage
    asio::steady_timer t(surface_io, std::chrono::milliseconds(0));
    t.async_wait(asio::detached);
    static_assert(std::is_same_v<decltype(asio::detached), const asio::detached_t>);

    // use_future — accessible as a named variable
    auto uf = asio::use_future;
    (void)uf;

    // deferred
    static_assert(std::is_same_v<decltype(asio::deferred), const asio::deferred_t>);

    // --- redirect_error ---
    std::error_code redirect_ec;
    auto redirected = asio::redirect_error(redirect_ec);
    (void)redirected;

    // --- bind_executor ---
    auto bound = asio::bind_executor(asio::system_executor(), []{});
    (void)bound;

    // --- associated traits ---
    static_assert(std::is_class_v<asio::associated_allocator<int>>);
    static_assert(std::is_class_v<asio::associated_executor<int>>);
    static_assert(std::is_class_v<asio::associated_cancellation_slot<int>>);

    // --- error namespace ---
    if (asio::error::operation_aborted == std::error_code{}) return 10;

    return 0;
}
