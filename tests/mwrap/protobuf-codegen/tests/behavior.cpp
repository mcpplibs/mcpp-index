// Generated code beside the module: addressbook.pb.h comes from protoc during
// the build. The prelude (every header the modules include) first, then the
// generated header, then the import — GCC needs every #include before it.
#if defined(HAVE_PROTOC)
#include <mwrap/protobuf/prelude.hpp>
#include "addressbook.pb.h"

import std;
import mcpplibs.mwrap.protobuf;

namespace gpb = google::protobuf;

int main() {
    tutorial::AddressBook book;
    tutorial::Person* ada = book.add_people();
    ada->set_name("Ada Lovelace");
    ada->set_id(1815);
    ada->add_phones()->set_type(tutorial::Person::PHONE_TYPE_HOME);
    const bool stamped = gpb::util::TimeUtil::FromString("1843-07-01T00:00:00Z", ada->mutable_last_updated());
    tutorial::AddressBook back;
    const bool ok = stamped && back.ParseFromString(book.SerializeAsString()) &&
                    gpb::util::MessageDifferencer::Equals(book, back) && back.people(0).id() == 1815 &&
                    tutorial::Person::descriptor()->full_name() == "tutorial.Person";
    std::println("{}", ok ? "protobuf-codegen: generated messages round-trip" : "protobuf-codegen: FAILED");
    return ok ? 0 : 1;
}
#else
int main() { return 0; }  // Windows: no protoc yet; the rule package was built above
#endif
