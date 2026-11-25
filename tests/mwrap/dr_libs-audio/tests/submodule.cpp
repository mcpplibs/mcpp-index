// One header's module alone: mcpplibs.mwrap.dr_libs.flac is all a FLAC
// decoder needs, its constants included; nothing of dr_wav or dr_mp3 comes
// with it but the shared macros module.
import std;
import mcpplibs.mwrap.dr_libs.flac;

int main() {
    namespace m = mcpplibs::mwrap::dr_libs::macros;
    static_assert(m::DRFLAC_METADATA_BLOCK_TYPE_VORBIS_COMMENT == 4 && m::DR_FLAC_BUFFER_SIZE == 4096);
    const unsigned char not_flac[] = {'R', 'I', 'F', 'F', 0, 0, 0, 0};
    if (drflac_open_memory(not_flac, sizeof not_flac, nullptr) != nullptr) return 1;
    drflac_container c = drflac_container_native;
    return std::string_view(drflac_version_string()) == "0.13.3" && c == drflac_container_native ? 0 : 2;
}
