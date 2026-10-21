// Model a libc that provides public baud constants without glibc's private
// __MAX_BAUD helper. Include termios first so its include guard prevents the
// library header from restoring the private macro on a glibc test host.
#ifdef __linux__
#include <termios.h>
#undef __MAX_BAUD
#include <libserial/SerialPortConstants.h>

static_assert(static_cast<speed_t>(LibSerial::BaudRate::BAUD_2000000) == B2000000);
static_assert(static_cast<speed_t>(LibSerial::BaudRate::BAUD_2500000) == B2500000);
static_assert(static_cast<speed_t>(LibSerial::BaudRate::BAUD_3000000) == B3000000);
static_assert(static_cast<speed_t>(LibSerial::BaudRate::BAUD_3500000) == B3500000);
static_assert(static_cast<speed_t>(LibSerial::BaudRate::BAUD_4000000) == B4000000);
#endif

int main() { return 0; }
