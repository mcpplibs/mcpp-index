#ifdef __linux__

#include <bluetooth/bluetooth.h>
#include <bluetooth/l2cap.h>
#include <bluetooth/uuid.h>

#include <cassert>
#include <cstring>
#include <iostream>

int main() {
    // Positive check: address formatting and parsing via libbluetooth.
    bdaddr_t addr{};
    assert(str2ba("11:22:33:44:55:66", &addr) == 0);
    char formatted[18]{};
    assert(ba2str(&addr, formatted) == 17);
    assert(std::strcmp(formatted, "11:22:33:44:55:66") == 0);

    // Positive check: UUID string conversion via uuid.c + struct sockaddr_l2 layout.
    bt_uuid_t uuid{};
    assert(bt_string_to_uuid(&uuid, "0000180d-0000-1000-8000-00805f9b34fb") == 0);
    sockaddr_l2 l2{};
    l2.l2_family = AF_BLUETOOTH;
    l2.l2_bdaddr = addr;
    assert(l2.l2_family == AF_BLUETOOTH);

    // Negative check: malformed Bluetooth address and malformed UUID fail cleanly.
    bdaddr_t bad_addr{};
    assert(str2ba("not-an-address", &bad_addr) < 0);
    bt_uuid_t bad_uuid{};
    assert(bt_string_to_uuid(&bad_uuid, "invalid-uuid") < 0);

    std::cout << "compat.bluez verification PASSED\n";
    return 0;
}

#else

#include <iostream>

int main() {
    std::cout << "compat.bluez verification SKIPPED (Linux only)\n";
    return 0;
}

#endif
