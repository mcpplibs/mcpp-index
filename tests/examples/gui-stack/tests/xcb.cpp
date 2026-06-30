#ifdef __linux__
#include <cstdlib>
#include <xcb/xcb.h>
int main() {
    char* host = nullptr; int display = -1, screen = -1;
    const int ok = xcb_parse_display(":0.1", &host, &display, &screen);
    std::free(host);
    return ok && display == 0 && screen == 1 ? 0 : 1;
}
#else
int main() { return 0; }
#endif
