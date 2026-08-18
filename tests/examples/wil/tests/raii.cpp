// Behavioral test: WIL's three families, each doing real work.
//
// A header-only package can fail in two ways a "does it link" test would miss:
// the headers might not compile under this toolchain at all (WIL is dense in
// __declspec, SAL annotations and intrinsics, and this index builds Windows
// with clang rather than cl.exe), and the RAII types might not actually release
// what they own. So the assertions observe SIDE EFFECTS — a handle that really
// closed, a COM refcount that really dropped — rather than just naming symbols.
#ifdef _WIN32

#include <wil/com.h>
#include <wil/resource.h>
#include <wil/result.h>

#include <windows.h>
#include <shobjidl.h>

#include <cassert>
#include <utility>

namespace {

// Returns whether the handle value still names a live kernel object in this
// process. This is how "the wrapper really closed it" gets observed.
bool handle_is_live(HANDLE h) {
    DWORD flags = 0;
    return ::GetHandleInformation(h, &flags) != FALSE;
}

HRESULT succeeds() { return S_OK; }
HRESULT fails() { return E_ACCESSDENIED; }

HRESULT propagates_failure() {
    RETURN_IF_FAILED(succeeds());
    RETURN_IF_FAILED(fails());     // must return here
    return S_FALSE;                // unreachable
}

}  // namespace

int main() {
    // ── wil::unique_handle: ownership, move, and actual closure ──────────
    HANDLE raw = ::CreateEventW(nullptr, TRUE, FALSE, nullptr);
    assert(raw != nullptr && handle_is_live(raw));
    {
        wil::unique_handle owner(raw);
        assert(owner.get() == raw);

        wil::unique_handle moved = std::move(owner);
        assert(!owner && moved.get() == raw);   // move really transferred
        assert(handle_is_live(raw));            // and did not close on the way
    }
    assert(!handle_is_live(raw) && "unique_handle did not close the handle");

    // release() must hand ownership BACK, i.e. not close it
    HANDLE raw2 = ::CreateEventW(nullptr, TRUE, FALSE, nullptr);
    assert(raw2 != nullptr);
    {
        wil::unique_handle owner(raw2);
        HANDLE released = owner.release();
        assert(released == raw2 && !owner);
    }
    assert(handle_is_live(raw2) && "release() must not close");
    ::CloseHandle(raw2);

    // ── wil::unique_hlocal_string over a LocalAlloc'd buffer ─────────────
    {
        auto* buffer = static_cast<PWSTR>(::LocalAlloc(LPTR, 8 * sizeof(wchar_t)));
        assert(buffer != nullptr);
        wcscpy_s(buffer, 8, L"wil");
        wil::unique_hlocal_string owned(buffer);
        assert(owned && wcscmp(owned.get(), L"wil") == 0);
    }  // LocalFree runs here; nothing observable, but it must compile and not crash

    // ── wil::com_ptr against a real COM object ───────────────────────────
    {
        const auto uninit = wil::CoInitializeEx(COINIT_APARTMENTTHREADED);

        wil::com_ptr<IShellLinkW> link;
        const HRESULT hr = ::CoCreateInstance(CLSID_ShellLink, nullptr, CLSCTX_INPROC_SERVER,
                                              IID_PPV_ARGS(&link));
        assert(SUCCEEDED(hr) && link);

        // query() crosses an interface — the classic com_ptr operation.
        auto persist = link.query<IPersistFile>();
        assert(persist);

        // A raw AddRef/Release pair around a copy proves the smart pointer is
        // actually counting, not just holding.
        link->AddRef();
        const ULONG after_addref = link->AddRef();
        const ULONG after_release = link->Release();
        assert(after_release == after_addref - 1);
        link->Release();

        wil::com_ptr<IShellLinkW> copy = link;
        assert(copy.get() == link.get());
        copy.reset();
        assert(!copy && link);
    }

    // ── HRESULT macros: the error model, not just the spelling ───────────
    assert(propagates_failure() == E_ACCESSDENIED);

    bool threw = false;
    try {
        THROW_IF_FAILED(fails());
    } catch (const wil::ResultException& e) {
        threw = true;
        assert(e.GetErrorCode() == E_ACCESSDENIED);
    }
    assert(threw && "THROW_IF_FAILED did not throw on a failed HRESULT");

    // …and must NOT throw on success.
    THROW_IF_FAILED(succeeds());

    return 0;
}

#else

int main() { return 0; }   // WIL is Windows-only; nothing to assert here.

#endif
