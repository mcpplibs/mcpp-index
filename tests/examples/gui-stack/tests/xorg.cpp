#ifdef __linux__
#include <X11/Xauth.h>
#include <X11/Xdmcp.h>
int main() {
    ARRAY8 array{};
    const int allocated = XdmcpAllocARRAY8(&array, 1);
    if (allocated) XdmcpDisposeARRAY8(&array);
    char* auth_file = XauFileName();
    return allocated && auth_file != nullptr ? 0 : 1;
}
#else
int main() { return 0; }
#endif
