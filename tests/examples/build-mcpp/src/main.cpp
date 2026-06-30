// Consumes both outputs of build.mcpp: the -DBUILT_BY_BUILD_MCPP define and the
// generated answer() function. Returns 0 only if both took effect.
#ifndef BUILT_BY_BUILD_MCPP
#error "build.mcpp cxxflag did not reach this translation unit"
#endif

int answer();  // defined in the generated src/generated.cpp

int main() { return answer() == 42 ? 0 : 1; }
