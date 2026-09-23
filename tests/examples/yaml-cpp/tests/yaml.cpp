// Behavioral test for compat.yaml-cpp 0.9.0.
//
// Each check reaches symbols defined in the package's own .cpp files, so a
// package that compiled nothing cannot pass by being header-only by accident:
//
//   YAML::Load, node access, conversions  -> parse.cpp, node_data.cpp, convert.cpp
//   anchors and aliases                   -> nodebuilder.cpp, singledocparser.cpp
//   YAML::LoadAll                         -> parse.cpp, parser.cpp
//   YAML::Emitter, YAML::Dump             -> emitter.cpp, emitterstate.cpp, emit.cpp
//   malformed input                       -> scanner.cpp, exceptions.cpp
//   YAML::BuildGraphOfNextDocument        -> contrib/graphbuilder*.cpp
//   YAML::FpToString                      -> fptostring.cpp (new in 0.9.0)
//
// Returns non-zero on any mismatch.
#include <yaml-cpp/yaml.h>
#include <yaml-cpp/contrib/graphbuilder.h>
#include <yaml-cpp/fptostring.h>

#include <cstdio>
#include <sstream>
#include <string>
#include <vector>

// The package builds objects, not a shared library, so every yaml-cpp
// declaration this TU sees must be plain -- not dllimport. The package
// delivers that with a shim in front of yaml-cpp/dll.h, because no descriptor
// key carries a define to a consumer's TUs. On Linux the difference is only a
// visibility attribute and everything links anyway; on the MSVC ABI it is a
// link failure. Asserting it at compile time fails everywhere the moment the
// shim stops being reached.
#ifndef YAML_CPP_STATIC_DEFINE
#  error "YAML_CPP_STATIC_DEFINE did not reach the consumer: the yaml-cpp/dll.h shim was not found first"
#endif

namespace {

const char *const kDoc = R"(
name: mcpp-index
version: 3
ratio: 0.25
enabled: true
tags: [yaml, cpp, "quoted, with comma"]
base: &base
  host: localhost
  port: 8080
derived:
  <<: *base
  alias_of_base: *base
text: |
  line one
  line two
)";

bool loads_and_converts() {
    YAML::Node root = YAML::Load(kDoc);
    if (!root.IsMap()) return false;
    if (root["name"].as<std::string>() != "mcpp-index") return false;
    if (root["version"].as<int>() != 3) return false;
    if (root["ratio"].as<double>() != 0.25) return false;
    if (!root["enabled"].as<bool>()) return false;

    const YAML::Node tags = root["tags"];
    if (!tags.IsSequence() || tags.size() != 3) return false;
    if (tags[2].as<std::string>() != "quoted, with comma") return false;
    if (tags.as<std::vector<std::string>>().front() != "yaml") return false;

    if (root["text"].as<std::string>() != "line one\nline two\n") return false;

    // A missing key is reported as undefined and a fallback applies; an
    // explicit conversion of the wrong kind throws.
    if (root["absent"].IsDefined()) return false;
    if (root["absent"].as<int>(42) != 42) return false;
    try {
        (void)root["name"].as<int>();
        return false;
    } catch (const YAML::BadConversion &) {
    }
    return true;
}

bool resolves_aliases() {
    YAML::Node root = YAML::Load(kDoc);
    const YAML::Node alias = root["derived"]["alias_of_base"];
    if (alias["port"].as<int>() != 8080) return false;
    // An alias is the SAME node as its anchor, not a copy of it.
    return alias.is(root["base"]);
}

bool loads_every_document() {
    const std::vector<YAML::Node> docs = YAML::LoadAll("a: 1\n---\nb: 2\n---\n- 3\n");
    return docs.size() == 3 && docs[0]["a"].as<int>() == 1
           && docs[1]["b"].as<int>() == 2 && docs[2][0].as<int>() == 3;
}

bool emits_and_round_trips() {
    YAML::Emitter out;
    out << YAML::BeginMap;
    out << YAML::Key << "list" << YAML::Value << YAML::Flow
        << YAML::BeginSeq << 1 << 2 << 3 << YAML::EndSeq;
    out << YAML::Key << "nested" << YAML::Value << YAML::BeginMap
        << YAML::Key << "k" << YAML::Value << "v" << YAML::EndMap;
    out << YAML::EndMap;
    if (!out.good()) return false;
    if (std::string(out.c_str()) != "list: [1, 2, 3]\nnested:\n  k: v") return false;

    YAML::Node again = YAML::Load(out.c_str());
    if (again["list"][2].as<int>() != 3) return false;

    // A node built in code and dumped comes back with the same content.
    YAML::Node built;
    built["x"] = 7;
    built["y"].push_back("first");
    built["y"].push_back("second");
    YAML::Node back = YAML::Load(YAML::Dump(built));
    return back["x"].as<int>() == 7 && back["y"].size() == 2
           && back["y"][1].as<std::string>() == "second";
}

bool rejects_malformed_input() {
    try {
        (void)YAML::Load("key: [unterminated\nother: 1\n");
    } catch (const YAML::ParserException &e) {
        // The mark points into the document rather than being left unset.
        return e.mark.line >= 0 && !std::string(e.what()).empty();
    }
    return false;
}

}  // namespace

// Upstream declares GraphBuilderInterface's destructor pure virtual and
// defines it nowhere (0.8.0 and 0.9.0 alike), so every class derived from it
// -- upstream's own GraphBuilder<Impl> included -- needs the definition from
// its user. This is that definition, as any consumer of the contrib API must
// write it. BuildGraphOfNextDocument below still comes only from
// src/contrib/graphbuilder.cpp, so the check still proves contrib was built.
YAML::GraphBuilderInterface::~GraphBuilderInterface() = default;

namespace {

// Counts what the contrib GraphBuilder is told, which only the two
// src/contrib/*.cpp translation units implement.
struct Counter : YAML::GraphBuilderInterface {
    int scalars = 0, sequences = 0, maps = 0;
    void *NewNull(const YAML::Mark &, void *) override { return this; }
    void *NewScalar(const YAML::Mark &, const std::string &, void *,
                    const std::string &) override {
        ++scalars;
        return this;
    }
    void *NewSequence(const YAML::Mark &, const std::string &, void *) override {
        ++sequences;
        return this;
    }
    void AppendToSequence(void *, void *) override {}
    void SequenceComplete(void *) override {}
    void *NewMap(const YAML::Mark &, const std::string &, void *) override {
        ++maps;
        return this;
    }
    void AssignInMap(void *, void *, void *) override {}
    void MapComplete(void *) override {}
    void *AnchorReference(const YAML::Mark &, void *node) override { return node; }
};

bool builds_a_graph() {
    std::istringstream in("a: [1, 2]\nb: {c: 3}\n");
    YAML::Parser parser(in);
    Counter counter;
    if (YAML::BuildGraphOfNextDocument(parser, counter) == nullptr) return false;
    // keys a, b, c and values 1, 2, 3
    return counter.scalars == 6 && counter.sequences == 1 && counter.maps == 2;
}

// 0.9.0 formats floating point by the shortest representation that reads
// back to the same value; 0.8.0 printed max_digits10 digits
// ("0.10000000000000001"). The emitter uses the same routine.
bool formats_floats_shortest() {
    if (YAML::FpToString(0.1) != "0.1") return false;
    if (YAML::FpToString(1.5f) != "1.5") return false;
    YAML::Emitter out;
    out << 0.1;
    return std::string(out.c_str()) == "0.1";
}

}  // namespace

int main() {
    struct Check {
        const char *name;
        bool (*run)();
    } checks[] = {
        {"loads_and_converts", loads_and_converts},
        {"resolves_aliases", resolves_aliases},
        {"loads_every_document", loads_every_document},
        {"emits_and_round_trips", emits_and_round_trips},
        {"rejects_malformed_input", rejects_malformed_input},
        {"builds_a_graph", builds_a_graph},
        {"formats_floats_shortest", formats_floats_shortest},
    };
    bool ok = true;
    for (const Check &c : checks) {
        const bool passed = c.run();
        std::printf("%s %s\n", passed ? "ok  " : "FAIL", c.name);
        ok = ok && passed;
    }
    return ok ? 0 : 1;
}
