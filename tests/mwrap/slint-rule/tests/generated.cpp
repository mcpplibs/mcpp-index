// t.h is what mcpplibs.mplugin.slint wrote for ui/t.slint; the program compiles against it.
#include "t.h"
#include <cstdio>

int main() {
    static_assert(sizeof(Tiny) > 0);
    std::puts("mcpplibs.mplugin.slint: ui/t.slint became t.h, and Tiny compiles");
    return 0;
}
