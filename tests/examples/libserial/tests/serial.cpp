// Behavioral test: a real pseudo-terminal pair driven through SerialPort.
//
// Why a PTY and not /dev/ttyUSB0: a build machine has no serial hardware, and
// a link-only test would pass even if SerialPort got termios wrong. openpty()
// gives a master/slave pair the same way `socat` would; SerialPort opens the
// slave, and writing on the master exercises its read path while writing
// through SerialPort exercises the master's.
//
// The first include is the one that matters for the descriptor: upstream's
// SerialPortConstants.h uses uint8_t but does not include <cstdint>, so a bare
// `#include <libserial/SerialPort.h>` with nothing before it fails unless the
// package's generated shim supplies it. Deliberately open on the libserial
// header first, with no stdlib header above it, so that shim is compile-time
// asserted.
#ifdef __linux__

#include <libserial/SerialPort.h>
#include <libserial/SerialStream.h>

#include <cassert>
#include <cstdio>
#include <cstring>
#include <string>

#include <fcntl.h>
#include <pty.h>
#include <unistd.h>

using namespace LibSerial;

namespace {

// master>=0 on success; the slave fd is closed again because SerialPort opens
// the path itself.
int open_pty(char (&slave_path)[128]) {
    int master = -1, slave = -1;
    if (::openpty(&master, &slave, nullptr, nullptr, nullptr) != 0) return -1;
    if (::ptsname_r(master, slave_path, sizeof(slave_path)) != 0) {
        ::close(master);
        ::close(slave);
        return -1;
    }
    ::close(slave);   // SerialPort::Open() reopens the slave by path.
    return master;
}

} // namespace

int main() {
    char slave_path[128] = {};
    int master = open_pty(slave_path);
    assert(master >= 0 && "openpty/ptsname_r failed");

    SerialPort port;

    // -- NotOpen contract: a closed port refuses I/O instead of touching fd -1.
    bool threw_not_open = false;
    try { port.Write(std::string("x")); }
    catch (const NotOpen&) { threw_not_open = true; }
    assert(threw_not_open && "Write on a closed port did not throw NotOpen");
    assert(!port.IsOpen());

    // -- Open / IsOpen, and AlreadyOpen on a second Open.
    port.Open(slave_path);
    assert(port.IsOpen() && "port did not open");

    bool threw_already_open = false;
    try { port.Open(slave_path); }
    catch (const AlreadyOpen&) { threw_already_open = true; }
    assert(threw_already_open && "second Open did not throw AlreadyOpen");

    // -- Open defaults: BAUD_115200, 8 data bits, no parity, 1 stop bit.
    assert(port.GetBaudRate()      == BaudRate::BAUD_115200);
    assert(port.GetCharacterSize() == CharacterSize::CHAR_SIZE_8);
    assert(port.GetParity()        == Parity::PARITY_NONE);
    assert(port.GetStopBits()      == StopBits::STOP_BITS_1);

    // -- Set/Get round trips for the attributes a PTY can actually carry.
    // CS7/parity-even are NOT asserted: a pty's line discipline does not store
    // those bits, so GetCharacterSize() stays CS8 and GetParity() stays NONE
    // no matter what is written (measured against the tarball). That is a
    // property of the PTY, not of LibSerial, so the test pins only what is
    // observable here.
    port.SetBaudRate(BaudRate::BAUD_9600);
    assert(port.GetBaudRate() == BaudRate::BAUD_9600);
    port.SetStopBits(StopBits::STOP_BITS_2);
    assert(port.GetStopBits() == StopBits::STOP_BITS_2);
    port.SetFlowControl(FlowControl::FLOW_CONTROL_NONE);
    assert(port.GetFlowControl() == FlowControl::FLOW_CONTROL_NONE);

    // -- TX: SerialPort -> master. SerialPort opens the slave O_NONBLOCK; a pty
    //    accepts the write immediately, so this returns without a reader race.
    port.Write(std::string("hello\n"));
    char rx[16] = {};
    ssize_t got = ::read(master, rx, sizeof(rx));
    assert(got == 6 && std::strncmp(rx, "hello\n", 6) == 0 && "TX bytes mismatched");

    // -- RX: master -> SerialPort. Write on the master, then let the slave's
    //    input queue fill before asking (a 200 ms settle removes the race
    //    between write() returning and the byte landing in the slave buffer).
    assert(::write(master, "ping\n", 5) == 5);
    ::usleep(200 * 1000);
    assert(port.IsDataAvailable() && "IsDataAvailable saw no queued byte");

    char first = 0;
    port.ReadByte(first, 2000);
    assert(first == 'p' && "ReadByte returned the wrong byte");

    std::string line;
    port.ReadLine(line, '\n', 2000);
    assert(line == "ing\n" && "ReadLine did not assemble the rest of the line");

    // -- SerialStream: the iostream interface, on its OWN pty pair. Reusing
    //    the pair above fails: after SerialPort::Close() restored the slave's
    //    saved termios, a second Open() of the same pty throws OpenFailed
    //    ("Bad file descriptor") -- upstream's Open path, not this descriptor's.
    port.Close();
    assert(!port.IsOpen() && "port still open after Close");

    char stream_path[128] = {};
    int stream_master = open_pty(stream_path);
    assert(stream_master >= 0 && "second openpty/ptsname_r failed");

    SerialStream stream;
    stream.Open(stream_path);
    assert(stream.IsOpen() && "SerialStream did not open");
    stream.SetBaudRate(BaudRate::BAUD_57600);
    assert(stream.GetBaudRate() == BaudRate::BAUD_57600);

    // SerialStream -> master, i.e. the iostream write path (xsputn/overflow).
    // The READ path is deliberately not exercised: upstream's
    // SerialStreamBuf::showmanyc() sets the putback flag without storing the
    // character it read, so rdbuf()->in_avail() followed by a stream
    // extraction yields a garbage first byte, and `stream >> x` on a quiet
    // pty blocks (measured against the tarball). That is an upstream defect in
    // SerialStreamBuf, not something this descriptor can fix without patching
    // source, so the test pins the half that works.
    stream << "xyz" << std::flush;
    char tx[16] = {};
    ssize_t got2 = ::read(stream_master, tx, sizeof(tx));
    assert(got2 == 3 && std::strncmp(tx, "xyz", 3) == 0 && "SerialStream TX mismatched");

    stream.Close();
    assert(!stream.IsOpen() && "stream still open after Close");
    ::close(stream_master);

    ::close(master);
    return 0;
}

#else

// LibSerial is POSIX/Linux: <termios.h> and <linux/serial.h>. Nothing to
// assert on a platform the descriptor does not declare.
int main() { return 0; }

#endif
