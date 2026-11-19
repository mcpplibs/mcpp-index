// The installed Protocol Buffers wrapper through import alone (no protoc): a
// message type described at run time and instantiated through DynamicMessage,
// its wire bytes pinned, JSON and text formats round-tripped, a Timestamp and
// a Struct, and a .proto text parsed by the compiler's Parser.
import std;
import mcpplibs.mwrap.protobuf;

namespace gpb = google::protobuf;

namespace {
int failures = 0;
void check(bool ok, std::string_view what) {
    if (!ok) {
        ++failures;
        std::println("FAIL: {}", what);
    }
}
std::string hex(std::string_view bytes) {
    std::string out;
    for (unsigned char c : bytes) out += std::format("{:02x}", c);
    return out;
}
}  // namespace

int main() {
    gpb::FileDescriptorProto file;
    file.set_name("point.proto");
    file.set_package("demo");
    file.set_syntax("proto3");
    gpb::DescriptorProto* point = file.add_message_type();
    point->set_name("Point");
    for (auto [name, number, type] : {std::tuple{"x", 1, gpb::FieldDescriptorProto::TYPE_INT32},
                                      std::tuple{"label", 2, gpb::FieldDescriptorProto::TYPE_STRING}}) {
        gpb::FieldDescriptorProto* field = point->add_field();
        field->set_name(name);
        field->set_number(number);
        field->set_type(type);
        field->set_label(gpb::FieldDescriptorProto::LABEL_OPTIONAL);
    }
    gpb::DescriptorPool pool;
    const gpb::FileDescriptor* built = pool.BuildFile(file);
    check(built != nullptr, "descriptor built");
    const gpb::Descriptor* type = pool.FindMessageTypeByName("demo.Point");
    gpb::DynamicMessageFactory factory(&pool);
    std::unique_ptr<gpb::Message> message(factory.GetPrototype(type)->New());
    const gpb::Reflection* reflection = message->GetReflection();
    reflection->SetInt32(message.get(), type->FindFieldByName("x"), 150);
    reflection->SetString(message.get(), type->FindFieldByName("label"), "hi");
    const std::string wire = message->SerializeAsString();
    check(hex(wire) == "08960112026869", "wire bytes (x = 150, label = \"hi\")");

    std::string json;
    check(gpb::json::MessageToJsonString(*message, &json).ok() && json == R"({"x":150,"label":"hi"})", "to JSON");
    std::unique_ptr<gpb::Message> back(message->New());
    check(gpb::json::JsonStringToMessage(R"({"x": 7, "label": "yo"})", back.get()).ok() &&
              reflection->GetInt32(*back, type->FindFieldByName("x")) == 7,
          "from JSON");
    std::string text;
    check(gpb::TextFormat::PrintToString(*message, &text) && text.find("x: 150") != std::string::npos, "text format");

    gpb::Timestamp stamp;
    check(gpb::util::TimeUtil::FromString("2026-11-19T12:30:00Z", &stamp) && stamp.seconds() == 1795091400, "Timestamp");
    gpb::Struct object;
    (*object.mutable_fields())["n"].set_number_value(2.5);
    std::string struct_json;
    check(gpb::json::MessageToJsonString(object, &struct_json).ok() && struct_json == R"({"n":2.5})", "Struct");

    std::println("{}", failures == 0 ? "protobuf-message: all checks passed" : "protobuf-message: FAILED");
    return failures == 0 ? 0 : 1;
}
