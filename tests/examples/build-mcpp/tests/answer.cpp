// Asserts both outputs of build.mcpp reached the build: the -D define (compile
// flag) and the generated answer() function (a generated source linked in).
#ifndef BUILT_BY_BUILD_MCPP
#error "build.mcpp cxxflag did not reach the test translation unit"
#endif
int answer();  // from the build.mcpp-generated src/generated.cpp
int main() { return answer() == 42 ? 0 : 1; }
