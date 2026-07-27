module;

#include <llama.h>
#include <ggml-backend.h>
#include <ggml-alloc.h>

#undef LLAMA_DEFAULT_SEED
#undef LLAMA_TOKEN_NULL
#undef LLAMA_FILE_MAGIC_GGLA
#undef LLAMA_FILE_MAGIC_GGSN
#undef LLAMA_FILE_MAGIC_GGSQ
#undef LLAMA_SESSION_MAGIC
#undef LLAMA_SESSION_VERSION
#undef LLAMA_STATE_SEQ_MAGIC
#undef LLAMA_STATE_SEQ_VERSION
#undef LLAMA_STATE_SEQ_FLAGS_NONE
#undef LLAMA_STATE_SEQ_FLAGS_SWA_ONLY
#undef LLAMA_STATE_SEQ_FLAGS_PARTIAL_ONLY
#undef LLAMA_STATE_SEQ_FLAGS_ON_DEVICE

export module llamacpp;

#include "gen_exports/required_ggml.inc"
#include "gen_exports/llama.inc"

// Typed constant replacements for public preprocessor macros.
// uint32_t and llama_token are provided by <llama.h> (global module fragment).
export inline constexpr uint32_t LLAMA_DEFAULT_SEED   = 0xFFFFFFFFu;
export inline constexpr llama_token  LLAMA_TOKEN_NULL  = -1;

export inline constexpr uint32_t LLAMA_FILE_MAGIC_GGLA  = 0x67676c61u;
export inline constexpr uint32_t LLAMA_FILE_MAGIC_GGSN  = 0x6767736eu;
export inline constexpr uint32_t LLAMA_FILE_MAGIC_GGSQ  = 0x67677371u;
export inline constexpr uint32_t LLAMA_SESSION_MAGIC    = 0x6767736eu;
export inline constexpr uint32_t LLAMA_SESSION_VERSION  = 9u;
export inline constexpr uint32_t LLAMA_STATE_SEQ_MAGIC  = 0x67677371u;
export inline constexpr uint32_t LLAMA_STATE_SEQ_VERSION = 2u;

export inline constexpr llama_state_seq_flags LLAMA_STATE_SEQ_FLAGS_NONE          = 0u;
export inline constexpr llama_state_seq_flags LLAMA_STATE_SEQ_FLAGS_SWA_ONLY      = 1u;
export inline constexpr llama_state_seq_flags LLAMA_STATE_SEQ_FLAGS_PARTIAL_ONLY  = 1u;
export inline constexpr llama_state_seq_flags LLAMA_STATE_SEQ_FLAGS_ON_DEVICE     = 2u;
