// Behavioral test — compat.mio actually maps a file.
//
// The test writes its own file into the working directory, maps it, reads
// through the mapping and then writes through a second mapping. Nothing here
// depends on the runner's filesystem layout beyond "can create a file", which
// is true on all three CI platforms.
#include <mio/mmap.hpp>

#include <cstdio>
#include <fstream>
#include <string>
#include <system_error>

int main() {
    const std::string path = "mcpp_mio_test.bin";
    const std::string payload = "mcpp-index mio round trip";

    {
        std::ofstream out(path, std::ios::binary | std::ios::trunc);
        out.write(payload.data(), static_cast<std::streamsize>(payload.size()));
    }

    std::error_code ec;
    // Read mapping: the bytes must come back through the mapping, not through
    // a copy — a broken include root cannot get this far, but a mio that
    // mapped nothing would return an empty range.
    mio::mmap_source ro = mio::make_mmap_source(path, 0, mio::map_entire_file, ec);
    if (ec) { std::printf("make_mmap_source failed: %s\n", ec.message().c_str()); std::remove(path.c_str()); return 1; }
    if (ro.size() != payload.size() || std::string(ro.begin(), ro.end()) != payload) {
        std::printf("mapped content differs\n");
        std::remove(path.c_str());
        return 2;
    }
    ro.unmap();

    // Write mapping: mutate through the map, flush, and read the file back
    // with ordinary I/O. This is the half that proves it is a real mapping and
    // not a buffered read.
    mio::mmap_sink rw = mio::make_mmap_sink(path, 0, mio::map_entire_file, ec);
    if (ec) { std::printf("make_mmap_sink failed: %s\n", ec.message().c_str()); std::remove(path.c_str()); return 3; }
    rw[0] = 'M';
    rw.sync(ec);
    if (ec) { std::printf("sync failed: %s\n", ec.message().c_str()); std::remove(path.c_str()); return 4; }
    rw.unmap();

    std::string back;
    {
        std::ifstream in(path, std::ios::binary);
        back.assign(std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>());
    }
    std::remove(path.c_str());

    if (back.empty() || back[0] != 'M') { std::printf("write through the mapping did not reach the file\n"); return 5; }

    std::printf("compat.mio: ok (mapped %zu bytes, read back and wrote through)\n", payload.size());
    return 0;
}
