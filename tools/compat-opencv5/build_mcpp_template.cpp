// build.mcpp for compat.opencv5 — consumer-side synthesis of OpenCV's
// build-time generated files from the frozen config snapshot. Embedded into
// pkgs/c/compat.opencv5.lua by tools/compat-opencv5/gen_descriptor.py.
//
// What it does (all pure transforms of files already in the pinned tarball —
// nothing is downloaded, nothing depends on the host):
//   1. blob2hdr  — modules/imgproc/fonts/*.ttf.gz → builtin_font_{sans,italic}.h
//                  (hex byte arrays; faithful port of cmake ocv_blob2hdr)
//   2. cl2cpp    — modules/<m>/src/opencl/*.cl → opencl_kernels_<m>.{cpp,hpp}
//                  (comment-strip + string-escape + md5; faithful port of
//                  cmake/cl2cpp.cmake; content is #ifdef HAVE_OPENCL-guarded
//                  and inert in this profile, kept byte-faithful anyway)
//   3. tu stubs  — one uniquely-named forwarding TU per source, driven by
//                  mcpp_generated/tu_manifest.txt. Works around mcpp#233
//                  (object paths fold to <parent-dir>/<basename> — OpenCV's
//                  modules/*/src/ layout collides), absorbs the
//                  libjpeg-turbo BITS_IN_JSAMPLE=12/16 same-source
//                  re-compiles, and carries defines whose values contain
//                  spaces (mcpp#234) as #define preludes.
// The raw `mcpp:` stdout protocol is used (no `import mcpp;`) so this file
// has zero non-standard dependencies.
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

namespace fs = std::filesystem;

// ── tiny MD5 (RFC 1321, public-domain style condensed implementation) ────
namespace md5impl {
struct MD5 {
    uint32_t a0 = 0x67452301, b0 = 0xefcdab89, c0 = 0x98badcfe, d0 = 0x10325476;
    static const uint32_t K[64];
    static const uint32_t R[64];
    void block(const uint8_t* p) {
        uint32_t M[16];
        for (int i = 0; i < 16; i++)
            M[i] = (uint32_t)p[i*4] | ((uint32_t)p[i*4+1] << 8) | ((uint32_t)p[i*4+2] << 16) | ((uint32_t)p[i*4+3] << 24);
        uint32_t A = a0, B = b0, C = c0, D = d0;
        for (int i = 0; i < 64; i++) {
            uint32_t F; int g;
            if (i < 16)      { F = (B & C) | (~B & D);        g = i; }
            else if (i < 32) { F = (D & B) | (~D & C);        g = (5*i + 1) % 16; }
            else if (i < 48) { F = B ^ C ^ D;                 g = (3*i + 5) % 16; }
            else             { F = C ^ (B | ~D);              g = (7*i) % 16; }
            F = F + A + K[i] + M[g];
            A = D; D = C; C = B;
            B = B + ((F << R[i]) | (F >> (32 - R[i])));
        }
        a0 += A; b0 += B; c0 += C; d0 += D;
    }
    static std::string hex(const std::string& data) {
        MD5 m;
        uint64_t bits = (uint64_t)data.size() * 8;
        std::string buf = data;
        buf.push_back((char)0x80);
        while (buf.size() % 64 != 56) buf.push_back('\0');
        for (int i = 0; i < 8; i++) buf.push_back((char)((bits >> (8*i)) & 0xff));
        for (size_t o = 0; o < buf.size(); o += 64) m.block((const uint8_t*)buf.data() + o);
        char out[33];
        uint32_t w[4] = { m.a0, m.b0, m.c0, m.d0 };
        for (int i = 0; i < 16; i++)
            std::snprintf(out + 2*i, 3, "%02x", (w[i/4] >> (8*(i%4))) & 0xff);
        return std::string(out, 32);
    }
};
const uint32_t MD5::K[64] = {
    0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,0xf57c0faf,0x4787c62a,0xa8304613,0xfd469501,
    0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,0x6b901122,0xfd987193,0xa679438e,0x49b40821,
    0xf61e2562,0xc040b340,0x265e5a51,0xe9b6c7aa,0xd62f105d,0x02441453,0xd8a1e681,0xe7d3fbc8,
    0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,0xa9e3e905,0xfcefa3f8,0x676f02d9,0x8d2a4c8a,
    0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,
    0x289b7ec6,0xeaa127fa,0xd4ef3085,0x04881d05,0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,
    0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,0x655b59c3,0x8f0ccc92,0xffeff47d,0x85845dd1,
    0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391 };
const uint32_t MD5::R[64] = {
    7,12,17,22,7,12,17,22,7,12,17,22,7,12,17,22, 5,9,14,20,5,9,14,20,5,9,14,20,5,9,14,20,
    4,11,16,23,4,11,16,23,4,11,16,23,4,11,16,23, 6,10,15,21,6,10,15,21,6,10,15,21,6,10,15,21 };
} // namespace md5impl

static std::string slurp(const fs::path& p) {
    std::ifstream f(p, std::ios::binary);
    if (!f) { std::fprintf(stderr, "compat.opencv5 build.mcpp: cannot read %s\n", p.string().c_str()); std::exit(1); }
    std::ostringstream ss; ss << f.rdbuf(); return ss.str();
}
static void spew(const fs::path& p, const std::string& content) {
    fs::create_directories(p.parent_path());
    // only rewrite when changed: keeps ninja restat-friendly timestamps
    if (fs::exists(p)) {
        std::ifstream f(p, std::ios::binary); std::ostringstream ss; ss << f.rdbuf();
        if (ss.str() == content) return;
    }
    std::ofstream f(p, std::ios::binary);
    f << content;
    if (!f) { std::fprintf(stderr, "compat.opencv5 build.mcpp: cannot write %s\n", p.string().c_str()); std::exit(1); }
}

// ── gunzip (raw inflate over the vendored zlib? not available here) ─────
// The .ttf.gz blobs are embedded AS-IS: cmake's ocv_blob2hdr hex-dumps the
// *compressed* file bytes (OpenCV decompresses at runtime via its zlib), so
// no inflate is needed here — just a hex dump.
static void blob2hdr(const fs::path& blob, const fs::path& hdr, const std::string& var) {
    // byte-faithful port of cmake ocv_blob2hdr: 16 bytes per line, ", "
    // separators, the very last ", " trimmed.
    std::string data = slurp(blob);
    std::ostringstream out;
    out << "// Auto generated file.\nstatic const unsigned char " << var << "[] =\n{\n";
    char buf[8];
    for (size_t i = 0; i < data.size(); i++) {
        std::snprintf(buf, sizeof buf, "0x%02x", (unsigned char)data[i]);
        out << buf;
        if (i + 1 != data.size()) out << ", ";
        if (i % 16 == 15 && i + 1 != data.size()) out << "\n";
    }
    out << "\n};\n";
    spew(hdr, out.str());
}

// ── cl2cpp (faithful port of cmake/cl2cpp.cmake) ────────────────────────
static std::string cl_escape(std::string lines) {
    std::string t;
    // \r removal + trailing \n + tabs→2 spaces
    for (char c : lines) if (c != '\r') t.push_back(c);
    t.push_back('\n');
    std::string u;
    for (char c : t) { if (c == '\t') u += "  "; else u.push_back(c); }
    // strip /* */ comments (non-greedy scan)
    std::string v; v.reserve(u.size());
    for (size_t i = 0; i < u.size();) {
        if (i + 1 < u.size() && u[i] == '/' && u[i+1] == '*') {
            size_t e = u.find("*/", i + 2);
            i = (e == std::string::npos) ? u.size() : e + 2;
        } else v.push_back(u[i++]);
    }
    // strip // comments (with leading spaces)
    std::string w; w.reserve(v.size());
    for (size_t i = 0; i < v.size();) {
        if (i + 1 < v.size() && v[i] == '/' && v[i+1] == '/') {
            while (!w.empty() && w.back() == ' ') w.pop_back();
            size_t e = v.find('\n', i);
            i = (e == std::string::npos) ? v.size() : e;   // keep the newline
        } else w.push_back(v[i++]);
    }
    // collapse empty lines + leading whitespace per line
    std::string x; x.reserve(w.size());
    for (size_t i = 0; i < w.size();) {
        if (w[i] == '\n') {
            x.push_back('\n');
            size_t j = i + 1;
            while (j < w.size() && (w[j] == ' ' || w[j] == '\n')) {
                if (w[j] == '\n') { i = j; }
                j++;
            }
            // re-scan: skip spaces directly after newline, and fold newline runs
            size_t k = i + 1;
            while (k < w.size() && w[k] == ' ') k++;
            while (k < w.size() && w[k] == '\n') { k++; i = k - 1;
                while (k < w.size() && w[k] == ' ') k++; }
            i = k;
        } else x.push_back(w[i++]);
    }
    if (!x.empty() && x.front() == '\n') x.erase(0, 1);
    // escape backslash, quote; newline → \n" <newline> "
    std::string y;
    for (char c : x) {
        if (c == '\\') y += "\\\\";
        else if (c == '"') y += "\\\"";
        else if (c == '\n') y += "\\n\"\n\"";
        else y.push_back(c);
    }
    // drop unneeded trailing quote opener
    if (y.size() >= 1 && y.back() == '"') y.pop_back();
    return y;
}

static void cl2cpp(const fs::path& cl_dir, const fs::path& out_cpp, const fs::path& out_hpp,
                   const std::string& module_name) {
    std::vector<fs::path> cls;
    for (auto& e : fs::directory_iterator(cl_dir))
        if (e.path().extension() == ".cl") cls.push_back(e.path());
    std::sort(cls.begin(), cls.end());
    std::string ns = module_name;
    if (!ns.empty() && ns[0] >= '0' && ns[0] <= '9') ns = "_" + ns;
    std::ostringstream cpp, hpp;
    cpp << "// This file is auto-generated. Do not edit!\n\n#include \"opencv2/core.hpp\"\n"
        << "#include \"cvconfig.h\"\n#include \"" << out_hpp.filename().string() << "\"\n\n"
        << "#ifdef HAVE_OPENCL\n\nnamespace cv\n{\nnamespace ocl\n{\nnamespace " << ns
        << "\n{\n\nstatic const char* const moduleName = \"" << module_name << "\";\n\n";
    hpp << "// This file is auto-generated. Do not edit!\n\n#include \"opencv2/core/ocl.hpp\"\n"
        << "#include \"opencv2/core/ocl_genbase.hpp\"\n#include \"opencv2/core/opencl/ocl_defs.hpp\"\n\n"
        << "#ifdef HAVE_OPENCL\n\nnamespace cv\n{\nnamespace ocl\n{\nnamespace " << ns << "\n{\n\n";
    for (auto& cl : cls) {
        std::string name = cl.stem().string();
        std::string body = cl_escape(slurp(cl));
        std::string hash = md5impl::MD5::hex(body);
        cpp << "struct cv::ocl::internal::ProgramEntry " << name << "_oclsrc={moduleName, \"" << name
            << "\",\n\"" << body << ", \"" << hash << "\", NULL};\n";
        hpp << "extern struct cv::ocl::internal::ProgramEntry " << name << "_oclsrc;\n";
    }
    cpp << "\n}}}\n#endif\n";
    hpp << "\n}}}\n#endif\n";
    spew(out_cpp, cpp.str());
    spew(out_hpp, hpp.str());
}

int main() {
    const char* man_env = std::getenv("MCPP_MANIFEST_DIR");
    const char* out_env = std::getenv("MCPP_OUT_DIR");
    fs::path man = man_env ? man_env : ".";
    if (!out_env) { std::fprintf(stderr, "compat.opencv5 build.mcpp: MCPP_OUT_DIR unset (mcpp >= 0.0.95 required)\n"); return 1; }
    fs::path out = out_env;
    fs::path gen = man / "mcpp_generated";

    // the extracted official tarball wrap dir (opencv-<version>/)
    fs::path wrap;
    for (auto& e : fs::directory_iterator(man)) {
        if (e.is_directory() && e.path().filename().string().rfind("opencv-", 0) == 0
            && fs::exists(e.path() / "modules")) { wrap = e.path(); break; }
    }
    if (wrap.empty()) { std::fprintf(stderr, "compat.opencv5 build.mcpp: opencv-* source dir not found under %s\n", man.string().c_str()); return 1; }

    // 1. fonts
    blob2hdr(wrap / "modules/imgproc/fonts/Rubik.ttf.gz",        out / "builtin_font_sans.h",   "OcvBuiltinFontSans");
    blob2hdr(wrap / "modules/imgproc/fonts/Rubik-Italic.ttf.gz", out / "builtin_font_italic.h", "OcvBuiltinFontItalic");

    // 2. OpenCL kernel embeddings (inert under this profile, byte-faithful)
    for (std::string m : { "core", "imgproc", "geometry" }) {
        fs::path cl_dir = wrap / "modules" / m / "src" / "opencl";
        if (fs::exists(cl_dir))
            cl2cpp(cl_dir, out / ("clsrc/opencl_kernels_" + m + ".cpp"),
                   out / ("opencl_kernels_" + m + ".hpp"), m);
    }

    // 3. forwarding TU stubs from the manifest
    //    line grammar:  !prelude<TAB><group><TAB><literal line>       (collect)
    //                   <group><TAB><include-target>                  (emit stub)
    std::map<std::string, std::string> preludes;
    std::ifstream mf(gen / "tu_manifest.txt");
    if (!mf) { std::fprintf(stderr, "compat.opencv5 build.mcpp: mcpp_generated/tu_manifest.txt missing\n"); return 1; }
    std::string line;
    int stubs = 0;
    while (std::getline(mf, line)) {
        if (line.empty() || line[0] == '#') continue;
        std::vector<std::string> f;
        size_t pos = 0;
        while (true) {
            size_t t = line.find('\t', pos);
            if (t == std::string::npos) { f.push_back(line.substr(pos)); break; }
            f.push_back(line.substr(pos, t - pos)); pos = t + 1;
        }
        if (f[0] == "!prelude" && f.size() == 3) { preludes[f[1]] += f[2] + "\n"; continue; }
        if (f.size() != 2) continue;
        const std::string& grp = f[0];
        const std::string& target = f[1];
        std::string mangled = target;
        for (char& c : mangled) if (c == '/') c = '_';
        fs::path stub = out / "tu" / grp / mangled;
        std::string content = "/* compat.opencv5 forwarding TU (" + grp + ") */\n"
            + preludes[grp] + "#include \"" + target + "\"\n";
        spew(stub, content);
        std::printf("mcpp:generated=%s\n", stub.string().c_str());
        stubs++;
    }

    // out/ carries builtin_font_*.h, opencl_kernels_*.hpp, clsrc/ includes
    std::printf("mcpp:cxxflag=-I%s\n", out.string().c_str());
    std::printf("mcpp:cflag=-I%s\n", out.string().c_str());
    std::printf("mcpp:rerun-if-changed=%s\n", (gen / "tu_manifest.txt").string().c_str());
    // diagnostics as a non-directive stdout line: stderr writes can interleave
    // into the (buffered) stdout directive stream and corrupt a directive.
    std::printf("compat.opencv5 build.mcpp: %d stubs, fonts + CL kernels synthesized\n", stubs);
    std::fflush(stdout);
    return 0;
}
