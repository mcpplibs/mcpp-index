// Verify compat.eui-neo's `serial` feature — upstream's first optional MODULE
// with a translation unit of its own (modules/serial/serial.cpp, built as
// eui::module_serial in CMake and absent from CORE_SOURCES).
//
// The primary assertion is LINK-time: SerialPort's ctor/dtor/open()/isOpen()
// only exist when the feature's `sources` entry compiled that TU into the
// package lib. Without it the program fails with undefined references, which
// is the negative result this member is here to make visible.
//
// The runtime half stays hardware-free on purpose: the device path cannot
// exist on any platform, so open() must fail and leave the port closed. 0.6.3
// is the release that made a failed open release its handle and keep the
// previous connection; there is no previous connection here, so the observable
// contract is simply "still closed". No serial hardware, no privileges.
//
// Windows macros first: modules/serial/serial.h includes <windows.h> for the
// consumer, and this TU is compiled by the CONSUMER, which does not inherit the
// package-private NOMINMAX / WIN32_LEAN_AND_MEAN flags.
#if defined(_WIN32)
#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#endif

#include <modules/serial/serial.h>

#include <utility>

int main() {
    bool ok = true;

    core::serial::SerialPort port;
    ok = ok && !port.isOpen();

    const core::serial::OpenResult missing =
        port.open("__mcpp_no_such_serial_device__", 115200);
    ok = ok && !missing.ok;
    ok = ok && missing.error != core::serial::OpenError::None;
    ok = ok && !port.isOpen();

    // 0.6.3: ownership is movable and the moved-from object ends up closed.
    core::serial::SerialPort moved(std::move(port));
    ok = ok && !moved.isOpen();
    moved.close();

    return ok ? 0 : 1;
}
