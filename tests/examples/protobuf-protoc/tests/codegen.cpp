// Behavioral test for compat.protobuf's `protoc` target.
//
// Every type used here was emitted DURING THIS BUILD by a protoc that mcpp
// compiled from the same package that provides the runtime being linked. The
// test therefore asserts the thing that actually matters about a code
// generator shipped as a dependency: that its output and the runtime agree.
//
// What it drives, and what would break first on a generator/runtime mismatch:
//
//   nested message + accessors    generated_message_reflection.cc
//   enum                          generated_enum_util.cc
//   repeated message field        repeated_ptr_field.cc
//   map field                     map_field.cc
//   oneof                         the generated case() discriminator
//   well-known type import        timestamp.pb.cc  (proves the -I resolved)
//   serialize -> parse round trip wire_format_lite.cc, parse_context.cc
//   reflection over generated msg descriptor.cc against the generated pool
//
// Returns non-zero on any mismatch.
#include <cstdio>
#include <string>

// compat.protobuf declares no `protoc` target on windows, so nothing was
// generated and there is nothing to assert. A loud skip beats a test that
// passes without exercising anything.
#ifdef _WIN32
int main() {
    std::puts("skipped: compat.protobuf has no protoc target on windows");
    return 0;
}
#else

#include "google/protobuf/util/time_util.h"

#include "inventory.pb.h"

namespace {

int failures = 0;

void check(bool ok, const char* what) {
    if (!ok) {
        std::fprintf(stderr, "FAIL: %s\n", what);
        ++failures;
    }
}

}  // namespace

int main() {
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    inventory::Inventory inv;

    inventory::Item* widget = inv.add_items();
    widget->set_sku("WIDGET-1");
    widget->set_quantity(7);
    widget->set_grade(inventory::GRADE_A);
    widget->mutable_dimensions()->set_width(2.5);
    widget->mutable_dimensions()->set_height(4.0);
    widget->set_supplier("acme");

    inventory::Item* gizmo = inv.add_items();
    gizmo->set_sku("GIZMO-2");
    gizmo->set_quantity(3);
    gizmo->set_grade(inventory::GRADE_B);
    gizmo->set_warehouse("east");

    (*inv.mutable_totals_by_grade())["A"] = 7;
    (*inv.mutable_totals_by_grade())["B"] = 3;

    // The well-known type. Reaching this line at all proves protoc resolved
    // the import, and setting it proves timestamp.pb.cc is in the runtime.
    *inv.mutable_updated_at() =
        google::protobuf::util::TimeUtil::SecondsToTimestamp(1735689600);

    std::string wire;
    check(inv.SerializeToString(&wire), "serialize");
    check(!wire.empty(), "wire is non-empty");

    inventory::Inventory back;
    check(back.ParseFromString(wire), "parse");

    check(back.items_size() == 2, "two items survived the round trip");
    check(back.items(0).sku() == "WIDGET-1", "item 0 sku");
    check(back.items(0).quantity() == 7, "item 0 quantity");
    check(back.items(0).grade() == inventory::GRADE_A, "item 0 enum");
    check(back.items(0).dimensions().width() == 2.5, "nested message field");
    check(back.items(0).source_case() == inventory::Item::kSupplier,
          "oneof discriminator (supplier)");
    check(back.items(0).supplier() == "acme", "oneof value");
    check(back.items(1).source_case() == inventory::Item::kWarehouse,
          "oneof discriminator (warehouse)");
    check(back.totals_by_grade().size() == 2, "map size");
    check(back.totals_by_grade().at("A") == 7, "map lookup");
    check(google::protobuf::util::TimeUtil::TimestampToSeconds(
              back.updated_at()) == 1735689600,
          "well-known Timestamp round trip");

    // Reflection over the generated pool: the descriptor protoc emitted has to
    // describe the C++ class it emitted beside it.
    const google::protobuf::Descriptor* d = inventory::Item::descriptor();
    check(d != nullptr && d->full_name() == "inventory.Item",
          "descriptor full name");
    check(d != nullptr && d->FindFieldByName("sku") != nullptr,
          "descriptor knows the sku field");
    check(d != nullptr && d->oneof_decl_count() == 1,
          "descriptor knows the oneof");

    google::protobuf::ShutdownProtobufLibrary();

    if (failures != 0) {
        std::fprintf(stderr, "%d check(s) failed\n", failures);
        return 1;
    }
    std::puts("protoc-generated code round-trips against the linked runtime");
    return 0;
}

#endif  // _WIN32
