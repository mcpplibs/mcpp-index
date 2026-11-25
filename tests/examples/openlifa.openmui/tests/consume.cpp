import std;
import openmui.spec;

namespace spec = omui::spec;

int main() {
    const auto actor = spec::Actor::parse("agent:reader;via=person:alice,agent:planner");
    if (!actor || actor->via.size() != 2 || actor->text() != "agent:reader;via=person:alice,agent:planner") return 1;
    spec::SemanticNode n;
    n.id = "notes/delete";
    n.role = spec::Role::button;
    n.name = "Delete";
    n.actions.push_back({.name = "activate", .effect = spec::Effect::irreversible, .verb = "note.delete", .answer = "yes"});
    if (!spec::check(n).empty()) return 2;
    if (spec::catalog::find("slider") == nullptr) return 3;
    spec::Envelope e;
    e.error(spec::error_code::needs_answer, "confirm").result(spec::exit_code::needs_answer);
    if (e.exit_code() != 2) return 4;
    std::println("{}", e.ndjson());
    return 0;
}
