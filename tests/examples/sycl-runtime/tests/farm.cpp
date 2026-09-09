// What compat.sycl-runtime is asserted to do.
//
// A machine with no GPU is a legitimate configuration and is what every runner
// in this repository is, so the test cannot require a device. It asserts the
// properties that hold on both kinds of machine.
//
//   1. The package resolves, builds and links. The failure this package exists
//      to prevent is a RUNTIME one -- `libsycl.so.9 not found on the search
//      path this artifact will actually use` -- so linking alone is not the
//      whole assertion.
//
//   2. THE FARM IS SUFFICIENT FOR ITS OWN MEMBERS. For every versioned library
//      in the farm, every SONAME in its DT_NEEDED is either in the farm too or
//      is one of the three the artifact itself has already loaded.
//
//   3. `libsycl.so.9` loads and carries the entry point every SYCL program
//      reaches the runtime through. Resolving a file is not the same as it
//      being the runtime.
//
// WHY (2) IS A DT_NEEDED WALK AND NOT `dlopen` OF EACH MEMBER, which is what
// this test did first: dlopen measures the PROCESS, and the process has more
// on its search path than this package put there. Measured -- with an OpenCL
// dependency briefly declared, `compat:opencl-runtime`'s farm supplied
// `libnvidia-ml.so.1`, so removing NVML from THIS farm changed nothing and the
// test passed on a farm that was missing it. A package's test has to be able
// to fail on that package alone.
//
//   Before this walk existed, the assertion was three hand-written names --
//   `libsycl.so.9`, `libur_loader.so.0`, `libumf.so.1` -- against a farm of
//   twenty-five members, and the two members that could not load were not
//   among the three (mcpp#596). The population is enumerated now; only the
//   exceptions are named, and each one carries its reason.
//
// WHETHER A MEMBER'S CLOSURE IS SATISFIED IS A PACKAGING PROPERTY, NOT A
// DEVICE PROPERTY. This machine has no Level Zero device and both Level Zero
// adapters are complete; the two that were broken reported `cannot open shared
// object file`, which is a statement about the farm.
//
// THE TWO LEGITIMATE ABSENCES:
//
//   * A dangling farm entry. The farm links the host's NVIDIA driver through
//     `xim:libcuda-host-link`, whose symlinks are deliberately dangling on a
//     machine with no driver so that installing one later self-heals every
//     consumer. The entry is present, so the package did its part; the target
//     is the machine's answer.
//
//   * A SONAME this package gets from a DECLARED DEPENDENCY rather than from
//     its own farm. Today that is `libOpenCL.so.1`: `compat:sycl-runtime`
//     depends on `compat:opencl`, whose shared library is deployed beside the
//     consumer's executable and is found there through `$ORIGIN`. The name is
//     listed here rather than resolved through the process, because resolving
//     through the process is what let another farm answer for
//     `libnvidia-ml.so.1` and hide the gap this test exists to catch. A short
//     list that a reader can check is the price of a criterion that cannot be
//     masked.
//
// Which devices exist is deliberately NOT asserted: that is the machine's
// answer, not this package's.
#include <cstdio>

#ifndef __linux__
int main() {
    std::printf("not applicable on this platform\n");
    return 0;
}
#else
#include <dirent.h>
#include <dlfcn.h>
#include <elf.h>
#include <link.h>
#include <sys/stat.h>

#include <cstdint>
#include <cstring>
#include <string>
#include <vector>

namespace {

// Loaded on the executable's own behalf before any farm member is asked for,
// and resolved by SONAME without a search. The recipe says the same thing from
// the other side, as the reason it does NOT farm them: a second C library in
// one address space is the one failure worse than a missing library.
bool provided_by_the_artifact(const std::string& soname) {
    return soname == "libc.so.6" || soname == "libm.so.6"
        || soname.rfind("ld-linux", 0) == 0;
}

// Served by a declared dependency of this package, not by its farm.
//
// `compat:opencl` builds the Khronos ICD loader with the canonical soname and
// mcpp deploys it beside the consumer's executable, where `$ORIGIN` finds it.
// Naming it here keeps the farm's self-sufficiency assertion exact: everything
// NOT on this list must be in the farm, and no other directory on the search
// path can answer for it.
bool served_by_a_declared_dependency(const std::string& soname) {
    return soname == "libOpenCL.so.1";
}

// The farm's directory, read from a library that is in it.
//
// Not spelled as a path: this test does not know where the package was
// installed, and the artifact's own DT_RPATH is the only thing that does.
// `libsycl.so.9` resolves through it and the link map reports the file that
// was actually opened, so the directory is discovered the way the loader
// discovers it.
std::string farm_dir() {
    void* h = dlopen("libsycl.so.9", RTLD_LAZY | RTLD_LOCAL);
    if (!h) {
        std::printf("FAIL libsycl.so.9: %s\n", dlerror());
        return {};
    }
    struct link_map* map = nullptr;
    if (dlinfo(h, RTLD_DI_LINKMAP, &map) != 0 || !map || !map->l_name) {
        std::printf("FAIL libsycl.so.9: loaded, but its path is not readable\n");
        return {};
    }
    std::string path = map->l_name;
    auto slash = path.rfind('/');
    return slash == std::string::npos ? std::string(".") : path.substr(0, slash);
}

bool versioned_soname(const std::string& name) {
    // `libfoo.so.N...`, which is what the farm links and what dlopen asks for.
    // The `-gdb.py` sidecars beside the payload's libraries match a looser test.
    auto so = name.find(".so.");
    if (so == std::string::npos) return false;
    if (name.size() < so + 5) return false;
    if (name.size() >= 3 && name.compare(name.size() - 3, 3, ".py") == 0)
        return false;
    return name[so + 4] >= '0' && name[so + 4] <= '9';
}

// A link whose target does not exist. The sentinel's self-heal shape.
bool dangling(const std::string& path) {
    struct stat st {};
    struct stat lst {};
    if (lstat(path.c_str(), &lst) != 0) return false;
    return stat(path.c_str(), &st) != 0;
}

// The DT_NEEDED list of an ELF64 file.
//
// Read here rather than shelled out to `objdump`/`readelf`: a test that needs
// a binutils on the runner is a test that skips. Returns false when the file
// is not an ELF64 this reader understands, which the caller reports rather
// than treating as an empty list -- "could not look" and "nothing there" are
// the two readings this repository has been burned by conflating.
bool needed_of(const std::string& path, std::vector<std::string>& out) {
    FILE* f = std::fopen(path.c_str(), "rb");
    if (!f) return false;
    std::vector<unsigned char> buf;
    std::fseek(f, 0, SEEK_END);
    long size = std::ftell(f);
    std::fseek(f, 0, SEEK_SET);
    if (size <= 0) { std::fclose(f); return false; }
    buf.resize(static_cast<std::size_t>(size));
    bool ok = std::fread(buf.data(), 1, buf.size(), f) == buf.size();
    std::fclose(f);
    if (!ok || buf.size() < sizeof(Elf64_Ehdr)) return false;

    auto const* eh = reinterpret_cast<const Elf64_Ehdr*>(buf.data());
    if (std::memcmp(eh->e_ident, ELFMAG, SELFMAG) != 0) return false;
    if (eh->e_ident[EI_CLASS] != ELFCLASS64) return false;
    if (eh->e_phoff == 0 || eh->e_phentsize != sizeof(Elf64_Phdr)) return false;

    const Elf64_Dyn* dyn = nullptr;
    std::size_t dynCount = 0;
    for (unsigned i = 0; i < eh->e_phnum; ++i) {
        auto off = eh->e_phoff + static_cast<std::size_t>(i) * eh->e_phentsize;
        if (off + sizeof(Elf64_Phdr) > buf.size()) return false;
        auto const* ph = reinterpret_cast<const Elf64_Phdr*>(buf.data() + off);
        if (ph->p_type != PT_DYNAMIC) continue;
        if (ph->p_offset + ph->p_filesz > buf.size()) return false;
        dyn = reinterpret_cast<const Elf64_Dyn*>(buf.data() + ph->p_offset);
        dynCount = ph->p_filesz / sizeof(Elf64_Dyn);
    }
    if (!dyn) return true;   // statically linked: no DT_NEEDED, and that is a
                             // complete answer rather than a failure to read

    // DT_STRTAB is a virtual address; map it back through the program headers
    // that actually cover it.
    std::uint64_t strtabVaddr = 0;
    for (std::size_t i = 0; i < dynCount && dyn[i].d_tag != DT_NULL; ++i)
        if (dyn[i].d_tag == DT_STRTAB) strtabVaddr = dyn[i].d_un.d_ptr;
    if (!strtabVaddr) return false;

    std::size_t strtabOff = 0;
    bool mapped = false;
    for (unsigned i = 0; i < eh->e_phnum; ++i) {
        auto off = eh->e_phoff + static_cast<std::size_t>(i) * eh->e_phentsize;
        auto const* ph = reinterpret_cast<const Elf64_Phdr*>(buf.data() + off);
        if (ph->p_type != PT_LOAD) continue;
        if (strtabVaddr < ph->p_vaddr || strtabVaddr >= ph->p_vaddr + ph->p_filesz)
            continue;
        strtabOff = ph->p_offset + (strtabVaddr - ph->p_vaddr);
        mapped = true;
        break;
    }
    if (!mapped || strtabOff >= buf.size()) return false;

    for (std::size_t i = 0; i < dynCount && dyn[i].d_tag != DT_NULL; ++i) {
        if (dyn[i].d_tag != DT_NEEDED) continue;
        auto at = strtabOff + dyn[i].d_un.d_val;
        if (at >= buf.size()) return false;
        out.emplace_back(reinterpret_cast<const char*>(buf.data() + at));
    }
    return true;
}

} // namespace

int main() {
    const std::string dir = farm_dir();
    if (dir.empty()) return 1;
    std::printf("farm: %s\n", dir.c_str());

    DIR* d = opendir(dir.c_str());
    if (!d) {
        std::printf("FAIL %s: cannot be read\n", dir.c_str());
        return 1;
    }
    std::vector<std::string> members;
    while (dirent* e = readdir(d)) {
        std::string name = e->d_name;
        if (versioned_soname(name)) members.push_back(name);
    }
    closedir(d);

    auto in_farm = [&](const std::string& soname) {
        for (auto const& m : members) if (m == soname) return true;
        return false;
    };

    // The denominator, printed before any verdict. A farm that failed to build
    // enumerates nothing and every per-member assertion then passes.
    std::printf("members: %zu\n", members.size());
    if (members.empty()) {
        std::printf("FAIL: the farm is empty\n");
        return 1;
    }

    int bad = 0;
    std::size_t walked = 0;
    for (auto const& name : members) {
        const std::string path = dir + "/" + name;
        if (dangling(path)) {
            // A host library this machine does not have. The entry is present,
            // which is this package's half of the contract.
            std::printf("skip %s (dangling host link)\n", name.c_str());
            continue;
        }
        std::vector<std::string> needed;
        if (!needed_of(path, needed)) {
            std::printf("FAIL %s: DT_NEEDED could not be read\n", name.c_str());
            ++bad;
            continue;
        }
        ++walked;
        for (auto const& soname : needed) {
            if (provided_by_the_artifact(soname)) continue;
            if (in_farm(soname)) {
                if (dangling(dir + "/" + soname))
                    std::printf("note %s needs %s, which is a dangling host "
                                "link on this machine\n",
                                name.c_str(), soname.c_str());
                continue;
            }
            if (served_by_a_declared_dependency(soname)) {
                std::printf("note %s needs %s, which a declared dependency of "
                            "this package provides\n",
                            name.c_str(), soname.c_str());
                continue;
            }
            std::printf("FAIL %s needs %s, which the farm does not carry\n",
                        name.c_str(), soname.c_str());
            ++bad;
        }
    }
    // The second denominator. Every member could be a dangling link, and the
    // walk above would then have examined nothing while reporting no failure.
    std::printf("walked: %zu of %zu members\n", walked, members.size());
    if (walked == 0) {
        std::printf("FAIL: no member's closure was examined\n");
        ++bad;
    }

    // The entry point every SYCL program reaches the runtime through. Loading
    // the file is not the same as it being the runtime, and a farm that linked
    // a stale or wrong-class file would satisfy everything above.
    void* h = dlopen("libsycl.so.9", RTLD_LAZY | RTLD_LOCAL);
    if (!h || !dlsym(h, "__sycl_register_lib")) {
        std::printf("FAIL libsycl.so.9: __sycl_register_lib is not there\n");
        ++bad;
    }

    std::printf("%s\n", bad ? "FAILED" : "PASSED");
    return bad ? 1 : 0;
}
#endif
