import std;
import tf;

bool taskflow_utility_ok() {
    return std::string_view(tf::version()) == "4.1.0"
        && tf::next_pow2(std::uint64_t{17}) == 32;
}
