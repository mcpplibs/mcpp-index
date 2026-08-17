// Behavioral test: the digests themselves, against upstream's own vectors.
//
// A hash package that links but computes a different value is worse than one
// that does not link at all — every caller downstream is content-addressing
// something. So the assertions here are known-answer tests taken verbatim from
// xxHash's `tests/sanity_test_vectors.h`, together with the buffer generator
// from `tests/sanity_test.c` that those vectors were computed over. Nothing is
// derived from running the code under test.
//
// The lengths cover every size branch XXH3 switches on (0, 1-3, 4-8, 9-16,
// 17-128, 129-240, >240) plus the multi-block path at 2048 and 4160, which is
// where a mis-selected SIMD variant or a byte-order slip would show up.
#include <xxhash.h>

#include <cassert>
#include <cstddef>
#include <cstdint>
#include <vector>

namespace {

// tests/sanity_test.c: fillTestBuffer(). "Its values must not be changed."
constexpr std::uint32_t kPrime32 = 2654435761U;
constexpr std::uint64_t kPrime64 = 11400714785074694797ULL;

std::vector<unsigned char> make_sanity_buffer(std::size_t len) {
    std::vector<unsigned char> buf(len);
    std::uint64_t gen = kPrime32;
    for (std::size_t i = 0; i < len; ++i) {
        buf[i] = static_cast<unsigned char>(gen >> 56);
        gen *= kPrime64;
    }
    return buf;
}

struct Case32 { std::uint32_t len; std::uint32_t seed; std::uint32_t expected; };
struct Case64 { std::uint32_t len; std::uint64_t seed; std::uint64_t expected; };
struct Case128 { std::uint32_t len; std::uint64_t lo; std::uint64_t hi; };

// XSUM_XXH32_testdata, seed 0.
constexpr Case32 kXXH32[] = {
    {    0, 0x00000000U, 0x02CC5D05U }, {    1, 0x00000000U, 0xCF65B03EU },
    {    2, 0x00000000U, 0x1151BEE4U }, {    3, 0x00000000U, 0xC23884F5U },
    {    4, 0x00000000U, 0xA9DE7CE9U }, {    8, 0x00000000U, 0xA3F6F44BU },
    {    9, 0x00000000U, 0xFFB82A24U }, {   16, 0x00000000U, 0x93BA3759U },
    {   17, 0x00000000U, 0x89FDC23EU }, {   64, 0x00000000U, 0x02E95DBBU },
    {  128, 0x00000000U, 0x0FD07B71U }, {  129, 0x00000000U, 0x68C9EC37U },
    {  222, 0x00000000U, 0x5BD11DBDU }, {  240, 0x00000000U, 0xFA6B6557U },
    {  241, 0x00000000U, 0xE5F7C54DU }, {  403, 0x00000000U, 0x6675FF5AU },
    {  512, 0x00000000U, 0xD485C30AU }, { 2048, 0x00000000U, 0x7C535464U },
    { 4160, 0x00000000U, 0xDB0D9141U },
};

// XSUM_XXH64_testdata, seed 0.
constexpr Case64 kXXH64[] = {
    {    0, 0ULL, 0xEF46DB3751D8E999ULL }, {    1, 0ULL, 0xE934A84ADB052768ULL },
    {    2, 0ULL, 0x5D48CD60A77E23FFULL }, {    3, 0ULL, 0xFF7E1959CB50794AULL },
    {    4, 0ULL, 0x9136A0DCA57457EEULL }, {    8, 0ULL, 0xCDBCF538E71D1348ULL },
    {    9, 0ULL, 0x554B1AE991EDA6B6ULL }, {   16, 0ULL, 0x98C90B57FDFCB55CULL },
    {   17, 0ULL, 0x0D39A2D051A30C2CULL }, {   64, 0ULL, 0xEF558F8ACAC2B5CDULL },
    {  128, 0ULL, 0x90CA021457D96DC5ULL }, {  129, 0ULL, 0x41C280132D697ABAULL },
    {  222, 0ULL, 0xB641AE8CB691C174ULL }, {  240, 0ULL, 0xB81838D483BAEE53ULL },
    {  241, 0ULL, 0x95D76C8B4D8FC4D6ULL }, {  403, 0ULL, 0xD99858FEE82283DFULL },
    {  512, 0ULL, 0x4358D2FDD62B58A7ULL }, { 2048, 0ULL, 0x5940F2752BC04387ULL },
    { 4160, 0ULL, 0xEEE6A4E2AC952A5EULL },
};

// XSUM_XXH3_testdata, seed 0 and seed PRIME64 — the seeded path is a different
// branch in XXH3, not a reseeding of the same one.
constexpr Case64 kXXH3[] = {
    {    0, 0ULL, 0x2D06800538D394C2ULL }, {    1, 0ULL, 0xC44BDFF4074EECDBULL },
    {    2, 0ULL, 0x7A9978044CB8A8BBULL }, {    3, 0ULL, 0x54247382A8D6B94DULL },
    {    4, 0ULL, 0xE5DC74BC51848A51ULL }, {    8, 0ULL, 0x24CCC9ACAA9F65E4ULL },
    {    9, 0ULL, 0x14D5001C15DD3F2BULL }, {   16, 0ULL, 0x981B17D36C7498C9ULL },
    {   17, 0ULL, 0x796F5ACD3A60F862ULL }, {   64, 0ULL, 0x9CB48487720EC49DULL },
    {  128, 0ULL, 0xFCFF24126754D861ULL }, {  129, 0ULL, 0x98F1B0A679A2CA29ULL },
    {  222, 0ULL, 0xB9163B558664D356ULL }, {  240, 0ULL, 0x81C3C2B67F568CCFULL },
    {  241, 0ULL, 0xC5A639ECD2030E5EULL }, {  403, 0ULL, 0xCDEB804D65C6DEA4ULL },
    {  512, 0ULL, 0x617E49599013CB6BULL }, { 2048, 0ULL, 0xDD59E2C3A5F038E0ULL },
    { 4160, 0ULL, 0x4F323B15321E94E1ULL },
};

constexpr Case64 kXXH3Seeded[] = {
    {    0, 0x9E3779B185EBCA8DULL, 0xA8A6B918B2F0364AULL },
    {    1, 0x9E3779B185EBCA8DULL, 0x032BE332DD766EF8ULL },
    {   16, 0x9E3779B185EBCA8DULL, 0x663F29333B4DB6B1ULL },
    {  129, 0x9E3779B185EBCA8DULL, 0x21FFFDBCA099C844ULL },
    {  241, 0x9E3779B185EBCA8DULL, 0xDDA9B0A161D4829AULL },
    { 4160, 0x9E3779B185EBCA8DULL, 0x1BF6F5FAF9EECABDULL },
};

// XSUM_XXH128_testdata, seed 0.
constexpr Case128 kXXH128[] = {
    {    0, 0x6001C324468D497FULL, 0x99AA06D3014798D8ULL },
    {    1, 0xC44BDFF4074EECDBULL, 0xA6CD5E9392000F6AULL },
    {   16, 0x562980258A998629ULL, 0xC68C368ECF8A9C05ULL },
    {  129, 0x86C9E3BC8F0A3B5CULL, 0x03815FC91F1B30B6ULL },
    {  241, 0xC5A639ECD2030E5EULL, 0x99A80ECF0ECFC647ULL },
    { 4160, 0x4F323B15321E94E1ULL, 0x67140711C1E3E335ULL },
};

}  // namespace

int main() {
    for (const auto& c : kXXH32) {
        const auto buf = make_sanity_buffer(c.len);
        assert(XXH32(buf.data(), c.len, c.seed) == c.expected);
    }
    for (const auto& c : kXXH64) {
        const auto buf = make_sanity_buffer(c.len);
        assert(XXH64(buf.data(), c.len, c.seed) == c.expected);
    }
    for (const auto& c : kXXH3) {
        const auto buf = make_sanity_buffer(c.len);
        assert(XXH3_64bits(buf.data(), c.len) == c.expected);
    }
    for (const auto& c : kXXH3Seeded) {
        const auto buf = make_sanity_buffer(c.len);
        assert(XXH3_64bits_withSeed(buf.data(), c.len, c.seed) == c.expected);
    }
    for (const auto& c : kXXH128) {
        const auto buf = make_sanity_buffer(c.len);
        const XXH128_hash_t h = XXH3_128bits(buf.data(), c.len);
        assert(h.low64 == c.lo && h.high64 == c.hi);
    }

    // --- streaming must agree with the one-shot form ---
    // Split at 3 bytes, which is neither the 16-byte stripe nor the 256-byte
    // block, so the internal buffering path is actually exercised.
    {
        const auto buf = make_sanity_buffer(4160);
        XXH64_state_t* st = XXH64_createState();
        assert(st != nullptr);
        assert(XXH64_reset(st, 0) == XXH_OK);
        assert(XXH64_update(st, buf.data(), 3) == XXH_OK);
        assert(XXH64_update(st, buf.data() + 3, buf.size() - 3) == XXH_OK);
        assert(XXH64_digest(st) == 0xEEE6A4E2AC952A5EULL);
        assert(XXH64_freeState(st) == XXH_OK);

        XXH3_state_t* s3 = XXH3_createState();
        assert(s3 != nullptr);
        assert(XXH3_64bits_reset(s3) == XXH_OK);
        assert(XXH3_64bits_update(s3, buf.data(), 3) == XXH_OK);
        assert(XXH3_64bits_update(s3, buf.data() + 3, buf.size() - 3) == XXH_OK);
        assert(XXH3_64bits_digest(s3) == 0x4F323B15321E94E1ULL);
        assert(XXH3_freeState(s3) == XXH_OK);
    }

    // --- the canonical (big-endian) serialization round-trips ---
    {
        const auto buf = make_sanity_buffer(512);
        const std::uint64_t h64 = XXH64(buf.data(), buf.size(), 0);
        XXH64_canonical_t c64;
        XXH64_canonicalFromHash(&c64, h64);
        assert(c64.digest[0] == static_cast<unsigned char>(h64 >> 56));  // big-endian, always
        assert(XXH64_hashFromCanonical(&c64) == h64);

        const XXH128_hash_t h128 = XXH3_128bits(buf.data(), buf.size());
        XXH128_canonical_t c128;
        XXH128_canonicalFromHash(&c128, h128);
        const XXH128_hash_t back = XXH128_hashFromCanonical(&c128);
        assert(back.low64 == h128.low64 && back.high64 == h128.high64);
    }

    // --- a single flipped bit must change the digest ---
    {
        auto buf = make_sanity_buffer(4160);
        const std::uint64_t before = XXH3_64bits(buf.data(), buf.size());
        buf[buf.size() / 2] ^= 0x01;
        assert(XXH3_64bits(buf.data(), buf.size()) != before);
    }

    return 0;
}
