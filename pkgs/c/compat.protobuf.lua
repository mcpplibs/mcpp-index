-- compat.protobuf — Protocol Buffers 35.1 C++ RUNTIME (libprotobuf), built
-- straight from the upstream release tarball as one static archive.
--
-- Shape A (C++ source compat). Three properties of the upstream release make
-- this possible without a configure step or an external build system:
--
--   1. protobuf-35.1.tar.gz is a real published release asset (not the GitHub
--      tag archive) and is self-contained: no submodules, and third_party/
--      carries utf8_range as actual source.
--   2. The 14 .pb.cc files for the well-known types AND descriptor.pb.cc are
--      CHECKED IN upstream, so building the runtime needs no protoc — there is
--      no bootstrap problem to solve here.
--   3. Platform handling is entirely in-source `#ifdef` (port_def.inc), so one
--      source list covers linux/macosx/windows and the three xpm blocks share
--      a single tarball and sha256.
--
-- SCOPE — runtime by default, compiler on request. This package builds
-- upstream's `libprotobuf` target (79 TUs) unconditionally: messages,
-- reflection, descriptors, text/JSON formats, the well-known types — what a
-- program that *uses* generated code needs.
--
-- Since mcpp 2026.8.5.1 it ALSO offers `protoc` as a host tool, behind the
-- `protoc` feature (upstream's `libprotoc`, 138 further TUs). A consumer that
-- only links the runtime compiles none of them:
--
--     compat.protobuf = { version = "35.1", tools = ["protoc"] }
--
-- That replaces the old advice of "check in protoc output, or fetch the
-- official protoc-35.1-<platform>.zip and keep its version in step by hand".
-- Keeping it in step by hand is precisely the failure this removes: a protoc
-- that disagrees with the runtime fails at RUNTIME, and here the tool's
-- version IS this package's version, so the mismatch cannot be expressed.
--
-- Version numbering follows upstream verbatim: `35.1` is the protobuf release,
-- and it is what gRPC 1.83.0 pins (its third_party/protobuf submodule is
-- exactly tag v35.1, commit 35cd01f). The Abseil dependency is pinned to the
-- same LTS both agree on — protobuf's MODULE.bazel says `abseil-cpp
-- 20250512.1` and gRPC's submodule resolves to the same release — so a future
-- gRPC package links ONE Abseil rather than colliding with a second copy.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "protobuf",
    description = "Protocol Buffers — Google's data interchange format, C++ runtime (libprotobuf 35.1, static)",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/protocolbuffers/protobuf",
    type        = "package",

    xpm = {
        linux = {
            ["35.1"] = {
                url = {
                    GLOBAL = "https://github.com/protocolbuffers/protobuf/releases/download/v35.1/protobuf-35.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/protobuf/releases/download/35.1/protobuf-35.1.tar.gz",
                },
                sha256 = "f0b6838e7522a8da96126d487068c959bc624926368f3024ac8fd03abd0a1ac4",
            },
        },
        macosx = {
            ["35.1"] = {
                url = {
                    GLOBAL = "https://github.com/protocolbuffers/protobuf/releases/download/v35.1/protobuf-35.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/protobuf/releases/download/35.1/protobuf-35.1.tar.gz",
                },
                sha256 = "f0b6838e7522a8da96126d487068c959bc624926368f3024ac8fd03abd0a1ac4",
            },
        },
        windows = {
            ["35.1"] = {
                url = {
                    GLOBAL = "https://github.com/protocolbuffers/protobuf/releases/download/v35.1/protobuf-35.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/protobuf/releases/download/35.1/protobuf-35.1.tar.gz",
                },
                sha256 = "f0b6838e7522a8da96126d487068c959bc624926368f3024ac8fd03abd0a1ac4",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",       -- for third_party/utf8_range/utf8_range.c

        -- `*/src` carries the public <google/protobuf/…> headers;
        -- `*/third_party/utf8_range` carries utf8_range.h + utf8_validity.h,
        -- which protobuf's own TUs include unqualified.
        --
        -- The last two exist for the `upb` feature but are declared
        -- unconditionally: `features` can gate sources/defines/deps, not
        -- include dirs, and the feature's own TUs need them to compile. Both
        -- are additive rather than shadowing — the tarball root supplies only
        -- `upb/…` (protobuf's C++ headers live under src/, not at the root),
        -- and the bootstrap dir supplies `google/protobuf/descriptor.upb*.h`,
        -- a different file name from the C++ `descriptor.h` next door.
        include_dirs = {
            "*/src",
            "*/third_party/utf8_range",
            "*",                        -- upb/… headers
            "*/upb/reflection/cmake",   -- google/protobuf/descriptor.upb*.h
        },

        -- Transcribed from upstream's own authoritative list — the
        -- `libprotobuf_srcs` set in src/file_lists.cmake, which upstream
        -- auto-generates from its Bazel rules. Listed file-by-file rather than
        -- globbed on purpose: `src/google/protobuf/**/*.cc` would also sweep in
        -- libprotoc and the unit tests, and two of the runtime's own TUs live
        -- under compiler/ (importer.cc, parser.cc — the .proto text parser is
        -- part of the runtime), so no directory-level glob separates the two
        -- libraries cleanly. libprotobuf_lite_srcs is a strict subset of this
        -- list, so the lite variant needs no separate handling.
        sources = {
            -- well-known types + descriptor: generated, but CHECKED IN upstream
            "*/src/google/protobuf/any.pb.cc",
            "*/src/google/protobuf/api.pb.cc",
            "*/src/google/protobuf/duration.pb.cc",
            "*/src/google/protobuf/empty.pb.cc",
            "*/src/google/protobuf/field_mask.pb.cc",
            "*/src/google/protobuf/source_context.pb.cc",
            "*/src/google/protobuf/struct.pb.cc",
            "*/src/google/protobuf/timestamp.pb.cc",
            "*/src/google/protobuf/type.pb.cc",
            "*/src/google/protobuf/wrappers.pb.cc",
            "*/src/google/protobuf/cpp_features.pb.cc",
            "*/src/google/protobuf/descriptor.pb.cc",
            -- runtime core
            "*/src/google/protobuf/any.cc",
            "*/src/google/protobuf/any_lite.cc",
            "*/src/google/protobuf/arena.cc",
            "*/src/google/protobuf/arena_align.cc",
            "*/src/google/protobuf/arenastring.cc",
            "*/src/google/protobuf/arenaz_sampler.cc",
            "*/src/google/protobuf/compiler/importer.cc",
            "*/src/google/protobuf/compiler/parser.cc",
            "*/src/google/protobuf/descriptor.cc",
            "*/src/google/protobuf/descriptor_database.cc",
            "*/src/google/protobuf/dynamic_message.cc",
            "*/src/google/protobuf/extension_set.cc",
            "*/src/google/protobuf/extension_set_heavy.cc",
            "*/src/google/protobuf/feature_resolver.cc",
            "*/src/google/protobuf/generated_enum_util.cc",
            "*/src/google/protobuf/generated_message_bases.cc",
            "*/src/google/protobuf/generated_message_reflection.cc",
            "*/src/google/protobuf/generated_message_tctable_full.cc",
            "*/src/google/protobuf/generated_message_tctable_gen.cc",
            "*/src/google/protobuf/generated_message_tctable_lite.cc",
            "*/src/google/protobuf/generated_message_util.cc",
            "*/src/google/protobuf/implicit_weak_message.cc",
            "*/src/google/protobuf/inlined_string_field.cc",
            "*/src/google/protobuf/internal_feature_helper.cc",
            "*/src/google/protobuf/map.cc",
            "*/src/google/protobuf/map_field.cc",
            "*/src/google/protobuf/message.cc",
            "*/src/google/protobuf/message_lite.cc",
            "*/src/google/protobuf/micro_string.cc",
            "*/src/google/protobuf/parse_context.cc",
            "*/src/google/protobuf/port.cc",
            "*/src/google/protobuf/raw_ptr.cc",
            "*/src/google/protobuf/reflection_mode.cc",
            "*/src/google/protobuf/reflection_ops.cc",
            "*/src/google/protobuf/repeated_field.cc",
            "*/src/google/protobuf/repeated_ptr_field.cc",
            "*/src/google/protobuf/service.cc",
            "*/src/google/protobuf/stubs/common.cc",
            "*/src/google/protobuf/symbol_checker.cc",
            "*/src/google/protobuf/text_format.cc",
            "*/src/google/protobuf/unknown_field_set.cc",
            "*/src/google/protobuf/wire_format.cc",
            "*/src/google/protobuf/wire_format_lite.cc",
            -- io
            "*/src/google/protobuf/io/coded_stream.cc",
            "*/src/google/protobuf/io/gzip_stream.cc",   -- empty TU unless the `gzip` feature is on
            "*/src/google/protobuf/io/io_win32.cc",
            "*/src/google/protobuf/io/printer.cc",
            "*/src/google/protobuf/io/strtod.cc",
            "*/src/google/protobuf/io/tokenizer.cc",
            "*/src/google/protobuf/io/zero_copy_sink.cc",
            "*/src/google/protobuf/io/zero_copy_stream.cc",
            "*/src/google/protobuf/io/zero_copy_stream_impl.cc",
            "*/src/google/protobuf/io/zero_copy_stream_impl_lite.cc",
            -- json
            "*/src/google/protobuf/json/json.cc",
            "*/src/google/protobuf/json/internal/lexer.cc",
            "*/src/google/protobuf/json/internal/message_path.cc",
            "*/src/google/protobuf/json/internal/parser.cc",
            "*/src/google/protobuf/json/internal/unparser.cc",
            "*/src/google/protobuf/json/internal/untyped_message.cc",
            "*/src/google/protobuf/json/internal/writer.cc",
            "*/src/google/protobuf/json/internal/zero_copy_buffered_stream.cc",
            -- util
            "*/src/google/protobuf/util/delimited_message_util.cc",
            "*/src/google/protobuf/util/field_comparator.cc",
            "*/src/google/protobuf/util/field_mask_util.cc",
            "*/src/google/protobuf/util/message_differencer.cc",
            "*/src/google/protobuf/util/time_util.cc",
            "*/src/google/protobuf/util/type_resolver_util.cc",

            -- utf8_range: upstream's CMakeLists builds BOTH the `utf8_range`
            -- and `utf8_validity` targets from this one file. Every other .c
            -- in that directory (naive/lookup/lemire-*/range-*) is a
            -- benchmark alternative, and main.c is a benchmark driver whose
            -- main() would collide with the consumer's.
            "*/third_party/utf8_range/utf8_range.c",
        },

        targets = {
            ["protobuf"] = { kind = "lib" },
            -- #355 (mcpp 2026.8.5.1+): protoc as a HOST tool a consumer can ask
            -- for, so it never has to supply a matching one by hand:
            --
            --   compat.protobuf = { version = "35.1", tools = ["protoc"] }
            --
            -- The version axis is what matters here. protoc generating code for
            -- a DIFFERENT protobuf runtime than the one being linked fails at
            -- RUNTIME, not at compile time, and is the single nastiest thing
            -- about hand-managed protobuf codegen. Because the tool's version
            -- IS this package's version, that mismatch is not expressible.
            --
            -- `required_features` is a GATE in an ordinary build (the target is
            -- simply absent) and an INPUT in a tool sub-build (the target is
            -- what was asked for, so mcpp activates them). Both are needed:
            -- `protoc` for libprotoc itself, `upb` because libprotoc's upb
            -- generator links the upb runtime — leaving it out fails at LINK
            -- with undefined upb_* symbols.
            ["protoc"] = {
                kind              = "bin",
                main              = "*/src/google/protobuf/compiler/main.cc",
                required_features = { "protoc", "upb" },
            },
        },

        -- protobuf's public headers #include "absl/…" directly, so Abseil is
        -- part of this package's interface, not an implementation detail.
        deps = { ["compat.abseil"] = "20250512.1" },

        features = {
            -- #355: libprotoc — the protobuf COMPILER library, which the `protoc`
            -- target links. 138 TUs, transcribed from upstream's own
            -- `src/file_lists.cmake` `libprotoc_srcs` (not hand-picked), and with
            -- ZERO overlap against the runtime source set above: importer.cc and
            -- parser.cc are already there.
            --
            -- Off by default, and that is the whole point — a consumer that only
            -- links the protobuf runtime must not compile these.
            ["protoc"] = {
                sources = {
        "*/src/google/protobuf/compiler/code_generator.cc",
        "*/src/google/protobuf/compiler/code_generator_lite.cc",
        "*/src/google/protobuf/compiler/command_line_interface.cc",
        "*/src/google/protobuf/compiler/cpp/enum.cc",
        "*/src/google/protobuf/compiler/cpp/extension.cc",
        "*/src/google/protobuf/compiler/cpp/field.cc",
        "*/src/google/protobuf/compiler/cpp/field_chunk.cc",
        "*/src/google/protobuf/compiler/cpp/field_generators/cord_field.cc",
        "*/src/google/protobuf/compiler/cpp/field_generators/enum_field.cc",
        "*/src/google/protobuf/compiler/cpp/field_generators/map_field.cc",
        "*/src/google/protobuf/compiler/cpp/field_generators/message_field.cc",
        "*/src/google/protobuf/compiler/cpp/field_generators/primitive_field.cc",
        "*/src/google/protobuf/compiler/cpp/field_generators/string_field.cc",
        "*/src/google/protobuf/compiler/cpp/field_generators/string_view_field.cc",
        "*/src/google/protobuf/compiler/cpp/file.cc",
        "*/src/google/protobuf/compiler/cpp/generator.cc",
        "*/src/google/protobuf/compiler/cpp/helpers.cc",
        "*/src/google/protobuf/compiler/cpp/ifndef_guard.cc",
        "*/src/google/protobuf/compiler/cpp/message.cc",
        "*/src/google/protobuf/compiler/cpp/message_layout_helper.cc",
        "*/src/google/protobuf/compiler/cpp/namespace_printer.cc",
        "*/src/google/protobuf/compiler/cpp/parse_function_generator.cc",
        "*/src/google/protobuf/compiler/cpp/service.cc",
        "*/src/google/protobuf/compiler/cpp/tracker.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_doc_comment.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_enum.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_enum_field.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_field_base.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_generator.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_helpers.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_map_field.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_message.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_message_field.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_primitive_field.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_reflection_class.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_repeated_enum_field.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_repeated_message_field.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_repeated_primitive_field.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_source_generator_base.cc",
        "*/src/google/protobuf/compiler/csharp/csharp_wrapper_field.cc",
        "*/src/google/protobuf/compiler/csharp/names.cc",
        "*/src/google/protobuf/compiler/java/context.cc",
        "*/src/google/protobuf/compiler/java/doc_comment.cc",
        "*/src/google/protobuf/compiler/java/field_common.cc",
        "*/src/google/protobuf/compiler/java/file.cc",
        "*/src/google/protobuf/compiler/java/full/enum.cc",
        "*/src/google/protobuf/compiler/java/full/enum_field.cc",
        "*/src/google/protobuf/compiler/java/full/extension.cc",
        "*/src/google/protobuf/compiler/java/full/generator_factory.cc",
        "*/src/google/protobuf/compiler/java/full/make_field_gens.cc",
        "*/src/google/protobuf/compiler/java/full/map_field.cc",
        "*/src/google/protobuf/compiler/java/full/message.cc",
        "*/src/google/protobuf/compiler/java/full/message_builder.cc",
        "*/src/google/protobuf/compiler/java/full/message_field.cc",
        "*/src/google/protobuf/compiler/java/full/primitive_field.cc",
        "*/src/google/protobuf/compiler/java/full/service.cc",
        "*/src/google/protobuf/compiler/java/full/string_field.cc",
        "*/src/google/protobuf/compiler/java/generator.cc",
        "*/src/google/protobuf/compiler/java/helpers.cc",
        "*/src/google/protobuf/compiler/java/internal_helpers.cc",
        "*/src/google/protobuf/compiler/java/java_features.pb.cc",
        "*/src/google/protobuf/compiler/java/lite/enum.cc",
        "*/src/google/protobuf/compiler/java/lite/enum_field.cc",
        "*/src/google/protobuf/compiler/java/lite/extension.cc",
        "*/src/google/protobuf/compiler/java/lite/generator_factory.cc",
        "*/src/google/protobuf/compiler/java/lite/make_field_gens.cc",
        "*/src/google/protobuf/compiler/java/lite/map_field.cc",
        "*/src/google/protobuf/compiler/java/lite/message.cc",
        "*/src/google/protobuf/compiler/java/lite/message_builder.cc",
        "*/src/google/protobuf/compiler/java/lite/message_field.cc",
        "*/src/google/protobuf/compiler/java/lite/primitive_field.cc",
        "*/src/google/protobuf/compiler/java/lite/string_field.cc",
        "*/src/google/protobuf/compiler/java/message_serialization.cc",
        "*/src/google/protobuf/compiler/java/name_resolver.cc",
        "*/src/google/protobuf/compiler/java/names.cc",
        "*/src/google/protobuf/compiler/java/shared_code_generator.cc",
        "*/src/google/protobuf/compiler/kotlin/field.cc",
        "*/src/google/protobuf/compiler/kotlin/file.cc",
        "*/src/google/protobuf/compiler/kotlin/generator.cc",
        "*/src/google/protobuf/compiler/kotlin/message.cc",
        "*/src/google/protobuf/compiler/objectivec/enum.cc",
        "*/src/google/protobuf/compiler/objectivec/enum_field.cc",
        "*/src/google/protobuf/compiler/objectivec/extension.cc",
        "*/src/google/protobuf/compiler/objectivec/field.cc",
        "*/src/google/protobuf/compiler/objectivec/file.cc",
        "*/src/google/protobuf/compiler/objectivec/generator.cc",
        "*/src/google/protobuf/compiler/objectivec/helpers.cc",
        "*/src/google/protobuf/compiler/objectivec/import_writer.cc",
        "*/src/google/protobuf/compiler/objectivec/line_consumer.cc",
        "*/src/google/protobuf/compiler/objectivec/map_field.cc",
        "*/src/google/protobuf/compiler/objectivec/message.cc",
        "*/src/google/protobuf/compiler/objectivec/message_field.cc",
        "*/src/google/protobuf/compiler/objectivec/names.cc",
        "*/src/google/protobuf/compiler/objectivec/oneof.cc",
        "*/src/google/protobuf/compiler/objectivec/primitive_field.cc",
        "*/src/google/protobuf/compiler/objectivec/tf_decode_data.cc",
        "*/src/google/protobuf/compiler/php/names.cc",
        "*/src/google/protobuf/compiler/php/php_generator.cc",
        "*/src/google/protobuf/compiler/plugin.cc",
        "*/src/google/protobuf/compiler/plugin.pb.cc",
        "*/src/google/protobuf/compiler/python/generator.cc",
        "*/src/google/protobuf/compiler/python/helpers.cc",
        "*/src/google/protobuf/compiler/python/pyi_generator.cc",
        "*/src/google/protobuf/compiler/retention.cc",
        "*/src/google/protobuf/compiler/ruby/rbs_generator.cc",
        "*/src/google/protobuf/compiler/ruby/ruby_generator.cc",
        "*/src/google/protobuf/compiler/rust/accessors/accessor_case.cc",
        "*/src/google/protobuf/compiler/rust/accessors/accessors.cc",
        "*/src/google/protobuf/compiler/rust/accessors/default_value.cc",
        "*/src/google/protobuf/compiler/rust/accessors/map.cc",
        "*/src/google/protobuf/compiler/rust/accessors/repeated_field.cc",
        "*/src/google/protobuf/compiler/rust/accessors/singular_cord.cc",
        "*/src/google/protobuf/compiler/rust/accessors/singular_message.cc",
        "*/src/google/protobuf/compiler/rust/accessors/singular_scalar.cc",
        "*/src/google/protobuf/compiler/rust/accessors/singular_string.cc",
        "*/src/google/protobuf/compiler/rust/accessors/unsupported_field.cc",
        "*/src/google/protobuf/compiler/rust/accessors/with_presence.cc",
        "*/src/google/protobuf/compiler/rust/context.cc",
        "*/src/google/protobuf/compiler/rust/crate_mapping.cc",
        "*/src/google/protobuf/compiler/rust/enum.cc",
        "*/src/google/protobuf/compiler/rust/extension.cc",
        "*/src/google/protobuf/compiler/rust/generator.cc",
        "*/src/google/protobuf/compiler/rust/message.cc",
        "*/src/google/protobuf/compiler/rust/naming.cc",
        "*/src/google/protobuf/compiler/rust/oneof.cc",
        "*/src/google/protobuf/compiler/rust/relative_path.cc",
        "*/src/google/protobuf/compiler/rust/rust_field_type.cc",
        "*/src/google/protobuf/compiler/rust/rust_keywords.cc",
        "*/src/google/protobuf/compiler/rust/upb_helpers.cc",
        "*/src/google/protobuf/compiler/subprocess.cc",
        "*/src/google/protobuf/compiler/versions.cc",
        "*/src/google/protobuf/compiler/zip_writer.cc",
        "*/upb_generator/common.cc",
        "*/upb_generator/common/names.cc",
        "*/upb_generator/file_layout.cc",
        "*/upb_generator/minitable/names.cc",
        "*/upb_generator/minitable/names_internal.cc",
        "*/upb_generator/plugin.cc",
                },
            },
            -- GzipInputStream / GzipOutputStream. io/gzip_stream.cc is wrapped
            -- head-to-toe in `#if HAVE_ZLIB`, so by default it compiles to an
            -- empty TU and the package carries no zlib dependency at all;
            -- turning the feature on defines the macro for protobuf's own TUs
            -- and pulls the provider. (`defines` reaches only this package's
            -- TUs, which is exactly the scope needed — the switch is read by
            -- gzip_stream.cc, never by consumer code.)
            ["gzip"] = {
                defines = { "HAVE_ZLIB=1" },
                deps    = { ["compat.zlib"] = "1.3.2" },
            },

            -- upb — protobuf's small C runtime, vendored in the SAME tarball
            -- (upb/ at the root) since protobuf v22 absorbed it. Off by
            -- default: nothing in the C++ runtime uses it, and it is 64 extra
            -- C TUs. gRPC is the consumer that needs it — its generated
            -- src/core/ext/upb-gen/**.c is upb code and links against this
            -- runtime.
            --
            -- The list is transcribed from upstream's `libupb_srcs`
            -- (src/file_lists.cmake) rather than globbed, and that is not
            -- fussiness: `upb/**/*.c` would pull in 14 more files, among them
            -- TWO ALTERNATIVE BUILDS of the descriptor tables
            -- (upb/reflection/stage0/… and upb/reflection/cmake/…) plus
            -- upb/message/promote.c and the decode_fast/ variants. Compiling
            -- more than one descriptor variant is a duplicate-symbol link
            -- failure.
            --
            -- descriptor.upb_minitable.c IS included even though it is not in
            -- libupb_srcs: upstream's cmake/libupb.cmake adds exactly this
            -- file as `bootstrap_sources` on top of the list, because
            -- upb/reflection/descriptor_bootstrap.h — reached by the whole
            -- reflection layer — needs the descriptor tables. Without it the
            -- feature builds and only fails at link time.
            ["upb"] = {
                sources = {
                    "*/upb/base/status.c",
                    "*/upb/hash/common.c",
                    "*/upb/json/decode.c",
                    "*/upb/json/encode.c",
                    "*/upb/lex/atoi.c",
                    "*/upb/lex/round_trip.c",
                    "*/upb/lex/strtod.c",
                    "*/upb/lex/unicode.c",
                    "*/upb/mem/alloc.c",
                    "*/upb/mem/arena.c",
                    "*/upb/message/accessors.c",
                    "*/upb/message/array.c",
                    "*/upb/message/compare.c",
                    "*/upb/message/compat.c",
                    "*/upb/message/copy.c",
                    "*/upb/message/internal/compare_unknown.c",
                    "*/upb/message/internal/extension.c",
                    "*/upb/message/internal/iterator.c",
                    "*/upb/message/internal/message.c",
                    "*/upb/message/map.c",
                    "*/upb/message/map_sorter.c",
                    "*/upb/message/merge.c",
                    "*/upb/message/message.c",
                    "*/upb/mini_descriptor/build_enum.c",
                    "*/upb/mini_descriptor/decode.c",
                    "*/upb/mini_descriptor/internal/base92.c",
                    "*/upb/mini_descriptor/internal/encode.c",
                    "*/upb/mini_descriptor/link.c",
                    "*/upb/mini_table/compat.c",
                    "*/upb/mini_table/debug_string.c",
                    "*/upb/mini_table/extension_registry.c",
                    "*/upb/mini_table/generated_registry.c",
                    "*/upb/mini_table/internal/message.c",
                    "*/upb/mini_table/message.c",
                    "*/upb/reflection/def_pool.c",
                    "*/upb/reflection/def_type.c",
                    "*/upb/reflection/desc_state.c",
                    "*/upb/reflection/enum_def.c",
                    "*/upb/reflection/enum_reserved_range.c",
                    "*/upb/reflection/enum_value_def.c",
                    "*/upb/reflection/extension_range.c",
                    "*/upb/reflection/field_def.c",
                    "*/upb/reflection/file_def.c",
                    "*/upb/reflection/internal/def_builder.c",
                    "*/upb/reflection/internal/strdup2.c",
                    "*/upb/reflection/message.c",
                    "*/upb/reflection/message_def.c",
                    "*/upb/reflection/message_reserved_range.c",
                    "*/upb/reflection/method_def.c",
                    "*/upb/reflection/oneof_def.c",
                    "*/upb/reflection/service_def.c",
                    "*/upb/text/debug_string.c",
                    "*/upb/text/encode.c",
                    "*/upb/text/internal/encode.c",
                    "*/upb/util/def_to_proto.c",
                    "*/upb/util/required_fields.c",
                    "*/upb/wire/byte_size.c",
                    "*/upb/wire/decode.c",
                    "*/upb/wire/decode_fast/select.c",
                    "*/upb/wire/encode.c",
                    "*/upb/wire/eps_copy_input_stream.c",
                    "*/upb/wire/internal/decoder.c",
                    "*/upb/wire/reader.c",
                    -- upstream's bootstrap_sources (cmake/libupb.cmake)
                    "*/upb/reflection/cmake/google/protobuf/descriptor.upb_minitable.c",
                },
            },
        },

        linux = {
            ldflags = { "-lpthread" },
        },
        -- macOS: libSystem carries pthread, and the CoreFoundation framework
        -- the time zone lookup needs comes in through compat.abseil.
        windows = {
            -- Same <windows.h> min/max macro hazard as compat.abseil: protobuf
            -- reaches <windows.h> through io/io_win32.cc and port.h while using
            -- std::min/std::max throughout. Upstream's CMake does not spell
            -- NOMINMAX out because its Abseil dependency's copts already do;
            -- here each package carries its own compile flags, so it has to be
            -- stated. No extra import libs: -ladvapi32 arrives with abseil.
            cxxflags = { "-DNOMINMAX", "-DWIN32_LEAN_AND_MEAN", "-D_CRT_SECURE_NO_WARNINGS" },

            -- NO `protoc` TARGET ON WINDOWS — a platform `targets` replaces the
            -- top-level one, so this drops the tool while keeping the library.
            --
            -- Not a protobuf problem and not a flags problem: the tool SUB-BUILD
            -- fails there. In the same CI run, tests/examples/protobuf,
            -- protobuf-upb and protobuf-gzip all pass on windows — the very same
            -- abseil + protobuf sources, built as an ordinary dependency. Only
            -- the sub-build dies, and only on three abseil TUs whose `.ddi` scan
            -- outputs never appear:
            --
            --   error: building host tool 'compat.protobuf:protoc' failed
            --   error: cannot read 'obj/compat_abseil/…/absl/time/internal/test_util.cc.ddi'
            --   …/cctz/src/time_zone_posix.cc.ddi, …/cctz/src/zone_info_source.cc.ddi
            --
            -- It is NOT path length (MAX_PATH was the obvious guess and it is
            -- wrong: those three relative paths are 31/46/47 chars, while
            -- absl/container/internal/hashtablez_sampler_force_weak_definition.cc
            -- at 67 compiles fine in the same sub-build). The sub-build's inner
            -- ninja output is summarized, so the underlying scan error is not in
            -- the log and the cause is UNKNOWN.
            --
            -- Declaring the target on a platform where it cannot be built would
            -- hand users a failure with no explanation. Left off until the
            -- sub-build issue is diagnosed on a windows host; nothing else about
            -- this descriptor is windows-gated.
            targets = {
                ["protobuf"] = { kind = "lib" },
            },
        },
    },
}
