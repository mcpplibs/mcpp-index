import std;
import openas;
import openas.conformance;

int main() {
    const auto alice = openas::parse("person:alice");
    if (!alice) return 1;
    const auto agent = openas::delegate(*alice, openas::Kind::agent, "claude");
    if (openas::format(agent) != "agent:claude;via=person:alice") return 2;
    const openas::Verb drop{.name = "notes.delete", .summary = "Delete a note", .effect = openas::Effect::irreversible,
                            .options = {{.name = "yes", .flag = true}}, .answers = {"yes"}};
    const auto grant = openas::parse_grant("agent:claude;via=person:alice=irreversible@notes.*");
    if (!grant) return 3;
    if (openas::decide(drop, agent, false, {}, {}) != openas::Decision::ask) return 4;
    if (openas::decide(drop, agent, false, {}, {&*grant, 1}) != openas::Decision::run) return 5;
    if (!openas::conformance::check(std::span<const openas::Verb>(&drop, 1)).ok()) return 6;
    std::println("openas {}: {}", openas::version, openas::format(*grant));
    return 0;
}
