# ONNX Runtime 1.31.0 compat package

- Branch: `add-onnxruntime`.
- Source: [microsoft/onnxruntime](https://github.com/microsoft/onnxruntime),
  release `v1.31.0`, MIT licensed.
- Shape: Form B with an external CMake build hook. ONNX Runtime cannot be
  represented by a source glob: the upstream build generates protobuf and
  flatbuffers sources and fetches its pinned dependency graph from
  `cmake/external/deps.txt`.
- Build profile: CPU execution provider only. CUDA, TensorRT, OpenVINO,
  CoreML, DNNL, XNNPACK, mimalloc, language bindings, tests, and optional
  provider plugins are disabled. The upstream shared library is installed
  into the package prefix, and the mcpp descriptor links it through a small C
  anchor target.
- Platforms: Linux, macOS, and Windows use the same source archive and the
  upstream CMake platform selection. `xim:cmake` is declared as the build
  dependency on each platform.
- Test: `tests/examples/onnxruntime` loads the public C API and verifies the
  runtime version string begins with `1.31.`.
- CN mirror: not declared because no mcpp-res upload is available; the
  descriptor uses the permitted upstream URL fallback. The release archive
  SHA-256 is
  `a7e84230b5d509e48fbd6b73c2453a56345ccb22da34a46dac1f0cb4a2d6507b`.
