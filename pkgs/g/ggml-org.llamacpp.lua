-- ggml-org.llamacpp - llama.cpp b10069 registry + inference implementation.
--
-- Consumer syntax:
--     mcpp add ggml-org.llamacpp@b10069
--
-- The default/backend-cpu path uses CPU. backend-metal is supported only on
-- macOS AArch64. build.mcpp rejects every other feature before compilation.

package = {
    spec        = "1",
    namespace   = "ggml-org",
    name        = "llamacpp",
    description = "llama.cpp b10069 registry and inference implementation",
    licenses    = {"MIT"},
    repo        = "https://github.com/ggml-org/llama.cpp",
    type        = "package",

    xpm = {
        linux = {
            ["b10069"] = {
                url = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz",
                sha256 = "293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097",
            },
        },
        macosx = {
            ["b10069"] = {
                url = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz",
                sha256 = "293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097",
            },
        },
        windows = {
            ["b10069"] = {
                url = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz",
                sha256 = "293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097",
            },
        },
    },

    mcpp = {
        c_standard  = "c11",
        language    = "c++23",
        import_std  = false,
        include_dirs = {
            "*/include",
            "*/ggml/include",
            "*/ggml/src",
            "*/ggml/src/ggml-cpu",
            "*/ggml/src/ggml-metal",
            "*/src",
            "mcpp_generated",
        },
        modules = { "llama" },
        generated_files = {
            ["mcpp_generated/ggml_cpp.cpp"] = "#include \"ggml.cpp\"\n",
            ["mcpp_generated/ggml-cpu_cpp.cpp"] = "#include \"ggml-cpu.cpp\"\n",
            ["mcpp_generated/ggml_metal_device_m.m"] = "#include \"ggml-metal-device.m\"\n",
            ["mcpp_generated/ggml_build_info.h"] = [=[
#pragma once
#define GGML_VERSION "b10069"
#define GGML_COMMIT "178a6c44937154dc4c4eff0d166f4a044c4fceba"
]=],
            ["mcpp_generated/llama.cppm"] = [==[
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

export module llama;

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
]==],
            ["mcpp_generated/gen_exports/required_ggml.inc"] = [==[
export using ::GGML_BACKEND_DEVICE_TYPE_ACCEL;
export using ::GGML_BACKEND_DEVICE_TYPE_CPU;
export using ::GGML_BACKEND_DEVICE_TYPE_GPU;
export using ::GGML_LOG_LEVEL_CONT;
export using ::GGML_LOG_LEVEL_DEBUG;
export using ::GGML_LOG_LEVEL_ERROR;
export using ::GGML_LOG_LEVEL_INFO;
export using ::GGML_LOG_LEVEL_NONE;
export using ::GGML_LOG_LEVEL_WARN;
export using ::GGML_NUMA_STRATEGY_COUNT;
export using ::GGML_NUMA_STRATEGY_DISABLED;
export using ::GGML_NUMA_STRATEGY_DISTRIBUTE;
export using ::GGML_NUMA_STRATEGY_ISOLATE;
export using ::GGML_NUMA_STRATEGY_MIRROR;
export using ::GGML_NUMA_STRATEGY_NUMACTL;
export using ::GGML_OPT_OPTIMIZER_TYPE_ADAMW;
export using ::GGML_OPT_OPTIMIZER_TYPE_COUNT;
export using ::GGML_OPT_OPTIMIZER_TYPE_SGD;
export using ::GGML_STATUS_SUCCESS;
export using ::GGML_TYPE_BF16;
export using ::GGML_TYPE_COUNT;
export using ::GGML_TYPE_F16;
export using ::GGML_TYPE_F32;
export using ::GGML_TYPE_F64;
export using ::GGML_TYPE_I16;
export using ::GGML_TYPE_I32;
export using ::GGML_TYPE_I64;
export using ::GGML_TYPE_I8;
export using ::GGML_TYPE_IQ1_M;
export using ::GGML_TYPE_IQ1_S;
export using ::GGML_TYPE_IQ2_S;
export using ::GGML_TYPE_IQ2_XS;
export using ::GGML_TYPE_IQ2_XXS;
export using ::GGML_TYPE_IQ3_S;
export using ::GGML_TYPE_IQ3_XXS;
export using ::GGML_TYPE_IQ4_NL;
export using ::GGML_TYPE_IQ4_XS;
export using ::GGML_TYPE_MXFP4;
export using ::GGML_TYPE_NVFP4;
export using ::GGML_TYPE_Q1_0;
export using ::GGML_TYPE_Q2_0;
export using ::GGML_TYPE_Q2_K;
export using ::GGML_TYPE_Q3_K;
export using ::GGML_TYPE_Q4_0;
export using ::GGML_TYPE_Q4_1;
export using ::GGML_TYPE_Q4_K;
export using ::GGML_TYPE_Q5_0;
export using ::GGML_TYPE_Q5_1;
export using ::GGML_TYPE_Q5_K;
export using ::GGML_TYPE_Q6_K;
export using ::GGML_TYPE_Q8_0;
export using ::GGML_TYPE_Q8_1;
export using ::GGML_TYPE_Q8_K;
export using ::GGML_TYPE_TQ1_0;
export using ::GGML_TYPE_TQ2_0;
export using ::ggml_abort_callback;
export using ::ggml_add;
export using ::ggml_backend_alloc_ctx_tensors;
export using ::ggml_backend_buffer_free;
export using ::ggml_backend_buffer_t;
export using ::ggml_backend_buffer_type_t;
export using ::ggml_backend_dev_init;
export using ::ggml_backend_dev_t;
export using ::ggml_backend_dev_type;
export using ::ggml_backend_free;
export using ::ggml_backend_get_features_t;
export using ::ggml_backend_graph_compute;
export using ::ggml_backend_reg_by_name;
export using ::ggml_backend_reg_dev_count;
export using ::ggml_backend_reg_dev_get;
export using ::ggml_backend_reg_get_proc_address;
export using ::ggml_backend_reg_t;
export using ::ggml_backend_sched_eval_callback;
export using ::ggml_backend_synchronize;
export using ::ggml_backend_t;
export using ::ggml_backend_tensor_get;
export using ::ggml_backend_tensor_set;
export using ::ggml_build_forward_expand;
export using ::ggml_cgraph;
export using ::ggml_context;
export using ::ggml_free;
export using ::ggml_init;
export using ::ggml_init_params;
export using ::ggml_log_callback;
export using ::ggml_log_level;
export using ::ggml_new_graph;
export using ::ggml_new_tensor_1d;
export using ::ggml_numa_strategy;
export using ::ggml_opt_dataset_t;
export using ::ggml_opt_epoch_callback;
export using ::ggml_opt_get_optimizer_params;
export using ::ggml_opt_optimizer_type;
export using ::ggml_opt_result_t;
export using ::ggml_status;
export using ::ggml_tensor;
export using ::ggml_threadpool_t;
export using ::ggml_type;
]==],
            ["mcpp_generated/gen_exports/llama.inc"] = [==[
export using ::LLAMA_ATTENTION_TYPE_CAUSAL;
export using ::LLAMA_ATTENTION_TYPE_NON_CAUSAL;
export using ::LLAMA_ATTENTION_TYPE_UNSPECIFIED;
export using ::LLAMA_CONTEXT_TYPE_DEFAULT;
export using ::LLAMA_CONTEXT_TYPE_MTP;
export using ::LLAMA_FLASH_ATTN_TYPE_AUTO;
export using ::LLAMA_FLASH_ATTN_TYPE_DISABLED;
export using ::LLAMA_FLASH_ATTN_TYPE_ENABLED;
export using ::LLAMA_FTYPE_ALL_F32;
export using ::LLAMA_FTYPE_GUESSED;
export using ::LLAMA_FTYPE_MOSTLY_BF16;
export using ::LLAMA_FTYPE_MOSTLY_F16;
export using ::LLAMA_FTYPE_MOSTLY_IQ1_M;
export using ::LLAMA_FTYPE_MOSTLY_IQ1_S;
export using ::LLAMA_FTYPE_MOSTLY_IQ2_M;
export using ::LLAMA_FTYPE_MOSTLY_IQ2_S;
export using ::LLAMA_FTYPE_MOSTLY_IQ2_XS;
export using ::LLAMA_FTYPE_MOSTLY_IQ2_XXS;
export using ::LLAMA_FTYPE_MOSTLY_IQ3_M;
export using ::LLAMA_FTYPE_MOSTLY_IQ3_S;
export using ::LLAMA_FTYPE_MOSTLY_IQ3_XS;
export using ::LLAMA_FTYPE_MOSTLY_IQ3_XXS;
export using ::LLAMA_FTYPE_MOSTLY_IQ4_NL;
export using ::LLAMA_FTYPE_MOSTLY_IQ4_XS;
export using ::LLAMA_FTYPE_MOSTLY_MXFP4_MOE;
export using ::LLAMA_FTYPE_MOSTLY_NVFP4;
export using ::LLAMA_FTYPE_MOSTLY_Q1_0;
export using ::LLAMA_FTYPE_MOSTLY_Q2_0;
export using ::LLAMA_FTYPE_MOSTLY_Q2_K;
export using ::LLAMA_FTYPE_MOSTLY_Q2_K_S;
export using ::LLAMA_FTYPE_MOSTLY_Q3_K_L;
export using ::LLAMA_FTYPE_MOSTLY_Q3_K_M;
export using ::LLAMA_FTYPE_MOSTLY_Q3_K_S;
export using ::LLAMA_FTYPE_MOSTLY_Q4_0;
export using ::LLAMA_FTYPE_MOSTLY_Q4_1;
export using ::LLAMA_FTYPE_MOSTLY_Q4_K_M;
export using ::LLAMA_FTYPE_MOSTLY_Q4_K_S;
export using ::LLAMA_FTYPE_MOSTLY_Q5_0;
export using ::LLAMA_FTYPE_MOSTLY_Q5_1;
export using ::LLAMA_FTYPE_MOSTLY_Q5_K_M;
export using ::LLAMA_FTYPE_MOSTLY_Q5_K_S;
export using ::LLAMA_FTYPE_MOSTLY_Q6_K;
export using ::LLAMA_FTYPE_MOSTLY_Q8_0;
export using ::LLAMA_FTYPE_MOSTLY_TQ1_0;
export using ::LLAMA_FTYPE_MOSTLY_TQ2_0;
export using ::LLAMA_KV_OVERRIDE_TYPE_BOOL;
export using ::LLAMA_KV_OVERRIDE_TYPE_FLOAT;
export using ::LLAMA_KV_OVERRIDE_TYPE_INT;
export using ::LLAMA_KV_OVERRIDE_TYPE_STR;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_MIN_P;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_MIROSTAT;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_MIROSTAT_ETA;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_MIROSTAT_TAU;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_PENALTY_LAST_N;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_PENALTY_REPEAT;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_SEQUENCE;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_TEMP;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_TOP_K;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_TOP_P;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_XTC_PROBABILITY;
export using ::LLAMA_MODEL_META_KEY_SAMPLING_XTC_THRESHOLD;
export using ::LLAMA_POOLING_TYPE_CLS;
export using ::LLAMA_POOLING_TYPE_LAST;
export using ::LLAMA_POOLING_TYPE_MEAN;
export using ::LLAMA_POOLING_TYPE_NONE;
export using ::LLAMA_POOLING_TYPE_RANK;
export using ::LLAMA_POOLING_TYPE_UNSPECIFIED;
export using ::LLAMA_ROPE_SCALING_TYPE_LINEAR;
export using ::LLAMA_ROPE_SCALING_TYPE_LONGROPE;
export using ::LLAMA_ROPE_SCALING_TYPE_MAX_VALUE;
export using ::LLAMA_ROPE_SCALING_TYPE_NONE;
export using ::LLAMA_ROPE_SCALING_TYPE_UNSPECIFIED;
export using ::LLAMA_ROPE_SCALING_TYPE_YARN;
export using ::LLAMA_ROPE_TYPE_IMROPE;
export using ::LLAMA_ROPE_TYPE_MROPE;
export using ::LLAMA_ROPE_TYPE_NEOX;
export using ::LLAMA_ROPE_TYPE_NONE;
export using ::LLAMA_ROPE_TYPE_NORM;
export using ::LLAMA_ROPE_TYPE_VISION;
export using ::LLAMA_SPLIT_MODE_LAYER;
export using ::LLAMA_SPLIT_MODE_NONE;
export using ::LLAMA_SPLIT_MODE_ROW;
export using ::LLAMA_SPLIT_MODE_TENSOR;
export using ::LLAMA_TOKEN_ATTR_BYTE;
export using ::LLAMA_TOKEN_ATTR_CONTROL;
export using ::LLAMA_TOKEN_ATTR_LSTRIP;
export using ::LLAMA_TOKEN_ATTR_NORMAL;
export using ::LLAMA_TOKEN_ATTR_NORMALIZED;
export using ::LLAMA_TOKEN_ATTR_RSTRIP;
export using ::LLAMA_TOKEN_ATTR_SINGLE_WORD;
export using ::LLAMA_TOKEN_ATTR_UNDEFINED;
export using ::LLAMA_TOKEN_ATTR_UNKNOWN;
export using ::LLAMA_TOKEN_ATTR_UNUSED;
export using ::LLAMA_TOKEN_ATTR_USER_DEFINED;
export using ::LLAMA_TOKEN_TYPE_BYTE;
export using ::LLAMA_TOKEN_TYPE_CONTROL;
export using ::LLAMA_TOKEN_TYPE_NORMAL;
export using ::LLAMA_TOKEN_TYPE_UNDEFINED;
export using ::LLAMA_TOKEN_TYPE_UNKNOWN;
export using ::LLAMA_TOKEN_TYPE_UNUSED;
export using ::LLAMA_TOKEN_TYPE_USER_DEFINED;
export using ::LLAMA_VOCAB_TYPE_BPE;
export using ::LLAMA_VOCAB_TYPE_NONE;
export using ::LLAMA_VOCAB_TYPE_PLAMO2;
export using ::LLAMA_VOCAB_TYPE_RWKV;
export using ::LLAMA_VOCAB_TYPE_SPM;
export using ::LLAMA_VOCAB_TYPE_UGM;
export using ::LLAMA_VOCAB_TYPE_WPM;
export using ::llama_adapter_get_alora_invocation_tokens;
export using ::llama_adapter_get_alora_n_invocation_tokens;
export using ::llama_adapter_lora;
export using ::llama_adapter_lora_free;
export using ::llama_adapter_lora_init;
export using ::llama_adapter_meta_count;
export using ::llama_adapter_meta_key_by_index;
export using ::llama_adapter_meta_val_str;
export using ::llama_adapter_meta_val_str_by_index;
export using ::llama_attach_threadpool;
export using ::llama_attention_type;
export using ::llama_backend_free;
export using ::llama_backend_init;
export using ::llama_batch;
export using ::llama_batch_free;
export using ::llama_batch_get_one;
export using ::llama_batch_init;
export using ::llama_chat_apply_template;
export using ::llama_chat_builtin_templates;
export using ::llama_chat_message;
export using ::llama_context;
export using ::llama_context_default_params;
export using ::llama_context_params;
export using ::llama_context_type;
export using ::llama_decode;
export using ::llama_detach_threadpool;
export using ::llama_detokenize;
export using ::llama_encode;
export using ::llama_flash_attn_type;
export using ::llama_flash_attn_type_name;
export using ::llama_free;
export using ::llama_ftype;
export using ::llama_ftype_name;
export using ::llama_get_embeddings;
export using ::llama_get_embeddings_ith;
export using ::llama_get_embeddings_seq;
export using ::llama_get_logits;
export using ::llama_get_logits_ith;
export using ::llama_get_memory;
export using ::llama_get_model;
export using ::llama_get_sampled_candidates_count_ith;
export using ::llama_get_sampled_candidates_ith;
export using ::llama_get_sampled_logits_count_ith;
export using ::llama_get_sampled_logits_ith;
export using ::llama_get_sampled_probs_count_ith;
export using ::llama_get_sampled_probs_ith;
export using ::llama_get_sampled_token_ith;
export using ::llama_init_from_model;
export using ::llama_log_get;
export using ::llama_log_set;
export using ::llama_logit_bias;
export using ::llama_max_devices;
export using ::llama_max_parallel_sequences;
export using ::llama_max_tensor_buft_overrides;
export using ::llama_memory_can_shift;
export using ::llama_memory_clear;
export using ::llama_memory_i;
export using ::llama_memory_seq_add;
export using ::llama_memory_seq_cp;
export using ::llama_memory_seq_div;
export using ::llama_memory_seq_keep;
export using ::llama_memory_seq_pos_max;
export using ::llama_memory_seq_pos_min;
export using ::llama_memory_seq_rm;
export using ::llama_memory_t;
export using ::llama_model;
export using ::llama_model_chat_template;
export using ::llama_model_cls_label;
export using ::llama_model_decoder_start_token;
export using ::llama_model_default_params;
export using ::llama_model_desc;
export using ::llama_model_free;
export using ::llama_model_ftype;
export using ::llama_model_get_vocab;
export using ::llama_model_has_decoder;
export using ::llama_model_has_encoder;
export using ::llama_model_imatrix_data;
export using ::llama_model_init_from_user;
export using ::llama_model_is_diffusion;
export using ::llama_model_is_hybrid;
export using ::llama_model_is_recurrent;
export using ::llama_model_kv_override;
export using ::llama_model_kv_override_type;
export using ::llama_model_load_from_file;
export using ::llama_model_load_from_file_ptr;
export using ::llama_model_load_from_splits;
export using ::llama_model_meta_count;
export using ::llama_model_meta_key;
export using ::llama_model_meta_key_by_index;
export using ::llama_model_meta_key_str;
export using ::llama_model_meta_val_str;
export using ::llama_model_meta_val_str_by_index;
export using ::llama_model_n_cls_out;
export using ::llama_model_n_ctx_train;
export using ::llama_model_n_embd;
export using ::llama_model_n_embd_inp;
export using ::llama_model_n_embd_out;
export using ::llama_model_n_head;
export using ::llama_model_n_head_kv;
export using ::llama_model_n_layer;
export using ::llama_model_n_layer_nextn;
export using ::llama_model_n_params;
export using ::llama_model_n_swa;
export using ::llama_model_params;
export using ::llama_model_quantize;
export using ::llama_model_quantize_default_params;
export using ::llama_model_quantize_params;
export using ::llama_model_rope_freq_scale_train;
export using ::llama_model_rope_type;
export using ::llama_model_save_to_file;
export using ::llama_model_set_tensor_data_t;
export using ::llama_model_size;
export using ::llama_model_tensor_buft_override;
export using ::llama_model_tensor_override;
export using ::llama_n_batch;
export using ::llama_n_ctx;
export using ::llama_n_ctx_seq;
export using ::llama_n_rs_seq;
export using ::llama_n_seq_max;
export using ::llama_n_threads;
export using ::llama_n_threads_batch;
export using ::llama_n_ubatch;
export using ::llama_numa_init;
export using ::llama_opt_epoch;
export using ::llama_opt_init;
export using ::llama_opt_param_filter;
export using ::llama_opt_param_filter_all;
export using ::llama_opt_params;
export using ::llama_perf_context;
export using ::llama_perf_context_data;
export using ::llama_perf_context_print;
export using ::llama_perf_context_reset;
export using ::llama_perf_sampler;
export using ::llama_perf_sampler_data;
export using ::llama_perf_sampler_print;
export using ::llama_perf_sampler_reset;
export using ::llama_pooling_type;
export using ::llama_pos;
export using ::llama_print_system_info;
export using ::llama_progress_callback;
export using ::llama_rope_scaling_type;
export using ::llama_rope_type;
export using ::llama_sampler;
export using ::llama_sampler_accept;
export using ::llama_sampler_apply;
export using ::llama_sampler_chain_add;
export using ::llama_sampler_chain_default_params;
export using ::llama_sampler_chain_get;
export using ::llama_sampler_chain_init;
export using ::llama_sampler_chain_n;
export using ::llama_sampler_chain_params;
export using ::llama_sampler_chain_remove;
export using ::llama_sampler_clone;
export using ::llama_sampler_context_t;
export using ::llama_sampler_data;
export using ::llama_sampler_free;
export using ::llama_sampler_get_seed;
export using ::llama_sampler_i;
export using ::llama_sampler_init;
export using ::llama_sampler_init_adaptive_p;
export using ::llama_sampler_init_dist;
export using ::llama_sampler_init_dry;
export using ::llama_sampler_init_grammar;
export using ::llama_sampler_init_grammar_lazy_patterns;
export using ::llama_sampler_init_greedy;
export using ::llama_sampler_init_infill;
export using ::llama_sampler_init_logit_bias;
export using ::llama_sampler_init_min_p;
export using ::llama_sampler_init_mirostat;
export using ::llama_sampler_init_mirostat_v2;
export using ::llama_sampler_init_penalties;
export using ::llama_sampler_init_temp;
export using ::llama_sampler_init_temp_ext;
export using ::llama_sampler_init_top_k;
export using ::llama_sampler_init_top_n_sigma;
export using ::llama_sampler_init_top_p;
export using ::llama_sampler_init_typical;
export using ::llama_sampler_init_xtc;
export using ::llama_sampler_name;
export using ::llama_sampler_reset;
export using ::llama_sampler_sample;
export using ::llama_sampler_seq_config;
export using ::llama_seq_id;
export using ::llama_set_abort_callback;
export using ::llama_set_adapter_cvec;
export using ::llama_set_adapters_lora;
export using ::llama_set_causal_attn;
export using ::llama_set_embeddings;
export using ::llama_set_n_threads;
export using ::llama_set_sampler;
export using ::llama_split_mode;
export using ::llama_split_path;
export using ::llama_split_prefix;
export using ::llama_state_get_data;
export using ::llama_state_get_size;
export using ::llama_state_load_file;
export using ::llama_state_save_file;
export using ::llama_state_seq_flags;
export using ::llama_state_seq_get_data;
export using ::llama_state_seq_get_data_ext;
export using ::llama_state_seq_get_size;
export using ::llama_state_seq_get_size_ext;
export using ::llama_state_seq_load_file;
export using ::llama_state_seq_save_file;
export using ::llama_state_seq_set_data;
export using ::llama_state_seq_set_data_ext;
export using ::llama_state_set_data;
export using ::llama_supports_gpu_offload;
export using ::llama_supports_mlock;
export using ::llama_supports_mmap;
export using ::llama_supports_rpc;
export using ::llama_synchronize;
export using ::llama_time_us;
export using ::llama_token;
export using ::llama_token_attr;
export using ::llama_token_data;
export using ::llama_token_data_array;
export using ::llama_token_to_piece;
export using ::llama_token_type;
export using ::llama_tokenize;
export using ::llama_vocab;
export using ::llama_vocab_bos;
export using ::llama_vocab_eos;
export using ::llama_vocab_eot;
export using ::llama_vocab_fim_mid;
export using ::llama_vocab_fim_pad;
export using ::llama_vocab_fim_pre;
export using ::llama_vocab_fim_rep;
export using ::llama_vocab_fim_sep;
export using ::llama_vocab_fim_suf;
export using ::llama_vocab_get_add_bos;
export using ::llama_vocab_get_add_eos;
export using ::llama_vocab_get_add_sep;
export using ::llama_vocab_get_attr;
export using ::llama_vocab_get_score;
export using ::llama_vocab_get_text;
export using ::llama_vocab_is_control;
export using ::llama_vocab_is_eog;
export using ::llama_vocab_mask;
export using ::llama_vocab_n_tokens;
export using ::llama_vocab_nl;
export using ::llama_vocab_pad;
export using ::llama_vocab_sep;
export using ::llama_vocab_type;
]==],
            ["build.mcpp"] = [=[
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iterator>
#include <sstream>
#include <stdexcept>
#include <string>
namespace fs = std::filesystem;
static std::string read_all(const fs::path & path) {
    std::ifstream in(path, std::ios::binary);
    if (!in) throw std::runtime_error("cannot read " + path.string());
    return {std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>()};
}
static void write_all(const fs::path & path, const std::string & value) {
    fs::create_directories(path.parent_path());
    std::ofstream out(path, std::ios::binary | std::ios::trunc);
    out.write(value.data(), static_cast<std::streamsize>(value.size()));
    if (!out) throw std::runtime_error("cannot write " + path.string());
}
static void replace_once(std::string & value, const std::string & marker,
                         const std::string & replacement) {
    auto first = value.find(marker);
    if (first == std::string::npos
        || value.find(marker, first + marker.size()) != std::string::npos) {
        throw std::runtime_error("expected exactly one marker: " + marker);
    }
    value.replace(first, marker.size(), replacement);
}
static std::string asm_quote(std::string value) {
    std::string out;
    for (char c : value) {
        if (c == '\\' || c == '"') out.push_back('\\');
        out.push_back(c);
    }
    return out;
}
static int validate_features() {
    const char * raw = std::getenv("MCPP_FEATURES");
    if (!raw || *raw == '\0') return 0;
    std::istringstream input(raw);
    std::string feature;
    while (std::getline(input, feature, ',')) {
        if (feature.empty() || feature == "backend-cpu" || feature == "backend-metal") {
            continue;
        }
        std::fprintf(stderr,
                     "ggml-org.llamacpp: unsupported feature '%s' "
                     "(supported features: backend-cpu, backend-metal)\n",
                     feature.c_str());
        return 2;
    }
    return 0;
}
int main() try {
    if (int result = validate_features(); result != 0) return result;
    const char * enabled = std::getenv("MCPP_FEATURE_BACKEND_METAL");
    if (!enabled || std::string(enabled) != "1") return 0;
    const char * os = std::getenv("MCPP_TARGET_OS");
    const char * arch = std::getenv("MCPP_TARGET_ARCH");
    const char * manifest = std::getenv("MCPP_MANIFEST_DIR");
    const char * out_env = std::getenv("MCPP_OUT_DIR");
    if (!os || std::string(os) != "macos") {
        std::fprintf(stderr, "ggml-org.llamacpp requires target_os=macos\n");
        return 2;
    }
    if (!arch || std::string(arch) != "aarch64") {
        std::fprintf(stderr, "ggml-org.llamacpp requires target_arch=aarch64\n");
        return 2;
    }
    if (!manifest || !out_env) {
        std::fprintf(stderr, "ggml-org.llamacpp requires MCPP_MANIFEST_DIR and MCPP_OUT_DIR\n");
        return 2;
    }
    fs::path root;
    for (const auto & entry : fs::directory_iterator(manifest)) {
        fs::path candidate = entry.path();
        if (entry.is_directory() && fs::exists(candidate / "ggml/src/ggml-common.h")
            && fs::exists(candidate / "ggml/src/ggml-metal/ggml-metal.metal")) {
            if (!root.empty()) throw std::runtime_error("multiple llama.cpp source roots");
            root = candidate;
        }
    }
    if (root.empty()) throw std::runtime_error("llama.cpp source root not found");
    const fs::path common  = root / "ggml/src/ggml-common.h";
    const fs::path metal   = root / "ggml/src/ggml-metal/ggml-metal.metal";
    const fs::path impl    = root / "ggml/src/ggml-metal/ggml-metal-impl.h";
    const fs::path out     = out_env;
    const fs::path merged  = out / "ggml-metal-embed.metal";
    const fs::path assembly = out / "ggml-metal-embed.s";
    std::string source = read_all(metal);
    replace_once(source, "__embed_ggml-common.h__", read_all(common));
    replace_once(source, "#include \"ggml-metal-impl.h\"", read_all(impl));
    write_all(merged, source);
    std::ostringstream body;
    body << ".section __DATA,__ggml_metallib\n"
         << ".globl _ggml_metallib_start\n"
         << "_ggml_metallib_start:\n"
         << ".incbin \"" << asm_quote(merged.string()) << "\"\n"
         << ".globl _ggml_metallib_end\n"
         << "_ggml_metallib_end:\n";
    write_all(assembly, body.str());
    std::printf("mcpp:generated=%s\n", assembly.string().c_str());
    std::printf("mcpp:cfg=GGML_METAL_EMBED_LIBRARY\n");
    for (const fs::path & input : {common, metal, impl}) {
        std::printf("mcpp:rerun-if-changed=%s\n", input.string().c_str());
    }
    std::fflush(stdout);
    return 0;
} catch (const std::exception & error) {
    std::fprintf(stderr, "ggml-org.llamacpp build.mcpp: %s\n", error.what());
    return 1;
}
]=],
        },
        sources = {
            "*/ggml/src/ggml.c",
            "mcpp_generated/ggml_cpp.cpp",
            "*/ggml/src/ggml-alloc.c",
            "*/ggml/src/ggml-backend.cpp",
            "*/ggml/src/ggml-backend-meta.cpp",
            "*/ggml/src/ggml-opt.cpp",
            "*/ggml/src/ggml-threading.cpp",
            "*/ggml/src/ggml-quants.c",
            "*/ggml/src/gguf.cpp",
            "*/ggml/src/ggml-backend-dl.cpp",
            "*/ggml/src/ggml-backend-reg.cpp",
            "*/ggml/src/ggml-cpu/ggml-cpu.c",
            "mcpp_generated/ggml-cpu_cpp.cpp",
            "*/ggml/src/ggml-cpu/binary-ops.cpp",
            "*/ggml/src/ggml-cpu/hbm.cpp",
            "*/ggml/src/ggml-cpu/ops.cpp",
            "*/ggml/src/ggml-cpu/quants.c",
            "*/ggml/src/ggml-cpu/repack.cpp",
            "*/ggml/src/ggml-cpu/traits.cpp",
            "*/ggml/src/ggml-cpu/unary-ops.cpp",
            "*/ggml/src/ggml-cpu/vec.cpp",
            "*/ggml/src/ggml-cpu/amx/amx.cpp",
            "*/ggml/src/ggml-cpu/amx/mmq.cpp",
            "*/ggml/src/ggml-cpu/llamafile/sgemm.cpp",
            "mcpp_generated/llama.cppm",
            "*/src/llama.cpp",
            "*/src/llama-adapter.cpp",
            "*/src/llama-arch.cpp",
            "*/src/llama-batch.cpp",
            "*/src/llama-chat.cpp",
            "*/src/llama-context.cpp",
            "*/src/llama-cparams.cpp",
            "*/src/llama-grammar.cpp",
            "*/src/llama-graph.cpp",
            "*/src/llama-hparams.cpp",
            "*/src/llama-impl.cpp",
            "*/src/llama-io.cpp",
            "*/src/llama-kv-cache.cpp",
            "*/src/llama-kv-cache-iswa.cpp",
            "*/src/llama-kv-cache-dsa.cpp",
            "*/src/llama-kv-cache-dsv4.cpp",
            "*/src/llama-memory.cpp",
            "*/src/llama-memory-hybrid.cpp",
            "*/src/llama-memory-hybrid-iswa.cpp",
            "*/src/llama-memory-recurrent.cpp",
            "*/src/llama-mmap.cpp",
            "*/src/llama-model-loader.cpp",
            "*/src/llama-model-saver.cpp",
            "*/src/llama-model.cpp",
            "*/src/llama-quant.cpp",
            "*/src/llama-sampler.cpp",
            "*/src/llama-vocab.cpp",
            "*/src/unicode-data.cpp",
            "*/src/unicode.cpp",
        "*/src/models/afmoe.cpp",
        "*/src/models/apertus.cpp",
        "*/src/models/arcee.cpp",
        "*/src/models/arctic.cpp",
        "*/src/models/arwkv7.cpp",
        "*/src/models/baichuan.cpp",
        "*/src/models/bailingmoe.cpp",
        "*/src/models/bailingmoe2.cpp",
        "*/src/models/bert.cpp",
        "*/src/models/bitnet.cpp",
        "*/src/models/bloom.cpp",
        "*/src/models/chameleon.cpp",
        "*/src/models/chatglm.cpp",
        "*/src/models/codeshell.cpp",
        "*/src/models/cogvlm.cpp",
        "*/src/models/cohere2.cpp",
        "*/src/models/cohere2moe.cpp",
        "*/src/models/command-r.cpp",
        "*/src/models/dbrx.cpp",
        "*/src/models/deci.cpp",
        "*/src/models/deepseek.cpp",
        "*/src/models/deepseek2.cpp",
        "*/src/models/deepseek2ocr.cpp",
        "*/src/models/deepseek32.cpp",
        "*/src/models/deepseek4.cpp",
        "*/src/models/delta-net-base.cpp",
        "*/src/models/dflash.cpp",
        "*/src/models/dots1.cpp",
        "*/src/models/dream.cpp",
        "*/src/models/eagle3.cpp",
        "*/src/models/ernie4-5-moe.cpp",
        "*/src/models/ernie4-5.cpp",
        "*/src/models/eurobert.cpp",
        "*/src/models/exaone-moe.cpp",
        "*/src/models/exaone.cpp",
        "*/src/models/exaone4.cpp",
        "*/src/models/falcon-h1.cpp",
        "*/src/models/falcon.cpp",
        "*/src/models/gemma-embedding.cpp",
        "*/src/models/gemma.cpp",
        "*/src/models/gemma2.cpp",
        "*/src/models/gemma3.cpp",
        "*/src/models/gemma3n.cpp",
        "*/src/models/gemma4-assistant.cpp",
        "*/src/models/gemma4.cpp",
        "*/src/models/glm-dsa.cpp",
        "*/src/models/glm4-moe.cpp",
        "*/src/models/glm4.cpp",
        "*/src/models/gpt2.cpp",
        "*/src/models/gptneox.cpp",
        "*/src/models/granite-hybrid.cpp",
        "*/src/models/granite-moe.cpp",
        "*/src/models/granite.cpp",
        "*/src/models/grok.cpp",
        "*/src/models/grovemoe.cpp",
        "*/src/models/hunyuan-dense.cpp",
        "*/src/models/hunyuan-moe.cpp",
        "*/src/models/hunyuan-vl.cpp",
        "*/src/models/hy-v3.cpp",
        "*/src/models/internlm2.cpp",
        "*/src/models/jais.cpp",
        "*/src/models/jais2.cpp",
        "*/src/models/jamba.cpp",
        "*/src/models/jina-bert-v2.cpp",
        "*/src/models/jina-bert-v3.cpp",
        "*/src/models/kimi-linear.cpp",
        "*/src/models/lfm2.cpp",
        "*/src/models/lfm2moe.cpp",
        "*/src/models/llada-moe.cpp",
        "*/src/models/llada.cpp",
        "*/src/models/llama-embed.cpp",
        "*/src/models/llama.cpp",
        "*/src/models/llama4.cpp",
        "*/src/models/maincoder.cpp",
        "*/src/models/mamba-base.cpp",
        "*/src/models/mamba.cpp",
        "*/src/models/mamba2.cpp",
        "*/src/models/mellum.cpp",
        "*/src/models/mimo2.cpp",
        "*/src/models/minicpm.cpp",
        "*/src/models/minicpm3.cpp",
        "*/src/models/minimax-m2.cpp",
        "*/src/models/mistral3.cpp",
        "*/src/models/mistral4.cpp",
        "*/src/models/modern-bert.cpp",
        "*/src/models/mpt.cpp",
        "*/src/models/nemotron-h-moe.cpp",
        "*/src/models/nemotron-h.cpp",
        "*/src/models/nemotron.cpp",
        "*/src/models/neo-bert.cpp",
        "*/src/models/nomic-bert-moe.cpp",
        "*/src/models/nomic-bert.cpp",
        "*/src/models/olmo.cpp",
        "*/src/models/olmo2.cpp",
        "*/src/models/olmoe.cpp",
        "*/src/models/openai-moe.cpp",
        "*/src/models/openelm.cpp",
        "*/src/models/orion.cpp",
        "*/src/models/paddleocr.cpp",
        "*/src/models/pangu-embed.cpp",
        "*/src/models/phi2.cpp",
        "*/src/models/phi3.cpp",
        "*/src/models/phimoe.cpp",
        "*/src/models/plamo.cpp",
        "*/src/models/plamo2.cpp",
        "*/src/models/plamo3.cpp",
        "*/src/models/plm.cpp",
        "*/src/models/qwen.cpp",
        "*/src/models/qwen2.cpp",
        "*/src/models/qwen2moe.cpp",
        "*/src/models/qwen2vl.cpp",
        "*/src/models/qwen3.cpp",
        "*/src/models/qwen35.cpp",
        "*/src/models/qwen35moe.cpp",
        "*/src/models/qwen3moe.cpp",
        "*/src/models/qwen3next.cpp",
        "*/src/models/qwen3vl.cpp",
        "*/src/models/qwen3vlmoe.cpp",
        "*/src/models/refact.cpp",
        "*/src/models/rnd1.cpp",
        "*/src/models/rwkv6-base.cpp",
        "*/src/models/rwkv6.cpp",
        "*/src/models/rwkv6qwen2.cpp",
        "*/src/models/rwkv7-base.cpp",
        "*/src/models/rwkv7.cpp",
        "*/src/models/seed-oss.cpp",
        "*/src/models/smallthinker.cpp",
        "*/src/models/smollm3.cpp",
        "*/src/models/stablelm.cpp",
        "*/src/models/starcoder.cpp",
        "*/src/models/starcoder2.cpp",
        "*/src/models/step35.cpp",
        "*/src/models/t5.cpp",
        "*/src/models/t5encoder.cpp",
        "*/src/models/talkie.cpp",
        "*/src/models/wavtokenizer-dec.cpp",
        "*/src/models/xverse.cpp",
        },
        targets = {
            ["llama"] = { kind = "lib" },
        },
        cflags   = { "-w", "-include", "ggml_build_info.h", "-DGGML_USE_CPU_REPACK" },
        cxxflags = { "-w", "-include", "ggml_build_info.h", "-DGGML_USE_CPU_REPACK" },
        flags = {
            { glob = "*/ggml/src/ggml-backend-reg.cpp", defines = { "GGML_USE_CPU" } },
            {
                glob = "*/ggml/src/ggml-cpu/**",
                defines = { "GGML_USE_LLAMAFILE" },
            },
            {
                glob = "mcpp_generated/ggml-cpu_cpp.cpp",
                defines = { "GGML_USE_LLAMAFILE" },
            },
            { glob = "*/src/models/t5.cpp",      cxxflags = { "-std=c++20" } },
            { glob = "*/src/models/eagle3.cpp",  cxxflags = { "-std=c++20" } },
            { glob = "*/src/models/dflash.cpp",   cxxflags = { "-std=c++20" } },
            { glob = "*/src/models/hunyuan-dense.cpp", cxxflags = { "-std=c++20" } },
            { glob = "*/src/models/llama-embed.cpp", cxxflags = { "-std=c++20" } },
            { glob = "*/src/models/minimax-m2.cpp", cxxflags = { "-std=c++20" } },
        },
        linux = {
            sources = {
                "*/ggml/src/ggml-cpu/arch/x86/quants.c",
                "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
            },
            cflags   = { "-D_GNU_SOURCE" },
            cxxflags = { "-D_GNU_SOURCE" },
            ldflags  = { "-ldl", "-lpthread", "-lm" },
        },
        macosx = {
            sources = {
                "*/ggml/src/ggml-cpu/arch/arm/quants.c",
                "*/ggml/src/ggml-cpu/arch/arm/repack.cpp",
            },
            cflags   = { "-D_DARWIN_C_SOURCE" },
            cxxflags = { "-D_DARWIN_C_SOURCE" },
            ldflags = {
                "-lpthread", "-lm",
                "-framework", "Foundation",
                "-framework", "Metal",
                "-framework", "MetalKit",
            },
        },
        windows = {
            sources = {
                "*/ggml/src/ggml-cpu/arch/x86/quants.c",
                "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
            },
            cflags   = { "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN" },
            cxxflags = { "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN" },
            ldflags  = { "-ladvapi32" },
        },
        features = {
            default = { implies = { "backend-cpu" } },
            ["backend-cpu"] = {},
            ["backend-metal"] = {
                sources = {
                    "*/ggml/src/ggml-metal/ggml-metal.cpp",
                    "mcpp_generated/ggml_metal_device_m.m",
                    "*/ggml/src/ggml-metal/ggml-metal-device.cpp",
                    "*/ggml/src/ggml-metal/ggml-metal-common.cpp",
                    "*/ggml/src/ggml-metal/ggml-metal-context.m",
                    "*/ggml/src/ggml-metal/ggml-metal-ops.cpp",
                },
                flags = {
                    { glob = "mcpp_generated/ggml_metal_device_m.m", cflags = { "-fno-objc-arc" } },
                    { glob = "*/ggml/src/ggml-metal/ggml-metal-context.m", cflags = { "-fno-objc-arc" } },
                    { glob = "*/ggml/src/ggml-metal/ggml-metal.cpp", cxxflags = { "-include", "memory" } },
                    {
                        glob = "*/ggml/src/ggml-backend-reg.cpp",
                        defines = { "GGML_USE_METAL" },
                    },
                },
            },
        },
    },
}
