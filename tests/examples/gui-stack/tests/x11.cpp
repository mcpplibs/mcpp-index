#ifdef __linux__
#include <X11/Xlib.h>
#include <X11/keysym.h>
int main() {
    const KeySym escape = XStringToKeysym("Escape");
    return X_PROTOCOL == 11 && escape == XK_Escape ? 0 : 1;
}
#else
int main() { return 0; }
#endif
