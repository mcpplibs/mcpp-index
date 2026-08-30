// compat.expat — behavioral test. It parses a document rather than checking
// that symbols resolve, because the interesting failures are configuration
// ones: XML_DTD, XML_GE and XML_NS are feature switches compiled into
// expat_config.h, and getting them wrong yields a parser that links perfectly
// and then rejects (or mis-splits) input.

#ifdef __linux__

#include <expat.h>

#include <dlfcn.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) ++failures;
}

struct Collected {
    std::vector<std::string> elements;
    std::string text;
};

void XMLCALL on_start(void *ud, const XML_Char *name, const XML_Char **atts)
{
    auto *c = static_cast<Collected *>(ud);
    c->elements.emplace_back(name);
    for (int i = 0; atts != nullptr && atts[i] != nullptr; i += 2) {
        c->elements.emplace_back(std::string("@") + atts[i] + "=" + atts[i + 1]);
    }
}

void XMLCALL on_text(void *ud, const XML_Char *s, int len)
{
    static_cast<Collected *>(ud)->text.append(s, static_cast<std::size_t>(len));
}

} // namespace

int main()
{
    // ── 1. A namespaced parse, which is XML_NS ───────────────────────────
    // The separator argument only does anything when XML_NS was compiled in;
    // without it the element name comes back as "w:seat" instead of the
    // expanded "urn:test|seat", and wayland-scanner would misread every
    // protocol file.
    {
        Collected c;
        XML_Parser p = XML_ParserCreateNS(nullptr, '|');
        check(p != nullptr, "XML_ParserCreateNS returns a parser");
        XML_SetUserData(p, &c);
        XML_SetElementHandler(p, on_start, nullptr);
        XML_SetCharacterDataHandler(p, on_text);

        static const char doc[] =
            "<w:proto xmlns:w='urn:test'><w:seat name='seat0'>hi</w:seat></w:proto>";
        const bool ok = XML_Parse(p, doc, (int)std::strlen(doc), 1) == XML_STATUS_OK;
        check(ok, "XML_Parse accepts a namespaced document");
        check(c.elements.size() >= 2 && c.elements[0] == "urn:test|proto",
              "XML_NS expanded the prefix (urn:test|proto)");
        check(c.text == "hi", "character data reached the handler");
        XML_ParserFree(p);
    }

    // ── 2. An internal DTD entity, which is XML_DTD + XML_GE ─────────────
    // Built without general-entity support this parse fails outright, so it
    // separates a correct expat_config.h from a plausible one.
    {
        Collected c;
        XML_Parser p = XML_ParserCreate(nullptr);
        XML_SetUserData(p, &c);
        XML_SetCharacterDataHandler(p, on_text);

        static const char doc[] =
            "<!DOCTYPE r [<!ENTITY who 'wayland'>]><r>&who;</r>";
        const bool ok = XML_Parse(p, doc, (int)std::strlen(doc), 1) == XML_STATUS_OK;
        check(ok, "XML_Parse accepts an internal DTD entity");
        check(c.text == "wayland", "the general entity expanded to 'wayland'");
        XML_ParserFree(p);
    }

    // ── 3. Malformed input is rejected ───────────────────────────────────
    {
        XML_Parser p = XML_ParserCreate(nullptr);
        static const char bad[] = "<a><b></a>";
        check(XML_Parse(p, bad, (int)std::strlen(bad), 1) == XML_STATUS_ERROR,
              "mismatched tags are an error, not silence");
        XML_ParserFree(p);
    }

    // ── 4. It is THIS build that ran ─────────────────────────────────────
    {
        Dl_info info{};
        const bool located =
            ::dladdr(reinterpret_cast<void *>(&XML_ParserCreate), &info) != 0
            && info.dli_fname != nullptr;
        check(located, "dladdr locates the loaded libexpat");
        if (located) {
            const std::string from = info.dli_fname;
            std::printf("   loaded from: %s\n", from.c_str());
            check(from.find("xim-x-expat") == std::string::npos,
                  "the loaded libexpat is not the ecosystem payload's copy");
        }
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main() { return 0; }

#endif
