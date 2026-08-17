// The error surface: the four Asio error enums and their enumerators reach a
// module consumer, and each one compares equal to the std::error_code that
// asio::error::make_error_code builds from it.
//
// Before this was exported the module offered exactly one condition,
// operation_aborted, which is enough to notice a cancellation and nothing else:
// telling a refused connection from a DNS failure had no name to compare
// against on the consumer's side.
import std;
import asio;

int main() {
    // --- the enum types themselves ---
    static_assert(std::is_enum_v<asio::error::basic_errors>);
    static_assert(std::is_enum_v<asio::error::netdb_errors>);
    static_assert(std::is_enum_v<asio::error::addrinfo_errors>);
    static_assert(std::is_enum_v<asio::error::misc_errors>);

    // --- enumerators, one per enum, round-tripped through make_error_code ---
    const std::error_code aborted   = asio::error::make_error_code(asio::error::operation_aborted);
    const std::error_code refused   = asio::error::make_error_code(asio::error::connection_refused);
    const std::error_code timedout  = asio::error::make_error_code(asio::error::timed_out);
    const std::error_code unreach   = asio::error::make_error_code(asio::error::host_unreachable);
    const std::error_code netdown   = asio::error::make_error_code(asio::error::network_unreachable);
    const std::error_code nohost    = asio::error::make_error_code(asio::error::host_not_found);
    const std::error_code retryhost = asio::error::make_error_code(asio::error::host_not_found_try_again);
    const std::error_code nosvc     = asio::error::make_error_code(asio::error::service_not_found);
    const std::error_code eof       = asio::error::make_error_code(asio::error::eof);

    // An error_code built from an enumerator compares equal to that enumerator:
    // this is the comparison real code writes (`if (ec == asio::error::eof)`),
    // and it only works if the enumerator NAME crossed the module boundary.
    if (aborted   != asio::error::operation_aborted)          return 1;
    if (refused   != asio::error::connection_refused)         return 2;
    if (timedout  != asio::error::timed_out)                  return 3;
    if (unreach   != asio::error::host_unreachable)           return 4;
    if (netdown   != asio::error::network_unreachable)        return 5;
    if (nohost    != asio::error::host_not_found)             return 6;
    if (retryhost != asio::error::host_not_found_try_again)   return 7;
    if (nosvc     != asio::error::service_not_found)          return 8;
    if (eof       != asio::error::eof)                        return 9;

    // Distinct conditions must not collapse into each other.
    if (refused == timedout || nohost == retryhost)           return 10;

    // Every one of them is a real, non-empty condition.
    for (const auto& ec : {aborted, refused, timedout, unreach, netdown,
                           nohost, retryhost, nosvc, eof}) {
        if (!ec)                    return 11;
        if (ec.message().empty())   return 12;
    }

    // --- ip::make_address parses, and reports failure through error_code ---
    std::error_code parse;
    const auto v4 = asio::ip::make_address("192.0.2.7", parse);
    if (parse || !v4.is_v4() || v4.to_string() != "192.0.2.7") return 13;

    const auto v6 = asio::ip::make_address("::1", parse);
    if (parse || !v6.is_v6() || !v6.is_loopback())             return 14;

    (void)asio::ip::make_address("not-an-address", parse);
    if (!parse)                                                 return 15;

    if (asio::ip::make_address_v4("10.0.0.1", parse).to_string() != "10.0.0.1" || parse) return 16;
    if (!asio::ip::make_address_v6("::1", parse).is_loopback() || parse)                 return 17;

    return 0;
}
