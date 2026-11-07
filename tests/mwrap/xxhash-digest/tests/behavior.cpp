// The installed xxHash wrapper: the published hashes of the empty input,
// streaming equal to one call, and the canonical form.
import std;
import mcpplibs.mwrap.xxhash;

namespace h = mcpplibs::mwrap::xxhash::macros;

int main() {
    if (XXH32(nullptr, 0, 0) != 0x02CC5D05u || XXH64(nullptr, 0, 0) != 0xEF46DB3751D8E999ull
        || XXH3_64bits(nullptr, 0) != 0x2D06800538D394C2ull) return 1;
    std::string text;
    for (int i = 0; i < 400; ++i) text += std::format("{},", i * 31);
    XXH3_state_t* s = XXH3_createState();
    XXH3_64bits_reset(s);
    for (std::size_t at = 0; at < text.size(); at += 37)
        XXH3_64bits_update(s, text.data() + at, std::min<std::size_t>(37, text.size() - at));
    const bool same = XXH3_64bits_digest(s) == XXH3_64bits(text.data(), text.size());
    XXH3_freeState(s);
    XXH64_canonical_t canonical;
    XXH64_canonicalFromHash(&canonical, 0x0102030405060708ull);
    if (!same || canonical.digest[0] != 1 || XXH64_hashFromCanonical(&canonical) != 0x0102030405060708ull) return 2;
    std::println("xxHash {}", XXH_versionNumber());
    return XXH_versionNumber() == h::XXH_VERSION_NUMBER ? 0 : 3;
}
