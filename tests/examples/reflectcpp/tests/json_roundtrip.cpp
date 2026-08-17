// Behavioral test: struct -> JSON -> struct, through the JSON backend.
//
// The package compiles two umbrella TUs plus the vendored yyjson. All three have
// to be present and agree: leave out src/yyjson.c and this fails to LINK; get the
// include roots wrong and rfl/json/save.hpp picks a different yyjson than the one
// compiled, which fails at runtime rather than at build time. So the assertions
// go all the way to parsed values.
#include <rfl.hpp>
#include <rfl/json.hpp>

#include <cassert>
#include <optional>
#include <string>
#include <vector>

struct Point {
    int x;
    int y;
};

struct Document {
    std::string name;
    int version;
    bool enabled;
    std::vector<Point> points;
    std::optional<std::string> note;
};

int main() {
    const Document doc{
        .name = "mcpp",
        .version = 23,
        .enabled = true,
        .points = {{1, 2}, {-3, 4}},
        .note = std::nullopt,
    };

    // --- round trip ---
    const std::string json = rfl::json::write(doc);
    assert(!json.empty());

    const auto parsed = rfl::json::read<Document>(json);
    assert(parsed && "a document this library just wrote must parse");
    const Document& back = parsed.value();
    assert(back.name == doc.name);
    assert(back.version == doc.version);
    assert(back.enabled == doc.enabled);
    assert(back.points.size() == 2);
    assert(back.points[0].x == 1 && back.points[0].y == 2);
    assert(back.points[1].x == -3 && back.points[1].y == 4);
    assert(!back.note.has_value());

    // --- the field-name rename processor, which is why callers reach for rfl ---
    const std::string camel = rfl::json::write<rfl::SnakeCaseToCamelCase>(doc);
    const auto camel_back = rfl::json::read<Document, rfl::SnakeCaseToCamelCase>(camel);
    assert(camel_back && camel_back.value().version == doc.version);

    // --- a malformed document must fail, not throw or crash ---
    const auto bad = rfl::json::read<Document>(R"({"name": 5})");
    assert(!bad && "a type mismatch must surface as an error, not a value");

    // --- to_generic / from_generic, the path an RPC layer uses when the
    //     concrete type is only known per method ---
    const auto generic = rfl::to_generic(doc);
    const auto from_generic = rfl::from_generic<Document>(generic);
    assert(from_generic && from_generic.value().name == doc.name);

    // --- the JSON Schema generator ---
    const std::string schema = rfl::json::to_schema<Document>();
    assert(schema.find("version") != std::string::npos);

    return 0;
}
