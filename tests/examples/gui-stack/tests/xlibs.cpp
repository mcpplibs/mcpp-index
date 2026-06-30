#ifdef __linux__
#include <X11/Xlib.h>
#include <X11/extensions/Xext.h>
#include <X11/extensions/Xrender.h>
#include <X11/extensions/Xfixes.h>
#include <X11/Xcursor/Xcursor.h>
#include <X11/extensions/Xinerama.h>
#include <X11/extensions/Xrandr.h>
#include <X11/extensions/XInput2.h>
extern "C" int XextCreateExtension(void);
int main() {
    return XextCreateExtension != nullptr && XRenderQueryExtension != nullptr &&
           XFixesQueryExtension != nullptr && XcursorLibraryPath != nullptr &&
           XineramaQueryExtension != nullptr && XRRQueryExtension != nullptr &&
           XIQueryVersion != nullptr ? 0 : 1;
}
#else
int main() { return 0; }
#endif
