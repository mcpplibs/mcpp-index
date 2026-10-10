// build.mcpp ran with toml++ as a host module and parsed build-config.toml; the
// value it read reaches this TU as a define.
#ifndef TOMLPP_BUILD_PORT
#error "build.mcpp (import tomlplusplus;) did not run or its cxxflag did not arrive"
#endif
int main() { return TOMLPP_BUILD_PORT == 8080 ? 0 : 1; }
