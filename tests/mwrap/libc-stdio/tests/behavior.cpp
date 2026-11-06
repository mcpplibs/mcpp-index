// The installed C standard library wrapper: the streams, errno() as strtol
// sets it, and the stdio constants on a temporary file.
import mcpplibs.mwrap.libc;

namespace c = mcpplibs::mwrap::libc::macros;

int main() {
    if (std::fputs("libc-stdio writes to stdout()\n", c::stdout()) == c::EOF) return 1;
    if (std::fputs("libc-stdio writes to stderr()\n", c::stderr()) == c::EOF) return 2;
    c::errno() = 0;
    std::strtol("99999999999999999999999", nullptr, 10);
    if (c::errno() != c::ERANGE) return 3;
    std::FILE* f = std::tmpfile();
    if (!f) return 4;
    std::fputs("xyz", f);
    std::fseek(f, 0, c::SEEK_SET);
    const bool first = std::fgetc(f) == 'x';
    std::fseek(f, 0, c::SEEK_END);
    const bool end = std::fgetc(f) == c::EOF;
    std::fclose(f);
    return first && end && c::CHAR_BIT == 8 && c::BUFSIZ > 0 ? 0 : 5;
}
