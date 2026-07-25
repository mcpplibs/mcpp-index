# ggml-org.llamacpp Contract

`ggml-org.llamacpp@b10069` is the only llama.cpp package in this index. It
downloads the pinned upstream archive once and builds one `llama` library
target containing GGML base, the mandatory CPU backend, llama.cpp registry and
inference sources, model implementations, and the public C++23 module.

Consumers use the module directly:

```toml
[dependencies.ggml-org]
llamacpp = "b10069"
```

```cpp
import llama;
```

The module exports the curated llama.cpp and required GGML API. Header macros
such as `LLAMA_H` and `LLAMA_API` remain private to the implementation; typed
constants replace the public numeric macros used by the module contract.

CPU support is always present and is the default when no feature is specified:

```toml
[dependencies.ggml-org]
llamacpp = { version = "b10069", features = ["backend-cpu"] }
```

The explicit `backend-cpu` form produces the same CPU build as the short form
above. Metal is enabled on macOS AArch64 with:

```toml
[target.'cfg(all(macos, arch = "aarch64"))'.dependencies.ggml-org]
llamacpp = { version = "b10069", features = ["backend-metal"] }
```

`backend-metal` adds the six upstream Metal translation units, registers the
backend, embeds the shader through `build.mcpp`, and links Foundation, Metal,
and MetalKit. It is an in-package feature; no provider capability or separate
GGML descriptor is required.

The package declares only `backend-cpu` and `backend-metal`. Its `build.mcpp`
rejects every other requested feature before compiling llama.cpp, including
misspelled or unavailable backends such as `backend-cuda` and `backend-xxx`.
This package-level validation does not require `mcpp build --strict`.

The checked-in module inputs live under `tools/llamacpp/module`. Regenerate
the export lists with `tools/llamacpp/gen_exports.py --upstream <llama.cpp>` and
run `tests/check_llamacpp_snapshot.py` to verify that the descriptor's embedded
`generated_files` remain byte-for-byte synchronized.
