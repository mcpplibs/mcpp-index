#include <cstdio>
#include <sstream>
#include <string>

#include <pugixml.hpp>

static_assert(PUGIXML_VERSION == 1160, "expected pugixml 1.16 headers");

int main() {
    bool ok = true;

    const char *xml = R"(<?xml version="1.0" encoding="UTF-8"?>
<catalog>
  <book id="1" price="19.99"><title>Alpha</title></book>
  <book id="2" price="29.50"><title>Beta</title></book>
</catalog>)";

    pugi::xml_document doc;
    pugi::xml_parse_result res = doc.load_string(xml);
    if (!res) {
        std::fprintf(stderr, "pugixml load_string failed: %s\n", res.description());
        return 1;
    }

    // DOM traversal and typed attributes
    pugi::xml_node catalog = doc.child("catalog");
    ok = ok && catalog;
    pugi::xml_node first = catalog.child("book");
    ok = ok && first.attribute("id").as_int() == 1;
    ok = ok && std::string(first.child_value("title")) == "Alpha";

    // XPath query
    pugi::xpath_node match = doc.select_node("/catalog/book[@id='2']/title");
    ok = ok && match && std::string(match.node().child_value()) == "Beta";

    // Mutation and serialization
    pugi::xml_node added = catalog.append_child("book");
    added.append_attribute("id") = 3;
    added.append_child("title").text().set("Gamma");

    std::ostringstream oss;
    doc.save(oss, "  ", pugi::format_raw);
    const std::string out = oss.str();
    ok = ok && out.find("<book id=\"3\"><title>Gamma</title></book>") != std::string::npos;

    // Malformed XML rejection
    pugi::xml_document bad;
    pugi::xml_parse_result bad_res = bad.load_string("<unclosed>");
    ok = ok && !bad_res && bad_res.status != pugi::status_ok;

    return ok ? 0 : 1;
}
