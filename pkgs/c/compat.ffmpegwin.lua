-- TEMP windows-x86_64 FFmpeg build spike (R1 proper): does mcpp clang-MSVC
-- compile 2284 sources (159 win64 NASM .asm, HAVE_INLINE_ASM=0 → C fallbacks)?
package = {
    spec="1", namespace="compat", name="compat.ffmpegwin",
    description="FFmpeg 8.1.2 windows-x86_64 build spike (temp)",
    licenses={"LGPL-2.1-or-later"}, repo="https://ffmpeg.org", type="package",
    xpm = { windows = { ["8.1.2"] = {
        url = { GLOBAL="https://ffmpeg.org/releases/ffmpeg-8.1.2.tar.gz", CN="https://gitcode.com/mcpp-res/ffmpeg/releases/download/8.1.2/ffmpeg-8.1.2.tar.gz" },
        sha256="32faba5ef67340d54724941eae1425580791195312a4fd13bf6f820a2818bf22",
    } } },
    mcpp = {
        c_standard="c17",
        targets = { ffmpeg = { kind="lib" } },
        include_dirs = {
            "mcpp_generated",
            "mcpp_generated/libavcodec",
            "mcpp_generated/libavformat",
            "mcpp_generated/libavfilter",
            "mcpp_generated/libavdevice",
            "*",
            "*/libavcodec",
            "*/libavutil/x86",
            "*/libavcodec/x86",
            "*/libavfilter/x86",
            "*/libswscale/x86",
            "*/libswresample/x86",
        },
        cflags = {
            "-DHAVE_AV_CONFIG_H",
            "-D_ISOC11_SOURCE",
            "-DPIC",
            "-w",
        },
        flags = {
            { glob = "*/libavutil/**", defines = { "BUILDING_avutil" } },
            { glob = "*/libavcodec/**", defines = { "BUILDING_avcodec" } },
            { glob = "*/libavformat/**", defines = { "BUILDING_avformat" } },
            { glob = "*/libavfilter/**", defines = { "BUILDING_avfilter" } },
            { glob = "*/libavdevice/**", defines = { "BUILDING_avdevice" } },
            { glob = "*/libswscale/**", defines = { "BUILDING_swscale" } },
            { glob = "*/libswresample/**", defines = { "BUILDING_swresample" } },
            { glob = "**/*.asm", asmflags = { "-Pconfig.asm" } },
        },
        windows = { ldflags = {
                "-lbcrypt",
                "-lws2_32",
                "-lsecur32",
                "-luser32",
                "-lole32",
                "-loleaut32",
                "-ladvapi32",
                "-lshell32",
            } },
        sources = {
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/012v.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/4xm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/8bps.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/8svx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/a64multienc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac/aacdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac/aacdec_ac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac/aacdec_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac/aacdec_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac/aacdec_lpd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac/aacdec_tab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac/aacdec_usac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac/aacdec_usac_mps212.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac_ac3_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aac_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aaccoder.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacenc_is.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacenc_tns.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacenctab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacps_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacps_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacps_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacpsdsp_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacpsdsp_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacpsy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacsbr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aacsbr_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aactab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aandcttab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aasc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3_channel_layout_tab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3dec_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3dec_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3dec_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3enc_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3enc_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ac3tab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/acelp_filters.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/acelp_pitch_delay.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/acelp_vectors.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adpcm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adpcm_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adpcmenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adts_header.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adts_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adx_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adxdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/adxenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/agm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aic.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/alac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/alac_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/alacdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/alacenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aliaspixdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aliaspixenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/allcodecs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/alsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/amr_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/amrnbdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/amrwbdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/anm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ansi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aom_film_grain.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/apac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/apedec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aptx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aptxdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aptxenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/apv_decode.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/apv_dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/apv_entropy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/apv_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/arbc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/argo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ass.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ass_split.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/assdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/assenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/asv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/asvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/asvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/atrac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/atrac1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/atrac3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/atrac3plus.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/atrac3plusdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/atrac3plusdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/atrac9dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/atsc_a53.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/audio_frame_queue.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/audiodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/aura.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/av1_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/av1_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/av1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avcodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avdct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avrndec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avs2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avs2_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avs3_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avuidec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/avuienc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bethsoftvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bfi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bgmc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bink.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/binkaudio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/binkdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bintext.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bitpacked_dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bitpacked_enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bitstream.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bitstream_filters.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/blockdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bmp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bmp_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bmpenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bmvaudio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bmvvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bonk.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/brenderpix.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/aac_adtstoasc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/apv_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/av1_frame_merge.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/av1_frame_split.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/av1_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/chomp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/dca_core.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/dovi_rpu.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/dts2pts.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/dump_extradata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/dv_error_marker.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/eac3_core.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/eia608_to_smpte436m.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/evc_frame_merge.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/extract_extradata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/filter_units.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/h264_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/h264_mp4toannexb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/h264_redundant_pps.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/h265_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/h266_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/hapqa_extract.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/hevc_mp4toannexb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/imx_dump_header.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/lcevc_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/media100_to_mjpegb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/mjpeg2jpeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/mjpega_dump_header.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/movsub.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/mpeg2_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/mpeg4_unpack_bframes.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/noise.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/null.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/opus_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/pcm_rechunk.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/pgs_frame_merge.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/prores_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/remove_extradata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/setts.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/showinfo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/smpte436m_to_eia608.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/trace_headers.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/truehd_core.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/vp9_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/vp9_raw_reorder.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/vp9_superframe.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/vp9_superframe_split.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bsf/vvc_mp4toannexb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/bswapdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/c93.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cabac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/canopus.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cavs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cavs_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cavsdata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cavsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cavsdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbrt_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbrt_data_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbrt_tablegen_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_apv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_av1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_bsf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_h264.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_h2645.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_h265.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_h266.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_lcevc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_mpeg2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_sei.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_vp8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cbs_vp9.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ccaption_dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cdgraphics.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cdtoons.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cdxl.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/celp_filters.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/celp_math.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cfhd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cfhddata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cfhddsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cfhdenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cfhdencdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cga_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cinepak.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cinepakenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/clearvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cljrdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cljrenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cllc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cngdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cngenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/codec_desc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/codec_par.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cook.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cook_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cpia.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cri.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cri_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cscd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/cyuv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/d3d11va.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dca.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dca_core.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dca_exss.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dca_lbr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dca_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dca_sample_rate_tab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dca_xll.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dcaadpcm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dcadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dcadct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dcadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dcadsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dcaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dcahuff.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dct32_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dct32_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dds.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/decode.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dfa.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dfpwmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dfpwmenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dirac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dirac_arith.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dirac_dwt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dirac_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dirac_vlc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/diracdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/diracdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/diractab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dnxhd_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dnxhddata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dnxhddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dnxhdenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dnxuc_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dolby_e.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dolby_e_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dolby_e_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dovi_rpu.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dovi_rpudec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dovi_rpuenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dpcm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dpx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dpx_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dpxenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dsd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dsddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dsicinaudio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dsicinvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dss_sp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dstdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dv_profile.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvaudio_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvaudiodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvbsub_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvbsubdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvbsubenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvd_nav_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvdata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvdsub.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvdsub_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvdsubdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvdsubenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dxtory.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dxv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dxvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/dynamic_hdr_vivid.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/eac3_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/eac3enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/eacmv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/eaidct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/eamad.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/eatgq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/eatgv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/eatqi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/elbg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/encode.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/error_resilience.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/escape124.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/escape130.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/evc_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/evc_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/evc_ps.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/evrcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/executor.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/exif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/faandct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/faanidct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fastaudio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/faxcompr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fdctdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ffv1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ffv1_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ffv1_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ffv1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ffv1enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ffwavesynth.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fic.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/file_open.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fits.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fitsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fitsenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flac_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flacdata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flacdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flacdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flacenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flacencdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flicvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/flvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fmtconvert.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fmvc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/frame_thread_encoder.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/fraps.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/frwu.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ftr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ftr_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g722.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g722dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g722dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g722enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g723_1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g723_1_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g723_1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g723_1enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g726.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g728dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g729_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g729dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/g729postfilter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/gdv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/gemdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/get_buffer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/gif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/gif_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/gifdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/golomb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/gsm_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/gsmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/gsmdec_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h261.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h261_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h261data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h261dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h261enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h263.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h263_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h263data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h263dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h263dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_cabac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_cavlc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_direct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_levels.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_loopfilter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_mb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_picture.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_ps.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_refs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_sei.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264_slice.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h2645_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h2645_sei.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h2645_vui.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h2645data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264chroma.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264idct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264pred.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h264qpel.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h265_profile_level.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/h274.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hap.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hapdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hashtable.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hcadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hcom.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hdr_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hdrdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hdrenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/cabac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/filter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/hevcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/mvs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/pred.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/ps.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/refs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hevc/sei.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hnm4video.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hpeldsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hq_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hq_hqa.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hq_hqadsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hqx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/hqxdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/htmlsubtitles.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/huffman.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/huffyuv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/huffyuvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/huffyuvdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/huffyuvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/huffyuvencdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/idcinvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/idctdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/iff.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ilbcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/imc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/imgconvert.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/imm4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/imm5.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/imx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/indeo2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/indeo3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/indeo4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/indeo5.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/intelh263dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/interplayacm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/interplayvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/intrax8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/intrax8dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ipu_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ituh263dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ituh263enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ivi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ivi_dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/j2kenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jacosubdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jfdctfst.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jfdctint.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jni.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpeg2000.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpeg2000_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpeg2000dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpeg2000dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpeg2000dwt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpeg2000htdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpegls.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpeglsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpeglsenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpegquanttables.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpegtables.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpegxl_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpegxl_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jpegxs_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jrevdct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/jvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/kbdwin.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/kgv1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/kmvc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lagarith.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lagarithrac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/latm_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lcevc_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lcevctab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lcldec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/leaddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ljpegenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/loco.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lossless_audiodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lossless_videodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lossless_videoencdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lpc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lzf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lzw.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/lzwenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/m101.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mace.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/magicyuv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/magicyuvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mathtables.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/me_cmp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mediacodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/metasound.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/microdvddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/midivid.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mimic.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/misc4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/misc4_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mjpeg_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mjpegbdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mjpegdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mjpegdec_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mjpegenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mjpegenc_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mjpegenc_huffman.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mlp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mlp_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mlp_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mlpdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mlpdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mlpenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mlz.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mmvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mobiclip.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/motion_est.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/motionpixels.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/movtextdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/movtextenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpc7.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpc8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg_er.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg12.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg12data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg12dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg12enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg12framerate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg4audio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg4audio_sample_rates.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg4video.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg4video_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg4videodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg4videodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpeg4videoenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudio_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodec_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodec_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodec_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodecheader.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodsp_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodsp_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiodsp_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudioenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegaudiotabs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegpicture.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegutils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegvideo_dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegvideo_enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegvideo_motion.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegvideo_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegvideo_unquantize.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegvideodata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpegvideoencdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mpl2dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mqc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mqcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mqcenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msgsmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msmpeg4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msmpeg4_vc1_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msmpeg4data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msmpeg4dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msmpeg4enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msp2dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msrle.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msrledec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msrleenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mss1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mss12.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mss2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mss2dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mss3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mss34dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mss4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msvideo1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/msvideo1enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mv30.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mvcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/mxpegdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/nellymoser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/nellymoserdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/nellymoserenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/notchlc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/null.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/nuv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/on2avc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/on2avcdata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/options.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/celt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/dec_celt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/enc_psy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/frame_duration_tab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/pvq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/rc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/silk.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/opus/tab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/osq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/packet.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pafaudio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pafvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pamenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/parsers.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pcm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pcm-bluray.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pcm-blurayenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pcm-dvd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pcm-dvdenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pcx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pcxenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pgssubdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pgxdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/photocd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pictordec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pixblockdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pixlet.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/png_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pnm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pnm_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pnmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pnmenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/profiles.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/prores_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/prores_raw.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/prores_raw_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/proresdata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/proresdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/proresdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/proresenc_anatoliy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/proresenc_kostya.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/proresenc_kostya_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/prosumer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/psd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/psymodel.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pthread.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pthread_frame.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/pthread_slice.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ptx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qcelpdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qdm2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qdmc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qdrw.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qoadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qoi_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qoidec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qoienc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qpeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qpeldsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qsv_api.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qtrle.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/qtrleenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/r210dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/r210enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ra144.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ra144dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ra144enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ra288.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ralf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rangecoder.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ratecontrol.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/raw.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rawdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rawenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/realtextdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rka.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rl.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rl2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rle.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/roqaudioenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/roqvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/roqvideodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/roqvideoenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rpza.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rpzaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rtjpeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rtv1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv10.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv10enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv20enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv30.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv30dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv34.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv34_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv34dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv40.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv40dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv60dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/rv60dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/s302m.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/s302menc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/samidec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sanm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sbc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sbc_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sbcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sbcdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sbcenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sbrdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sbrdsp_fixed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/scpr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sga.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sgidec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sgienc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sgirledec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sheervideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/shorten.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/simple_idct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sinewin.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sipr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sipr_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sipr16k.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/siren.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/smacker.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/smc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/smcenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/smpte_436m.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/snappy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/snow.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/snow_dwt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/snowdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/snowenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sonic.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sp5xdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/speedhq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/speedhqdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/speedhqenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/speexdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/srtdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/srtenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/startcode.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/subviewerdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sunrast.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/sunrastenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/svq1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/svq1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/svq1enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/svq3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/synth_filter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tak.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tak_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/takdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/takdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/targa.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/targa_y216dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/targaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/textdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/texturedsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/texturedspenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/threadprogress.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tiertexseqv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tiff.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tiff_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tiffenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tmv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/to_upper4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tpeldsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/truemotion1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/truemotion2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/truemotion2rt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/truespeech.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tscc2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/tta.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ttadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ttadsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ttaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ttaencdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ttmlenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/twinvq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/twinvqdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/txd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ulti.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/utils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/utvideodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/utvideodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/utvideoenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v210dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v210enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v210x.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v308dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v308enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v408dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v408enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v410dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/v410enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vble.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vbndec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vbnenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1_block.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1_loopfilter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1_mc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1_pred.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc1dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc2enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vc2enc_dwt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vcr1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/version.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/videodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vima.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vlc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vmdaudio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vmdvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vmixdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vmnc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vorbis.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vorbis_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vorbis_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vorbisdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vorbisdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vorbisenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp3_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp3dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp5.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp56.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp56data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp5dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp6.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp6dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp8_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp8data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp8dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9block.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9dsp_10bpp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9dsp_12bpp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9dsp_8bpp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9lpf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9mvs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9prob.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vp9recon.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vpx_rac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vqavideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vqcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/cabac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/ctu.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/filter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/inter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/intra.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/intra_utils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/itx_1d.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/mvs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/ps.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/refs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/sei.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc/thread.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/vvc_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wavarc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wavpack.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wavpackdata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wavpackenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wbmpdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wbmpenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/webp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/webp_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/webvttdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/webvttenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wma.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wma_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wma_freqs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmalosslessdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmaprodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmavoice.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmv2data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmv2dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmv2dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wmv2enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wnv1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/wrapped_avframe.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ws-snd1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/aacencdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/aacencdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/aacpsdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/aacpsdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/ac3dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/ac3dsp_downmix.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/ac3dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/alacdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/alacdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/apv_dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/apv_dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/audiodsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/audiodsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/blockdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/blockdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/bswapdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/bswapdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/cavs_qpel.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/cavsdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/cavsidct.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/celt_pvq_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/celt_pvq_search.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/cfhddsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/cfhddsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/cfhdencdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/cfhdencdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/constants.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/dcadsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/dcadsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/dct32.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/dirac_dwt.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/dirac_dwt_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/diracdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/diracdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/dnxhdenc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/dnxhdenc_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/fdct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/fdctdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/flacdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/flacdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/flacencdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/fmtconvert.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/fmtconvert_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/fpel.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/g722dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/g722dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h263_loopfilter.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h263dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_chromamc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_chromamc_10bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_deblock.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_deblock_10bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_idct.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_idct_10bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_intrapred.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_intrapred_10bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_intrapred_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_qpel.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_qpel_10bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_qpel_8bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_weight.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264_weight_10bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264chroma_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h264dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h26x/h2656_inter.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/h26x/h2656dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hevc/add_res.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hevc/deblock.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hevc/dequant.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hevc/dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hevc/idct.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hevc/mc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hevc/sao.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hevc/sao_10bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hpeldsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/hpeldsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/huffyuvdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/huffyuvdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/huffyuvencdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/huffyuvencdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/idctdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/idctdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/imdct36.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/jpeg2000dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/jpeg2000dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/lossless_audiodsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/lossless_audiodsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/lossless_videodsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/lossless_videodsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/lossless_videoencdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/lossless_videoencdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/lpc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/lpc_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/me_cmp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/me_cmp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/mlpdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/mlpdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/mpeg4videodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/mpegaudiodsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/mpegvideo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/mpegvideoenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/mpegvideoencdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/mpegvideoencdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/opusdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/opusdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/pixblockdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/pixblockdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/proresdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/proresdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/qpel.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/qpeldsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/qpeldsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/rv34dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/rv34dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/rv40dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/rv40dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/sbcdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/sbcdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/sbrdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/sbrdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/simple_idct10.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/snowdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/svq1enc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/svq1enc_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/synth_filter.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/synth_filter_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/takdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/takdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/ttadsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/ttadsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/ttaencdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/ttaencdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/utvideodsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/utvideodsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/v210.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/v210enc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/v210enc_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/v210-init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vc1dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vc1dsp_loopfilter.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vc1dsp_mc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vc1dsp_mmx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/videodsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/videodsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vorbisdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vorbisdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp3dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp3dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp6dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp6dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp8dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp8dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp8dsp_loopfilter.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9dsp_init_10bpp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9dsp_init_12bpp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9dsp_init_16bpp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9intrapred.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9intrapred_16bpp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9itxfm.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9itxfm_16bpp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9itxfm_16bpp_avx512.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9itxfm_avx2.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9itxfm_avx512.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9lpf.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9lpf_16bpp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9mc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vp9mc_16bpp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vvc/alf.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vvc/dmvr.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vvc/dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vvc/mc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vvc/of.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vvc/sad.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vvc/sao.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/vvc/sao_10bit.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/xvididct.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/x86/xvididct_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xan.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xbm_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xbmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xbmenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xface.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xfacedec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xfaceenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xiph.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xl.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xma_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xpmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xsubdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xsubenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xvididct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xwd_parser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xwddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xwdenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/xxan.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/y41pdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/y41penc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/ylc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/yop.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/yuv4dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavcodec/yuv4enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/alldevices.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/avdevice.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/dshow.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/dshow_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/dshow_crossbar.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/dshow_enummediatypes.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/dshow_enumpins.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/dshow_filter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/dshow_pin.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/file_open.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/gdigrab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/lavfi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/utils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/version.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavdevice/vfwcap.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/aeval.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aap.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_acontrast.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_acopy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_acrossover.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_acrusher.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_adeclick.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_adecorrelate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_adelay.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_adenorm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aderivative.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_adrc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_adynamicequalizer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_adynamicsmooth.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aecho.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aemphasis.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aexciter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_afade.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_afftdn.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_afftfilt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_afir.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aformat.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_afreqshift.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_afwtdn.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_agate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aiir.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_alimiter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_amerge.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_amix.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_amultiply.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_anequalizer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_anlmdn.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_anlms.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_anull.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_apad.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aphaser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_apsyclip.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_apulsator.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aresample.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_arls.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_arnndn.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_asdr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_asetnsamples.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_asetrate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_ashowinfo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_asoftclip.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_aspectralstats.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_astats.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_asubboost.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_asupercut.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_atempo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_atilt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_axcorrelate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_biquads.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_channelmap.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_channelsplit.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_chorus.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_compand.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_compensationdelay.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_crossfeed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_crystalizer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_dcshift.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_deesser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_dialoguenhance.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_drmeter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_dynaudnorm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_earwax.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_extrastereo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_firequalizer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_flanger.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_haas.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_hdcd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_headphone.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_join.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_loudnorm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_mcompand.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_pan.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_replaygain.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_sidechaincompress.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_silencedetect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_silenceremove.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_speechnorm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_stereotools.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_stereowiden.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_superequalizer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_surround.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_tremolo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_vibrato.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_virtualbass.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_volume.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/af_volumedetect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/allfilters.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/asink_anullsink.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/asrc_afdelaysrc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/asrc_afirsrc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/asrc_anoisesrc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/asrc_anullsrc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/asrc_hilbert.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/asrc_sinc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/asrc_sine.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/audio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_a3dscope.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_abitscope.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_ahistogram.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_aphasemeter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_avectorscope.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_concat.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_showcqt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_showcwt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_showfreqs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_showspatial.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_showspectrum.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_showvolume.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avf_showwaves.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avfilter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/avfiltergraph.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/bbox.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/buffersink.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/buffersrc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/bwdifdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/ccfifo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/colorspace.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/colorspacedsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/drawutils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/ebur128.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/edge_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_bench.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_cue.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_drawgraph.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_ebur128.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_graphmonitor.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_interleave.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_latency.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_loop.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_perms.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_realtime.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_reverse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_segment.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_select.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_sendcmd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_sidedata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/f_streamselect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/file_open.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/formats.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/framepool.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/framequeue.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/framesync.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/generate_wave_table.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/graphdump.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/graphparser.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/lavfutils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/lswsutils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/motion_estimation.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/palette.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/perlin.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/psnr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/pthread.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/qp_table.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/scale_eval.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/scene_sad.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/setpts.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/settb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/split.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/src_avsynctest.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/src_movie.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/transform.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/trim.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vaf_spectrumsynth.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/version.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_addroi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_alphamerge.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_amplify.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_aspect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_atadenoise.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_avgblur.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_backgroundkey.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_bbox.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_bilateral.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_bitplanenoise.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_blackdetect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_blend.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_blockdetect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_blurdetect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_bm3d.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_bwdif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_cas.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_ccrepack.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_chromakey.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_chromanr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_chromashift.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_ciescope.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_codecview.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorbalance.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorchannelmixer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorconstancy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorcontrast.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorcorrect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colordetect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorize.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorkey.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorlevels.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colormap.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colorspace.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_colortemperature.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_convolution.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_convolve.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_copy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_corr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_crop.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_curves.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_datascope.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_dblur.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_dctdnoiz.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_deband.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_deblock.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_decimate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_dedot.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_deflicker.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_dejudder.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_deshake.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_despill.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_detelecine.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_displace.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_drawbox.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_edgedetect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_elbg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_entropy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_epx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_estdif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_exposure.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_extractplanes.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fade.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_feedback.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fftdnoiz.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fftfilt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_field.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fieldhint.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fieldmatch.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fieldorder.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fillborders.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_floodfill.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_format.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fps.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_framepack.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_framerate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_framestep.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_freezedetect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_freezeframes.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_fsync.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_gblur.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_geq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_gradfun.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_grayworld.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_guided.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_hflip.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_histogram.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_hqx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_hsvkey.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_hue.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_huesaturation.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_hwdownload.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_hwmap.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_hwupload.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_hysteresis.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_identity.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_idet.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_idetdsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_il.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_lagfun.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_lenscorrection.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_limitdiff.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_limiter.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_lumakey.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_lut.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_lut2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_lut3d.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_maskedclamp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_maskedmerge.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_maskedminmax.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_maskedthreshold.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_maskfun.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_median.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_mergeplanes.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_mestimate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_midequalizer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_minterpolate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_mix.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_monochrome.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_morpho.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_multiply.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_negate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_neighbor.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_nlmeans.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_noise.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_normalize.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_null.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_overlay.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_pad.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_palettegen.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_paletteuse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_photosensitivity.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_pixdesctest.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_pixelize.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_premultiply.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_pseudocolor.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_psnr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_qp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_random.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_readeia608.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_readvitc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_remap.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_removegrain.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_removelogo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_rotate.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_scale.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_scdet.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_scroll.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_selectivecolor.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_separatefields.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_setparams.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_shear.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_showinfo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_showpalette.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_shuffleframes.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_shufflepixels.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_shuffleplanes.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_signalstats.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_siti.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_ssim.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_ssim360.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_stack.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_swaprect.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_swapuv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_telecine.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_threshold.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_thumbnail.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_tile.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_tiltandshift.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_tmidequalizer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_tonemap.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_tpad.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_transpose.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_unsharp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_untile.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_v360.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_varblur.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_vectorscope.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_vflip.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_vfrdet.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_vibrance.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_vif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_vignette.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_vmafmotion.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_w3fdif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_waveform.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_weave.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_xbr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_xfade.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_xmedian.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_xpsnr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_yadif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_yaepblur.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vf_zoompan.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/video.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vsink_nullsink.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vsrc_cellauto.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vsrc_gradients.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vsrc_life.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vsrc_mandelbrot.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vsrc_perlin.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vsrc_sierpinski.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/vsrc_testsrc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/af_afir.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/af_afir_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/af_anlmdn.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/af_anlmdn_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/af_volume.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/af_volume_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/avf_showcqt.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/avf_showcqt_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/colorspacedsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/colorspacedsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/f_ebur128.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/f_ebur128_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/scene_sad.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/scene_sad_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_atadenoise.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_atadenoise_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_blackdetect.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_blackdetect_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_blend.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_blend_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_bwdif.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_bwdif_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_colordetect.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_colordetect_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_convolution.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_convolution_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_framerate.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_framerate_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_gblur.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_gblur_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_gradfun.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_gradfun_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_hflip.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_hflip_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_idetdsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_idetdsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_limiter.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_limiter_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_lut3d.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_lut3d_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_maskedclamp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_maskedclamp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_maskedmerge.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_maskedmerge_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_nlmeans.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_nlmeans_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_noise.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_overlay.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_overlay_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_psnr.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_psnr_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_ssim.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_ssim_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_threshold.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_threshold_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_transpose.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_transpose_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_v360.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_v360_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_w3fdif.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_w3fdif_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_yadif.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/vf_yadif_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/yadif-10.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/x86/yadif-16.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavfilter/yadif_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/3dostr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/4xm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/a64.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aacdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aaxdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ac3dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ac4dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ac4enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/acedec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/acm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/act.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/adp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ads.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/adtsenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/adxdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aeadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aeaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/afc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aiff.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aiffdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aiffenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aixdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/allformats.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/alp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/amr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/amvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/anm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ape.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apetag.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apngdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apngenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aptxdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/apvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aqtitledec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/argo_asf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/argo_brp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/argo_cvg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/asf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/asf_tags.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/asfcrypt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/asfdec_f.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/asfdec_o.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/asfenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/assdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/assenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ast.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/astdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/astenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/async.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/au.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/av1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/av1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avformat.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avidec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avienc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avio.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/aviobuf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avlanguage.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avs2dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/avs3dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/bethsoftvid.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/bfi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/bink.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/binka.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/bintext.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/bit.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/bmv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/boadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/bonk.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/brstm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/c93.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cache.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/caf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cafdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cafenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cavsvideodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cbs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cbs_apv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cbs_av1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cdg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cdxl.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/cinedec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/codec2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/codecstring.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/concat.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/concatdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/crcenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/crypto.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dash.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dashenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/data_uri.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dauddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/daudenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dcstr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/demux.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/demux_utils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/derf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dfa.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dfpwmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dhav.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/diracdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dnxhddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dovi_isom.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dsfdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dsicin.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dss.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dtsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dtshddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dump.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dvbsub.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dvbtxt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dvdclut.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/dxa.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/eacdata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/electronicarts.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/epafdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/evc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/evcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ffmetadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ffmetaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/fifo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/file.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/file_open.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/filmstripdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/filmstripenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/fitsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/fitsenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/flac_picture.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/flacdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/flacenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/flacenc_header.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/flic.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/flvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/flvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/format.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/framecrcenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/framehash.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/frmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/fsb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ftp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/fwse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/g722.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/g723_1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/g726.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/g728dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/g729dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/gdv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/genh.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/gif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/gifdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/gopher.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/gsmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/gxf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/gxfenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/h261dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/h263dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/h264dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hashenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hca.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hcom.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hdsenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hevc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hevcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hls.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hls_sample_encryption.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hlsenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hlsplaylist.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hnm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/http.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/httpauth.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/hxvs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iamf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iamf_parse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iamf_reader.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iamf_writer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iamfdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iamfenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/icecast.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/icodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/icoenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/id3v1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/id3v2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/id3v2enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/idcin.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/idroqdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/idroqenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iff.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ifv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ilbc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/img2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/img2_alias_pix.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/img2_brender_pix.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/img2dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/img2enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/imx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ingenientdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ip.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ipmovie.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ipudec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ircam.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ircamdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ircamenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/isom.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/isom_tags.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iss.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/iv8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ivfdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ivfenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/jacosubdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/jacosubenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/jpegxl_anim_dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/jvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/kvag.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/lafdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/latmenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/lc3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/lmlm4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/loasdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/lrc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/lrcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/lrcenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/luodatdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/lvfdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/lxfdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/m4vdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/matroska.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/matroskadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/matroskaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mca.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mccdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mccenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/md5proto.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mgsts.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/microdvddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/microdvdenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mj2kdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mkvtimestamp_v2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mlpdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mlvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mmf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mms.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mmsh.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mmst.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mods.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/moflex.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mov.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mov_chan.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mov_esds.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/movenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/movenc_ttml.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/movenccenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/movenchint.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mp3dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mp3enc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpc8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpegenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpegts.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpegtsenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpegvideodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpjpeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpjpegdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpl2dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mpsubdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/msf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/msnwc_tcp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mspdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mtaf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mtv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/musx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mux.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mux_utils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mvi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mxf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mxfdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mxfenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/mxg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nal.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ncdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/network.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nistspheredec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nspdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nsvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nullenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nut.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nutdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nutenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/nuv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparsecelt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparsedirac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparseflac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparseogm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparseopus.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparseskeleton.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparsespeex.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparsetheora.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparsevorbis.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oggparsevp8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/oma.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/omadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/omaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/options.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/os_support.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/osq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/paf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pcm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pcmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pcmenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pdvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pjsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pmpdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pp_bnk.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/prompeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/protocols.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/psxstr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pva.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/pvfdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/qcp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/qoadec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/qtpalette.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/r3d.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rawdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rawenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rawutils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rawvideodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rcwtdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rcwtenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rdt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/realtextdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/redspark.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/replaygain.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/riff.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/riffdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/riffenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rka.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rl2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rmenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rmsipr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rpl.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rsd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rso.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rsodec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rsoenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtmpdigest.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtmphttp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtmppkt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtmpproto.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_ac3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_amr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_asf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_av1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_dv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_g726.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_h261.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_h263.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_h263_rfc2190.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_h264.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_hevc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_ilbc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_jpeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_latm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_mpa_robust.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_mpeg12.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_mpeg4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_mpegts.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_opus.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_qcelp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_qdm2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_qt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_rfc4175.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_svq3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_vc2hq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_vp8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_vp9.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpdec_xiph.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_aac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_amr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_av1.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_chain.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_h261.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_h263.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_h263_rfc2190.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_h264_hevc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_jpeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_latm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_mpegts.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_mpv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_rfc4175.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_vc2hq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_vp8.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_vp9.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpenc_xiph.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtpproto.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtspdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/rtspenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/s337m.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/samidec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sapdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sapenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sauce.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sbcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sbgdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sccdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sccenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/scd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sdns.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sdp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sdr2.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sdsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sdxdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/seek.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/segafilm.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/segafilmenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/segment.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/serdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sga.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/shortendec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sierravmd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/siff.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/smacker.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/smjpeg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/smjpegdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/smjpegenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/smoothstreamingenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/smush.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/sol.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/soxdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/soxenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/spdif.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/spdifdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/spdifenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/srtdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/srtenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/srtp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/srtpproto.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/stldec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/subfile.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/subtitles.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/subviewer1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/subviewerdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/supdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/supenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/svag.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/svs.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/swf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/swfdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/swfenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/takdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/tcp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/tedcaptionsdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/tee.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/tee_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/teeproto.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/thp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/tiertexseq.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/tmv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/tta.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ttaenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ttmlenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/tty.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/txd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/ty.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/udp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/uncodedframecrcenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/url.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/urldecode.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/usmdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/utils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vag.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vc1dec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vc1test.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vc1testenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/version.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vividas.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vivo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/voc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/voc_packet.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vocdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vocenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vorbiscomment.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vpcc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vpk.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vplayerdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vqf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vvc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/vvcdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/w64.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wady.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wavarc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wavdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wavenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wc3movie.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/webm_chunk.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/webmdashenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/webpenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/webvttdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/webvttenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/westwood_aud.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/westwood_audenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/westwood_vqa.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wsddec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wtv_common.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wtvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wtvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wvdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wvedec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/wvenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/xa.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/xmd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/xmv.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/xvag.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/xwma.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/yop.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/yuv4mpegdec.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavformat/yuv4mpegenc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/adler32.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/aes.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/aes_ctr.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/ambient_viewing_environment.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/audio_fifo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/avsscanf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/avstring.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/base64.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/blowfish.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/bprint.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/buffer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/camellia.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/cast5.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/channel_layout.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/container_fifo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/cpu.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/crc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/csp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/des.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/detection_bbox.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/dict.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/display.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/dovi_meta.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/downmix_info.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/encryption_info.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/error.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/eval.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/executor.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/fifo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/file.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/file_open.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/film_grain_params.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/fixed_dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/float_dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/float_scalarproduct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/float2half.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/frame.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/half2float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/hash.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/hdr_dynamic_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/hdr_dynamic_vivid_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/hmac.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/hwcontext.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/hwcontext_stub.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/iamf.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/imgutils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/integer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/intmath.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/lfg.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/lls.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/log.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/log2_tab.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/lzo.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/mastering_display_metadata.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/mathematics.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/md5.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/mem.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/murmur3.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/opt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/parseutils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/pixdesc.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/pixelutils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/random_seed.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/rational.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/rc4.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/refstruct.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/reverse.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/ripemd.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/samplefmt.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/sha.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/sha512.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/side_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/slicethread.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/spherical.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/stereo3d.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/tdrdi.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/tea.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/threadmessage.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/time.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/timecode.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/timecode_internal.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/timestamp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/tree.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/twofish.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/tx.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/tx_double.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/tx_float.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/tx_int32.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/utils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/uuid.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/version.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/video_enc_params.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/video_hint.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/aes.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/aes_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/cpu.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/cpuid.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/crc.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/emms.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/fixed_dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/fixed_dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/float_dsp.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/float_dsp_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/imgutils.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/imgutils_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/lls.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/lls_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/pixelutils.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/pixelutils_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/tx_float.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/x86/tx_float_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/xga_font_data.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libavutil/xtea.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/audioconvert.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/dither.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/options.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/rematrix.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/resample.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/resample_dsp.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/swresample.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/swresample_frame.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/version.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/x86/audio_convert.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/x86/audio_convert_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/x86/rematrix.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/x86/rematrix_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/x86/resample.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswresample/x86/resample_init.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/alphablend.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/cms.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/csputils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/format.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/gamma.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/graph.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/hscale.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/hscale_fast_bilinear.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/input.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/lut3d.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/ops.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/ops_backend.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/ops_chain.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/ops_dispatch.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/ops_memcpy.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/ops_optimizer.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/options.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/output.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/rgb2rgb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/slice.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/swscale.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/swscale_unscaled.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/utils.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/version.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/vscale.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/input.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/ops.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/ops_float.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/ops_int.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/output.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/range_convert.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/rgb_2_rgb.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/rgb2rgb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/scale.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/scale_avx2.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/swscale.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/yuv_2_rgb.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/yuv2rgb.c",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/x86/yuv2yuvX.asm",
            "*//d/a/mcpp-index/mcpp-index/ffmpeg-8.1.2/libswscale/yuv2rgb.c",
            "*/-Pconfig.asm",
        },
        generated_files = {
        ["mcpp_generated/config.h"] = [==[
/* Automatically generated by configure - do not modify! */
#ifndef FFMPEG_CONFIG_H
#define FFMPEG_CONFIG_H
#define FFMPEG_CONFIGURATION "--toolchain=msvc --disable-autodetect --disable-programs --disable-doc"
#define FFMPEG_LICENSE "LGPL version 2.1 or later"
#define CONFIG_THIS_YEAR 2026
#define FFMPEG_DATADIR "/usr/local/share/ffmpeg"
#define AVCONV_DATADIR "/usr/local/share/ffmpeg"
#define CC_IDENT "Microsoft (R) C/C++ Optimizing Compiler Version 19.51.36248 for x64"
#define OS_NAME win32
#define EXTERN_PREFIX ""
#define EXTERN_ASM 
#define BUILDSUF ""
#define SLIBSUF ".dll"
#define SWS_MAX_FILTER_SIZE 256
#define ARCH_AARCH64 0
#define ARCH_ARM 0
#define ARCH_IA64 0
#define ARCH_LOONGARCH 0
#define ARCH_LOONGARCH32 0
#define ARCH_LOONGARCH64 0
#define ARCH_M68K 0
#define ARCH_MIPS 0
#define ARCH_MIPS64 0
#define ARCH_PARISC 0
#define ARCH_PPC 0
#define ARCH_PPC64 0
#define ARCH_RISCV 0
#define ARCH_S390 0
#define ARCH_SPARC 0
#define ARCH_SPARC64 0
#define ARCH_TILEGX 0
#define ARCH_TILEPRO 0
#define ARCH_WASM 0
#define ARCH_X86 1
#define ARCH_X86_32 0
#define ARCH_X86_64 1
#define HAVE_ARMV5TE 0
#define HAVE_ARMV6 0
#define HAVE_ARMV6T2 0
#define HAVE_ARMV8 0
#define HAVE_ARM_CRC 0
#define HAVE_DOTPROD 0
#define HAVE_I8MM 0
#define HAVE_NEON 0
#define HAVE_VFP 0
#define HAVE_VFPV3 0
#define HAVE_SETEND 0
#define HAVE_SVE 0
#define HAVE_SVE2 0
#define HAVE_SME 0
#define HAVE_SME_I16I64 0
#define HAVE_SME2 0
#define HAVE_ALTIVEC 0
#define HAVE_DCBZL 0
#define HAVE_LDBRX 0
#define HAVE_POWER8 0
#define HAVE_PPC4XX 0
#define HAVE_VEC_XL 0
#define HAVE_VSX 0
#define HAVE_RV 0
#define HAVE_RVV 0
#define HAVE_RV_ZICBOP 1
#define HAVE_RV_ZVBB 0
#define HAVE_SIMD128 0
#define HAVE_AESNI 1
#define HAVE_CLMUL 1
#define HAVE_AMD3DNOW 1
#define HAVE_AMD3DNOWEXT 1
#define HAVE_AVX 1
#define HAVE_AVX2 1
#define HAVE_AVX512 1
#define HAVE_AVX512ICL 1
#define HAVE_FMA3 1
#define HAVE_FMA4 1
#define HAVE_MMX 1
#define HAVE_MMXEXT 1
#define HAVE_SSE 1
#define HAVE_SSE2 1
#define HAVE_SSE3 1
#define HAVE_SSE4 1
#define HAVE_SSE42 1
#define HAVE_SSSE3 1
#define HAVE_XOP 1
#define HAVE_I686 1
#define HAVE_MIPSFPU 0
#define HAVE_MIPS32R2 0
#define HAVE_MIPS32R5 0
#define HAVE_MIPS64R2 0
#define HAVE_MIPS32R6 0
#define HAVE_MIPS64R6 0
#define HAVE_MIPSDSP 0
#define HAVE_MIPSDSPR2 0
#define HAVE_MSA 0
#define HAVE_LOONGSON2 0
#define HAVE_LOONGSON3 0
#define HAVE_MMI 0
#define HAVE_LSX 0
#define HAVE_LASX 0
#define HAVE_ARMV5TE_EXTERNAL 0
#define HAVE_ARMV6_EXTERNAL 0
#define HAVE_ARMV6T2_EXTERNAL 0
#define HAVE_ARMV8_EXTERNAL 0
#define HAVE_ARM_CRC_EXTERNAL 0
#define HAVE_DOTPROD_EXTERNAL 0
#define HAVE_I8MM_EXTERNAL 0
#define HAVE_NEON_EXTERNAL 0
#define HAVE_VFP_EXTERNAL 0
#define HAVE_VFPV3_EXTERNAL 0
#define HAVE_SETEND_EXTERNAL 0
#define HAVE_SVE_EXTERNAL 0
#define HAVE_SVE2_EXTERNAL 0
#define HAVE_SME_EXTERNAL 0
#define HAVE_SME_I16I64_EXTERNAL 0
#define HAVE_SME2_EXTERNAL 0
#define HAVE_ALTIVEC_EXTERNAL 0
#define HAVE_DCBZL_EXTERNAL 0
#define HAVE_LDBRX_EXTERNAL 0
#define HAVE_POWER8_EXTERNAL 0
#define HAVE_PPC4XX_EXTERNAL 0
#define HAVE_VEC_XL_EXTERNAL 0
#define HAVE_VSX_EXTERNAL 0
#define HAVE_RV_EXTERNAL 0
#define HAVE_RVV_EXTERNAL 0
#define HAVE_RV_ZICBOP_EXTERNAL 0
#define HAVE_RV_ZVBB_EXTERNAL 0
#define HAVE_SIMD128_EXTERNAL 0
#define HAVE_AESNI_EXTERNAL 1
#define HAVE_CLMUL_EXTERNAL 1
#define HAVE_AMD3DNOW_EXTERNAL 0
#define HAVE_AMD3DNOWEXT_EXTERNAL 0
#define HAVE_AVX_EXTERNAL 1
#define HAVE_AVX2_EXTERNAL 1
#define HAVE_AVX512_EXTERNAL 1
#define HAVE_AVX512ICL_EXTERNAL 1
#define HAVE_FMA3_EXTERNAL 1
#define HAVE_FMA4_EXTERNAL 1
#define HAVE_MMX_EXTERNAL 1
#define HAVE_MMXEXT_EXTERNAL 1
#define HAVE_SSE_EXTERNAL 1
#define HAVE_SSE2_EXTERNAL 1
#define HAVE_SSE3_EXTERNAL 1
#define HAVE_SSE4_EXTERNAL 1
#define HAVE_SSE42_EXTERNAL 1
#define HAVE_SSSE3_EXTERNAL 1
#define HAVE_XOP_EXTERNAL 1
#define HAVE_I686_EXTERNAL 0
#define HAVE_MIPSFPU_EXTERNAL 0
#define HAVE_MIPS32R2_EXTERNAL 0
#define HAVE_MIPS32R5_EXTERNAL 0
#define HAVE_MIPS64R2_EXTERNAL 0
#define HAVE_MIPS32R6_EXTERNAL 0
#define HAVE_MIPS64R6_EXTERNAL 0
#define HAVE_MIPSDSP_EXTERNAL 0
#define HAVE_MIPSDSPR2_EXTERNAL 0
#define HAVE_MSA_EXTERNAL 0
#define HAVE_LOONGSON2_EXTERNAL 0
#define HAVE_LOONGSON3_EXTERNAL 0
#define HAVE_MMI_EXTERNAL 0
#define HAVE_LSX_EXTERNAL 0
#define HAVE_LASX_EXTERNAL 0
#define HAVE_ARMV5TE_INLINE 0
#define HAVE_ARMV6_INLINE 0
#define HAVE_ARMV6T2_INLINE 0
#define HAVE_ARMV8_INLINE 0
#define HAVE_ARM_CRC_INLINE 0
#define HAVE_DOTPROD_INLINE 0
#define HAVE_I8MM_INLINE 0
#define HAVE_NEON_INLINE 0
#define HAVE_VFP_INLINE 0
#define HAVE_VFPV3_INLINE 0
#define HAVE_SETEND_INLINE 0
#define HAVE_SVE_INLINE 0
#define HAVE_SVE2_INLINE 0
#define HAVE_SME_INLINE 0
#define HAVE_SME_I16I64_INLINE 0
#define HAVE_SME2_INLINE 0
#define HAVE_ALTIVEC_INLINE 0
#define HAVE_DCBZL_INLINE 0
#define HAVE_LDBRX_INLINE 0
#define HAVE_POWER8_INLINE 0
#define HAVE_PPC4XX_INLINE 0
#define HAVE_VEC_XL_INLINE 0
#define HAVE_VSX_INLINE 0
#define HAVE_RV_INLINE 0
#define HAVE_RVV_INLINE 0
#define HAVE_RV_ZICBOP_INLINE 0
#define HAVE_RV_ZVBB_INLINE 0
#define HAVE_SIMD128_INLINE 0
#define HAVE_AESNI_INLINE 0
#define HAVE_CLMUL_INLINE 0
#define HAVE_AMD3DNOW_INLINE 0
#define HAVE_AMD3DNOWEXT_INLINE 0
#define HAVE_AVX_INLINE 0
#define HAVE_AVX2_INLINE 0
#define HAVE_AVX512_INLINE 0
#define HAVE_AVX512ICL_INLINE 0
#define HAVE_FMA3_INLINE 0
#define HAVE_FMA4_INLINE 0
#define HAVE_MMX_INLINE 0
#define HAVE_MMXEXT_INLINE 0
#define HAVE_SSE_INLINE 0
#define HAVE_SSE2_INLINE 0
#define HAVE_SSE3_INLINE 0
#define HAVE_SSE4_INLINE 0
#define HAVE_SSE42_INLINE 0
#define HAVE_SSSE3_INLINE 0
#define HAVE_XOP_INLINE 0
#define HAVE_I686_INLINE 0
#define HAVE_MIPSFPU_INLINE 0
#define HAVE_MIPS32R2_INLINE 0
#define HAVE_MIPS32R5_INLINE 0
#define HAVE_MIPS64R2_INLINE 0
#define HAVE_MIPS32R6_INLINE 0
#define HAVE_MIPS64R6_INLINE 0
#define HAVE_MIPSDSP_INLINE 0
#define HAVE_MIPSDSPR2_INLINE 0
#define HAVE_MSA_INLINE 0
#define HAVE_LOONGSON2_INLINE 0
#define HAVE_LOONGSON3_INLINE 0
#define HAVE_MMI_INLINE 0
#define HAVE_LSX_INLINE 0
#define HAVE_LASX_INLINE 0
#define HAVE_ALIGNED_STACK 1
#define HAVE_FAST_64BIT 1
#define HAVE_FAST_CLZ 1
#define HAVE_FAST_CMOV 1
#define HAVE_FAST_FLOAT16 0
#define HAVE_SIMD_ALIGN_16 1
#define HAVE_SIMD_ALIGN_32 1
#define HAVE_SIMD_ALIGN_64 1
#define HAVE_MEMORYBARRIER 1
#define HAVE_MM_EMPTY 0
#define HAVE_RDTSC 1
#define HAVE_SEM_TIMEDWAIT 0
#define HAVE_INLINE_ASM 0
#define HAVE_SYMVER 0
#define HAVE_X86ASM 1
#define HAVE_BIGENDIAN 0
#define HAVE_FAST_UNALIGNED 1
#define HAVE_ARPA_INET_H 0
#define HAVE_ASM_HWPROBE_H 0
#define HAVE_ASM_TYPES_H 0
#define HAVE_CDIO_PARANOIA_H 0
#define HAVE_CDIO_PARANOIA_PARANOIA_H 0
#define HAVE_CUDA_H 0
#define HAVE_DISPATCH_DISPATCH_H 0
#define HAVE_DIRECT_H 1
#define HAVE_DIRENT_H 0
#define HAVE_DXGIDEBUG_H 1
#define HAVE_DXVA_H 1
#define HAVE_ES2_GL_H 0
#define HAVE_GSM_H 0
#define HAVE_IO_H 1
#define HAVE_LINUX_DMA_BUF_H 0
#define HAVE_LINUX_PERF_EVENT_H 0
#define HAVE_MALLOC_H 1
#define HAVE_POLL_H 0
#define HAVE_PTHREAD_NP_H 0
#define HAVE_SYS_HWPROBE_H 0
#define HAVE_SYS_PARAM_H 0
#define HAVE_SYS_RESOURCE_H 0
#define HAVE_SYS_SELECT_H 0
#define HAVE_SYS_SOUNDCARD_H 0
#define HAVE_SYS_TIME_H 0
#define HAVE_SYS_UN_H 0
#define HAVE_SYS_VIDEOIO_H 0
#define HAVE_TERMIOS_H 0
#define HAVE_UDPLITE_H 0
#define HAVE_UNISTD_H 0
#define HAVE_VALGRIND_VALGRIND_H 0
#define HAVE_WINDOWS_H 1
#define HAVE_WINSOCK2_H 1
#define HAVE_INTRINSICS_NEON 0
#define HAVE_INTRINSICS_SSE2 1
#define HAVE_ATANF 1
#define HAVE_ATAN2F 1
#define HAVE_CBRT 1
#define HAVE_CBRTF 1
#define HAVE_COPYSIGN 1
#define HAVE_COSF 1
#define HAVE_ERF 1
#define HAVE_EXP2 1
#define HAVE_EXP2F 1
#define HAVE_EXPF 1
#define HAVE_HYPOT 1
#define HAVE_ISFINITE 1
#define HAVE_ISINF 1
#define HAVE_ISNAN 1
#define HAVE_LDEXPF 1
#define HAVE_LLRINT 1
#define HAVE_LLRINTF 1
#define HAVE_LOG2 1
#define HAVE_LOG2F 1
#define HAVE_LOG10F 1
#define HAVE_LRINT 1
#define HAVE_LRINTF 1
#define HAVE_POWF 1
#define HAVE_RINT 1
#define HAVE_ROUND 1
#define HAVE_ROUNDF 1
#define HAVE_SINF 1
#define HAVE_TRUNC 1
#define HAVE_TRUNCF 1
#define HAVE_DOS_PATHS 1
#define HAVE_LIBC_MSVCRT 1
#define HAVE_MMAL_PARAMETER_VIDEO_MAX_NUM_CALLBACKS 0
#define HAVE_SECTION_DATA_REL_RO 0
#define HAVE_THREADS 1
#define HAVE_UWP 0
#define HAVE_WINRT 0
#define HAVE_ACCESS 1
#define HAVE_ALIGNED_MALLOC 1
#define HAVE_ARC4RANDOM_BUF 0
#define HAVE_CLOCK_GETTIME 0
#define HAVE_CLOSESOCKET 1
#define HAVE_COMMANDLINETOARGVW 1
#define HAVE_ELF_AUX_INFO 0
#define HAVE_FCNTL 0
#define HAVE_GETADDRINFO 1
#define HAVE_GETAUXVAL 0
#define HAVE_GETENV 1
#define HAVE_GETHRTIME 0
#define HAVE_GETOPT 0
#define HAVE_GETMODULEHANDLE 1
#define HAVE_GETPROCESSAFFINITYMASK 1
#define HAVE_GETPROCESSMEMORYINFO 1
#define HAVE_GETPROCESSTIMES 1
#define HAVE_GETRUSAGE 0
#define HAVE_GETSTDHANDLE 1
#define HAVE_GETSYSTEMTIMEASFILETIME 1
#define HAVE_GETTIMEOFDAY 0
#define HAVE_GLOB 0
#define HAVE_GLXGETPROCADDRESS 0
#define HAVE_GMTIME_R 0
#define HAVE_INET_ATON 0
#define HAVE_ISATTY 1
#define HAVE_KBHIT 1
#define HAVE_LOCALTIME_R 0
#define HAVE_LSTAT 0
#define HAVE_LZO1X_999_COMPRESS 0
#define HAVE_MACH_ABSOLUTE_TIME 0
#define HAVE_MAPVIEWOFFILE 1
#define HAVE_MEMALIGN 0
#define HAVE_MKSTEMP 0
#define HAVE_MMAP 0
#define HAVE_MPROTECT 0
#define HAVE_NANOSLEEP 0
#define HAVE_PEEKNAMEDPIPE 1
#define HAVE_POSIX_MEMALIGN 0
#define HAVE_PRCTL 0
#define HAVE_PTHREAD_CANCEL 0
#define HAVE_PTHREAD_SET_NAME_NP 0
#define HAVE_PTHREAD_SETNAME_NP 0
#define HAVE_SCHED_GETAFFINITY 0
#define HAVE_SECITEMIMPORT 0
#define HAVE_SETCONSOLETEXTATTRIBUTE 1
#define HAVE_SETCONSOLECTRLHANDLER 1
#define HAVE_SETDLLDIRECTORY 1
#define HAVE_SETMODE 1
#define HAVE_SETRLIMIT 0
#define HAVE_SLEEP 1
#define HAVE_STRERROR_R 0
#define HAVE_SYSCONF 0
#define HAVE_SYSCTL 0
#define HAVE_SYSCTLBYNAME 0
#define HAVE_TEMPNAM 1
#define HAVE_USLEEP 0
#define HAVE_UTGETOSTYPEFROMSTRING 0
#define HAVE_VIRTUALALLOC 1
#define HAVE_WGLGETPROCADDRESS 0
#define HAVE_BCRYPT 1
#define HAVE_VAAPI_DRM 0
#define HAVE_VAAPI_X11 0
#define HAVE_VAAPI_WIN32 0
#define HAVE_VDPAU_X11 0
#define HAVE_PTHREADS 0
#define HAVE_OS2THREADS 0
#define HAVE_W32THREADS 1
#define HAVE_AS_ARCH_DIRECTIVE 0
#define HAVE_AS_ARCHEXT_CRC_DIRECTIVE 0
#define HAVE_AS_ARCHEXT_DOTPROD_DIRECTIVE 0
#define HAVE_AS_ARCHEXT_I8MM_DIRECTIVE 0
#define HAVE_AS_ARCHEXT_SVE_DIRECTIVE 0
#define HAVE_AS_ARCHEXT_SVE2_DIRECTIVE 0
#define HAVE_AS_ARCHEXT_SME_DIRECTIVE 0
#define HAVE_AS_ARCHEXT_SME_I16I64_DIRECTIVE 0
#define HAVE_AS_ARCHEXT_SME2_DIRECTIVE 0
#define HAVE_AS_DN_DIRECTIVE 0
#define HAVE_AS_FPU_DIRECTIVE 0
#define HAVE_AS_FUNC 0
#define HAVE_AS_OBJECT_ARCH 0
#define HAVE_ASM_MOD_Q 0
#define HAVE_BLOCKS_EXTENSION 0
#define HAVE_EBP_AVAILABLE 0
#define HAVE_EBX_AVAILABLE 0
#define HAVE_GNU_AS 0
#define HAVE_GNU_WINDRES 1
#define HAVE_IBM_ASM 0
#define HAVE_INLINE_ASM_DIRECT_SYMBOL_REFS 0
#define HAVE_INLINE_ASM_LABELS 0
#define HAVE_INLINE_ASM_NONLOCAL_LABELS 0
#define HAVE_PRAGMA_DEPRECATED 1
#define HAVE_RSYNC_CONTIMEOUT 0
#define HAVE_SYMVER_ASM_LABEL 0
#define HAVE_SYMVER_GNU_ASM 0
#define HAVE_VFP_ARGS 0
#define HAVE_XFORM_ASM 0
#define HAVE_XMM_CLOBBERS 0
#define HAVE_DPI_AWARENESS_CONTEXT 1
#define HAVE_IDXGIOUTPUT5 1
#define HAVE___X_ABI_CWINDOWS_CGRAPHICS_CCAPTURE_CIGRAPHICSCAPTURESESSION5 1
#define HAVE_IDIRECT3DDXGIINTERFACEACCESS 0
#define HAVE_KCMVIDEOCODECTYPE_HEVC 0
#define HAVE_KCMVIDEOCODECTYPE_HEVCWITHALPHA 0
#define HAVE_KCMVIDEOCODECTYPE_VP9 0
#define HAVE_KCMVIDEOCODECTYPE_AV1 0
#define HAVE_KCVPIXELFORMATTYPE_420YPCBCR10BIPLANARVIDEORANGE 0
#define HAVE_KCVPIXELFORMATTYPE_422YPCBCR8BIPLANARVIDEORANGE 0
#define HAVE_KCVPIXELFORMATTYPE_422YPCBCR10BIPLANARVIDEORANGE 0
#define HAVE_KCVPIXELFORMATTYPE_422YPCBCR16BIPLANARVIDEORANGE 0
#define HAVE_KCVPIXELFORMATTYPE_444YPCBCR8BIPLANARVIDEORANGE 0
#define HAVE_KCVPIXELFORMATTYPE_444YPCBCR10BIPLANARVIDEORANGE 0
#define HAVE_KCVPIXELFORMATTYPE_444YPCBCR16BIPLANARVIDEORANGE 0
#define HAVE_KCVPIXELFORMATTYPE_422YPCBCR8_YUVS 0
#define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_SMPTE_ST_2084_PQ 0
#define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_ITU_R_2100_HLG 0
#define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_LINEAR 0
#define HAVE_KCVIMAGEBUFFERYCBCRMATRIX_ITU_R_2020 0
#define HAVE_KCVIMAGEBUFFERCOLORPRIMARIES_ITU_R_2020 0
#define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_ITU_R_2020 0
#define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_SMPTE_ST_428_1 0
#define HAVE_KVTQPMODULATIONLEVEL_DEFAULT 0
#define HAVE_SECPKGCONTEXT_KEYINGMATERIALINFO 1
#define HAVE_SOCKLEN_T 1
#define HAVE_STRUCT_ADDRINFO 1
#define HAVE_STRUCT_GROUP_SOURCE_REQ 1
#define HAVE_STRUCT_IP_MREQ_SOURCE 1
#define HAVE_STRUCT_IPV6_MREQ 1
#define HAVE_STRUCT_MSGHDR_MSG_FLAGS 0
#define HAVE_STRUCT_POLLFD 1
#define HAVE_STRUCT_RUSAGE_RU_MAXRSS 0
#define HAVE_STRUCT_SCTP_EVENT_SUBSCRIBE 0
#define HAVE_STRUCT_SOCKADDR_IN6 1
#define HAVE_STRUCT_SOCKADDR_SA_LEN 0
#define HAVE_STRUCT_SOCKADDR_STORAGE 1
#define HAVE_STRUCT_STAT_ST_MTIM_TV_NSEC 0
#define HAVE_STRUCT_V4L2_FRMIVALENUM_DISCRETE 0
#define HAVE_STRUCT_MFXCONFIGINTERFACE 0
#define HAVE_GZIP 1
#define HAVE_IOCTL_POSIX 0
#define HAVE_LIBDRM_GETFB2 0
#define HAVE_MAKEINFO 0
#define HAVE_MAKEINFO_HTML 0
#define HAVE_OPENCL_D3D11 0
#define HAVE_OPENCL_DRM_ARM 0
#define HAVE_OPENCL_DRM_BEIGNET 0
#define HAVE_OPENCL_DXVA2 0
#define HAVE_OPENCL_VAAPI_BEIGNET 0
#define HAVE_OPENCL_VAAPI_INTEL_MEDIA 0
#define HAVE_OPENCL_VIDEOTOOLBOX 0
#define HAVE_PERL 1
#define HAVE_POD2MAN 1
#define HAVE_TEXI2HTML 0
#define HAVE_XMLLINT 1
#define HAVE_ZLIB_GZIP 0
#define HAVE_OPENVINO2 0
#define CONFIG_DOC 0
#define CONFIG_HTMLPAGES 0
#define CONFIG_MANPAGES 1
#define CONFIG_PODPAGES 1
#define CONFIG_TXTPAGES 0
#define CONFIG_AVIO_HTTP_SERVE_FILES_EXAMPLE 1
#define CONFIG_AVIO_LIST_DIR_EXAMPLE 1
#define CONFIG_AVIO_READ_CALLBACK_EXAMPLE 1
#define CONFIG_DECODE_AUDIO_EXAMPLE 1
#define CONFIG_DECODE_FILTER_AUDIO_EXAMPLE 1
#define CONFIG_DECODE_FILTER_VIDEO_EXAMPLE 1
#define CONFIG_DECODE_VIDEO_EXAMPLE 1
#define CONFIG_DEMUX_DECODE_EXAMPLE 1
#define CONFIG_ENCODE_AUDIO_EXAMPLE 1
#define CONFIG_ENCODE_VIDEO_EXAMPLE 1
#define CONFIG_EXTRACT_MVS_EXAMPLE 1
#define CONFIG_FILTER_AUDIO_EXAMPLE 1
#define CONFIG_HW_DECODE_EXAMPLE 1
#define CONFIG_MUX_EXAMPLE 1
#define CONFIG_QSV_DECODE_EXAMPLE 0
#define CONFIG_REMUX_EXAMPLE 1
#define CONFIG_RESAMPLE_AUDIO_EXAMPLE 1
#define CONFIG_SCALE_VIDEO_EXAMPLE 1
#define CONFIG_SHOW_METADATA_EXAMPLE 1
#define CONFIG_TRANSCODE_AAC_EXAMPLE 1
#define CONFIG_TRANSCODE_EXAMPLE 1
#define CONFIG_VAAPI_ENCODE_EXAMPLE 0
#define CONFIG_VAAPI_TRANSCODE_EXAMPLE 0
#define CONFIG_QSV_TRANSCODE_EXAMPLE 0
#define CONFIG_AVISYNTH 0
#define CONFIG_FREI0R 0
#define CONFIG_LIBCDIO 0
#define CONFIG_LIBDAVS2 0
#define CONFIG_LIBDVDNAV 0
#define CONFIG_LIBDVDREAD 0
#define CONFIG_LIBRUBBERBAND 0
#define CONFIG_LIBVIDSTAB 0
#define CONFIG_LIBX264 0
#define CONFIG_LIBX265 0
#define CONFIG_LIBXAVS 0
#define CONFIG_LIBXAVS2 0
#define CONFIG_LIBXVID 0
#define CONFIG_DECKLINK 0
#define CONFIG_LIBFDK_AAC 0
#define CONFIG_LIBMPEGHDEC 0
#define CONFIG_GMP 0
#define CONFIG_LIBARIBB24 0
#define CONFIG_LIBLENSFUN 0
#define CONFIG_LIBOPENCORE_AMRNB 0
#define CONFIG_LIBOPENCORE_AMRWB 0
#define CONFIG_LIBVO_AMRWBENC 0
#define CONFIG_MBEDTLS 0
#define CONFIG_RKMPP 0
#define CONFIG_LIBSMBCLIENT 0
#define CONFIG_CAIRO 0
#define CONFIG_CHROMAPRINT 0
#define CONFIG_GCRYPT 0
#define CONFIG_GNUTLS 0
#define CONFIG_JNI 0
#define CONFIG_LADSPA 0
#define CONFIG_LCMS2 0
#define CONFIG_LIBAOM 0
#define CONFIG_LIBARIBCAPTION 0
#define CONFIG_LIBASS 0
#define CONFIG_LIBBLURAY 0
#define CONFIG_LIBBS2B 0
#define CONFIG_LIBCACA 0
#define CONFIG_LIBCELT 0
#define CONFIG_LIBCODEC2 0
#define CONFIG_LIBDAV1D 0
#define CONFIG_LIBDC1394 0
#define CONFIG_LIBFLITE 0
#define CONFIG_LIBFONTCONFIG 0
#define CONFIG_LIBFREETYPE 0
#define CONFIG_LIBFRIBIDI 0
#define CONFIG_LIBHARFBUZZ 0
#define CONFIG_LIBGLSLANG 0
#define CONFIG_LIBGME 0
#define CONFIG_LIBGSM 0
#define CONFIG_LIBIEC61883 0
#define CONFIG_LIBILBC 0
#define CONFIG_LIBJACK 0
#define CONFIG_LIBJXL 0
#define CONFIG_LIBKLVANC 0
#define CONFIG_LIBKVAZAAR 0
#define CONFIG_LIBLC3 0
#define CONFIG_LIBLCEVC_DEC 0
#define CONFIG_LIBMODPLUG 0
#define CONFIG_LIBMP3LAME 0
#define CONFIG_LIBMYSOFA 0
#define CONFIG_LIBOAPV 0
#define CONFIG_LIBOPENCV 0
#define CONFIG_LIBOPENCOLORIO 0
#define CONFIG_LIBOPENH264 0
#define CONFIG_LIBOPENJPEG 0
#define CONFIG_LIBOPENMPT 0
#define CONFIG_LIBOPENVINO 0
#define CONFIG_LIBOPUS 0
#define CONFIG_LIBPLACEBO 0
#define CONFIG_LIBPULSE 0
#define CONFIG_LIBQRENCODE 0
#define CONFIG_LIBQUIRC 0
#define CONFIG_LIBRABBITMQ 0
#define CONFIG_LIBRAV1E 0
#define CONFIG_LIBRIST 0
#define CONFIG_LIBRSVG 0
#define CONFIG_LIBRTMP 0
#define CONFIG_LIBSHADERC 0
#define CONFIG_LIBSHINE 0
#define CONFIG_LIBSMBCLIENT 0
#define CONFIG_LIBSNAPPY 0
#define CONFIG_LIBSOXR 0
#define CONFIG_LIBSPEEX 0
#define CONFIG_LIBSRT 0
#define CONFIG_LIBSSH 0
#define CONFIG_LIBSVTAV1 0
#define CONFIG_LIBSVTJPEGXS 0
#define CONFIG_LIBTENSORFLOW 0
#define CONFIG_LIBTESSERACT 0
#define CONFIG_LIBTHEORA 0
#define CONFIG_LIBTLS 0
#define CONFIG_LIBTORCH 0
#define CONFIG_LIBTWOLAME 0
#define CONFIG_LIBUAVS3D 0
#define CONFIG_LIBV4L2 0
#define CONFIG_LIBVMAF 0
#define CONFIG_LIBVORBIS 0
#define CONFIG_LIBVPX 0
#define CONFIG_LIBVVENC 0
#define CONFIG_LIBWEBP 0
#define CONFIG_LIBXEVD 0
#define CONFIG_LIBXEVDB 0
#define CONFIG_LIBXEVE 0
#define CONFIG_LIBXEVEB 0
#define CONFIG_LIBXML2 0
#define CONFIG_LIBZIMG 0
#define CONFIG_LIBZMQ 0
#define CONFIG_LIBZVBI 0
#define CONFIG_LV2 0
#define CONFIG_MEDIACODEC 0
#define CONFIG_OHCODEC 0
#define CONFIG_OPENAL 0
#define CONFIG_OPENGL 0
#define CONFIG_OPENSSL 0
#define CONFIG_POCKETSPHINX 0
#define CONFIG_VAPOURSYNTH 0
#define CONFIG_VULKAN_STATIC 0
#define CONFIG_WHISPER 0
#define CONFIG_ALSA 0
#define CONFIG_APPKIT 0
#define CONFIG_AVFOUNDATION 0
#define CONFIG_BZLIB 0
#define CONFIG_COREIMAGE 0
#define CONFIG_ICONV 0
#define CONFIG_LIBXCB 0
#define CONFIG_LIBXCB_SHM 0
#define CONFIG_LIBXCB_SHAPE 0
#define CONFIG_LIBXCB_XFIXES 0
#define CONFIG_LZMA 0
#define CONFIG_MEDIAFOUNDATION 0
#define CONFIG_METAL 0
#define CONFIG_SCHANNEL 0
#define CONFIG_SDL2 0
#define CONFIG_SECURETRANSPORT 0
#define CONFIG_SNDIO 0
#define CONFIG_XLIB 0
#define CONFIG_ZLIB 0
#define CONFIG_CUDA_NVCC 0
#define CONFIG_CUDA_SDK 0
#define CONFIG_LIBNPP 0
#define CONFIG_LIBMFX 0
#define CONFIG_LIBVPL 0
#define CONFIG_MMAL 0
#define CONFIG_OMX 0
#define CONFIG_OPENCL 0
#define CONFIG_AMF 0
#define CONFIG_AUDIOTOOLBOX 0
#define CONFIG_CUDA 0
#define CONFIG_CUDA_LLVM 0
#define CONFIG_CUVID 0
#define CONFIG_D3D11VA 0
#define CONFIG_D3D12VA 0
#define CONFIG_DXVA2 0
#define CONFIG_FFNVCODEC 0
#define CONFIG_LIBDRM 0
#define CONFIG_NVDEC 0
#define CONFIG_NVENC 0
#define CONFIG_VAAPI 0
#define CONFIG_VDPAU 0
#define CONFIG_VIDEOTOOLBOX 0
#define CONFIG_VULKAN 0
#define CONFIG_V4L2_M2M 0
#define CONFIG_FTRAPV 0
#define CONFIG_GRAY 0
#define CONFIG_HARDCODED_TABLES 0
#define CONFIG_OMX_RPI 0
#define CONFIG_RUNTIME_CPUDETECT 1
#define CONFIG_SAFE_BITSTREAM_READER 1
#define CONFIG_SHARED 0
#define CONFIG_SMALL 0
#define CONFIG_STATIC 1
#define CONFIG_SWSCALE_ALPHA 1
#define CONFIG_UNSTABLE 1
#define CONFIG_GPL 0
#define CONFIG_NONFREE 0
#define CONFIG_VERSION3 0
#define CONFIG_AVDEVICE 1
#define CONFIG_AVFILTER 1
#define CONFIG_SWSCALE 1
#define CONFIG_AVFORMAT 1
#define CONFIG_AVCODEC 1
#define CONFIG_SWRESAMPLE 1
#define CONFIG_AVUTIL 1
#define CONFIG_FFPLAY 0
#define CONFIG_FFPROBE 0
#define CONFIG_FFMPEG 0
#define CONFIG_DWT 1
#define CONFIG_ERROR_RESILIENCE 1
#define CONFIG_FAAN 1
#define CONFIG_FAST_UNALIGNED 1
#define CONFIG_IAMF 1
#define CONFIG_LSP 1
#define CONFIG_PIXELUTILS 1
#define CONFIG_NETWORK 1
#define CONFIG_AUTODETECT 0
#define CONFIG_FONTCONFIG 0
#define CONFIG_LARGE_TESTS 1
#define CONFIG_LINUX_PERF 0
#define CONFIG_MACOS_KPERF 0
#define CONFIG_MEMORY_POISONING 0
#define CONFIG_NEON_CLOBBER_TEST 0
#define CONFIG_OSSFUZZ 0
#define CONFIG_PIC 0
#define CONFIG_SHADER_COMPRESSION 0
#define CONFIG_RESOURCE_COMPRESSION 0
#define CONFIG_THUMB 0
#define CONFIG_VALGRIND_BACKTRACE 0
#define CONFIG_XMM_CLOBBER_TEST 0
#define CONFIG_BSFS 1
#define CONFIG_DECODERS 1
#define CONFIG_ENCODERS 1
#define CONFIG_HWACCELS 0
#define CONFIG_PARSERS 1
#define CONFIG_INDEVS 1
#define CONFIG_OUTDEVS 0
#define CONFIG_FILTERS 1
#define CONFIG_DEMUXERS 1
#define CONFIG_MUXERS 1
#define CONFIG_PROTOCOLS 1
#define CONFIG_AANDCTTABLES 1
#define CONFIG_AC3DSP 1
#define CONFIG_ADTS_HEADER 1
#define CONFIG_ATSC_A53 1
#define CONFIG_AUDIO_FRAME_QUEUE 1
#define CONFIG_AUDIODSP 1
#define CONFIG_BLOCKDSP 1
#define CONFIG_BSWAPDSP 1
#define CONFIG_CABAC 1
#define CONFIG_CBS 1
#define CONFIG_CBS_APV 1
#define CONFIG_CBS_AV1 1
#define CONFIG_CBS_H264 1
#define CONFIG_CBS_H265 1
#define CONFIG_CBS_H266 1
#define CONFIG_CBS_JPEG 0
#define CONFIG_CBS_LCEVC 1
#define CONFIG_CBS_MPEG2 1
#define CONFIG_CBS_VP8 1
#define CONFIG_CBS_VP9 1
#define CONFIG_CELP_MATH 1
#define CONFIG_D3D12_INTRA_REFRESH 1
#define CONFIG_D3D12_MOTION_ESTIMATOR 1
#define CONFIG_D3D12_VIDEO_PROCESS_REFERENCE_INFO 1
#define CONFIG_D3D12VA_ENCODE 0
#define CONFIG_D3D12VA_ME_PRECISION_EIGHTH_PIXEL 1
#define CONFIG_DEFLATE_WRAPPER 0
#define CONFIG_DIRAC_PARSE 1
#define CONFIG_DNN 0
#define CONFIG_DOVI_RPUDEC 1
#define CONFIG_DOVI_RPUENC 1
#define CONFIG_DVPROFILE 1
#define CONFIG_EVCPARSE 1
#define CONFIG_FAANDCT 1
#define CONFIG_FAANIDCT 1
#define CONFIG_FDCTDSP 1
#define CONFIG_FMTCONVERT 1
#define CONFIG_FRAME_THREAD_ENCODER 1
#define CONFIG_G722DSP 1
#define CONFIG_GOLOMB 1
#define CONFIG_GPLV3 0
#define CONFIG_H263DSP 1
#define CONFIG_H264CHROMA 1
#define CONFIG_H264DSP 1
#define CONFIG_H264PARSE 1
#define CONFIG_H264PRED 1
#define CONFIG_H264QPEL 1
#define CONFIG_H264_SEI 1
#define CONFIG_HEVCPARSE 1
#define CONFIG_HEVC_SEI 1
#define CONFIG_HPELDSP 1
#define CONFIG_HUFFMAN 1
#define CONFIG_HUFFYUVDSP 1
#define CONFIG_HUFFYUVENCDSP 1
#define CONFIG_IAMFDEC 1
#define CONFIG_IAMFENC 1
#define CONFIG_IDCTDSP 1
#define CONFIG_INFLATE_WRAPPER 0
#define CONFIG_INTRAX8 1
#define CONFIG_ISO_MEDIA 1
#define CONFIG_ISO_WRITER 1
#define CONFIG_IVIDSP 1
#define CONFIG_JPEGTABLES 1
#define CONFIG_LGPLV3 0
#define CONFIG_LIBX262 0
#define CONFIG_LIBX264_HDR10 0
#define CONFIG_LLAUDDSP 1
#define CONFIG_LLVIDDSP 1
#define CONFIG_LLVIDENCDSP 1
#define CONFIG_LPC 1
#define CONFIG_LZF 1
#define CONFIG_ME_CMP 1
#define CONFIG_MPEG_ER 1
#define CONFIG_MPEGAUDIO 1
#define CONFIG_MPEGAUDIODSP 1
#define CONFIG_MPEGAUDIOHEADER 1
#define CONFIG_MPEG4AUDIO 1
#define CONFIG_MPEGVIDEO 1
#define CONFIG_MPEGVIDEODEC 1
#define CONFIG_MPEGVIDEOENC 1
#define CONFIG_MPEGVIDEOENCDSP 1
#define CONFIG_MSMPEG4DEC 1
#define CONFIG_MSMPEG4ENC 1
#define CONFIG_MSS34DSP 1
#define CONFIG_PIXBLOCKDSP 1
#define CONFIG_QPELDSP 1
#define CONFIG_QSV 0
#define CONFIG_QSVDEC 0
#define CONFIG_QSVENC 0
#define CONFIG_QSVVPP 0
#define CONFIG_RANGECODER 1
#define CONFIG_RIFFDEC 1
#define CONFIG_RIFFENC 1
#define CONFIG_RTPDEC 1
#define CONFIG_RTPENC_CHAIN 1
#define CONFIG_RV34DSP 1
#define CONFIG_SCENE_SAD 1
#define CONFIG_SINEWIN 1
#define CONFIG_SMPTE_436M 1
#define CONFIG_SNAPPY 1
#define CONFIG_SRTP 1
#define CONFIG_STARTCODE 1
#define CONFIG_TEXTUREDSP 1
#define CONFIG_TEXTUREDSPENC 1
#define CONFIG_TPELDSP 1
#define CONFIG_VAAPI_1 0
#define CONFIG_VAAPI_ENCODE 0
#define CONFIG_VULKAN_1_4 0
#define CONFIG_VC1DSP 1
#define CONFIG_VIDEODSP 1
#define CONFIG_VP3DSP 1
#define CONFIG_VP8DSP 1
#define CONFIG_VULKAN_ENCODE 0
#define CONFIG_VVC_SEI 1
#define CONFIG_WMA_FREQS 1
#define CONFIG_WMV2DSP 1
#endif /* FFMPEG_CONFIG_H */
]==],
        ["mcpp_generated/config_components.h"] = [==[
/* Automatically generated by configure - do not modify! */
#ifndef FFMPEG_CONFIG_COMPONENTS_H
#define FFMPEG_CONFIG_COMPONENTS_H
#define CONFIG_AAC_ADTSTOASC_BSF 1
#define CONFIG_AHX_TO_MP2_BSF 0
#define CONFIG_APV_METADATA_BSF 1
#define CONFIG_AV1_FRAME_MERGE_BSF 1
#define CONFIG_AV1_FRAME_SPLIT_BSF 1
#define CONFIG_AV1_METADATA_BSF 1
#define CONFIG_CHOMP_BSF 1
#define CONFIG_DUMP_EXTRADATA_BSF 1
#define CONFIG_DCA_CORE_BSF 1
#define CONFIG_DOVI_RPU_BSF 1
#define CONFIG_DTS2PTS_BSF 1
#define CONFIG_DV_ERROR_MARKER_BSF 1
#define CONFIG_EAC3_CORE_BSF 1
#define CONFIG_EIA608_TO_SMPTE436M_BSF 1
#define CONFIG_EVC_FRAME_MERGE_BSF 1
#define CONFIG_EXTRACT_EXTRADATA_BSF 1
#define CONFIG_FILTER_UNITS_BSF 1
#define CONFIG_H264_METADATA_BSF 1
#define CONFIG_H264_MP4TOANNEXB_BSF 1
#define CONFIG_H264_REDUNDANT_PPS_BSF 1
#define CONFIG_HAPQA_EXTRACT_BSF 1
#define CONFIG_HEVC_METADATA_BSF 1
#define CONFIG_HEVC_MP4TOANNEXB_BSF 1
#define CONFIG_IMX_DUMP_HEADER_BSF 1
#define CONFIG_LCEVC_METADATA_BSF 1
#define CONFIG_MEDIA100_TO_MJPEGB_BSF 1
#define CONFIG_MJPEG2JPEG_BSF 1
#define CONFIG_MJPEGA_DUMP_HEADER_BSF 1
#define CONFIG_MPEG2_METADATA_BSF 1
#define CONFIG_MPEG4_UNPACK_BFRAMES_BSF 1
#define CONFIG_MOV2TEXTSUB_BSF 1
#define CONFIG_NOISE_BSF 1
#define CONFIG_NULL_BSF 1
#define CONFIG_OPUS_METADATA_BSF 1
#define CONFIG_PCM_RECHUNK_BSF 1
#define CONFIG_PGS_FRAME_MERGE_BSF 1
#define CONFIG_PRORES_METADATA_BSF 1
#define CONFIG_REMOVE_EXTRADATA_BSF 1
#define CONFIG_SETTS_BSF 1
#define CONFIG_SHOWINFO_BSF 1
#define CONFIG_SMPTE436M_TO_EIA608_BSF 1
#define CONFIG_TEXT2MOVSUB_BSF 1
#define CONFIG_TRACE_HEADERS_BSF 1
#define CONFIG_TRUEHD_CORE_BSF 1
#define CONFIG_VP9_METADATA_BSF 1
#define CONFIG_VP9_RAW_REORDER_BSF 1
#define CONFIG_VP9_SUPERFRAME_BSF 1
#define CONFIG_VP9_SUPERFRAME_SPLIT_BSF 1
#define CONFIG_VVC_METADATA_BSF 1
#define CONFIG_VVC_MP4TOANNEXB_BSF 1
#define CONFIG_AASC_DECODER 1
#define CONFIG_AIC_DECODER 1
#define CONFIG_ALIAS_PIX_DECODER 1
#define CONFIG_AGM_DECODER 1
#define CONFIG_AMV_DECODER 1
#define CONFIG_ANM_DECODER 1
#define CONFIG_ANSI_DECODER 1
#define CONFIG_APNG_DECODER 0
#define CONFIG_APV_DECODER 1
#define CONFIG_ARBC_DECODER 1
#define CONFIG_ARGO_DECODER 1
#define CONFIG_ASV1_DECODER 1
#define CONFIG_ASV2_DECODER 1
#define CONFIG_AURA_DECODER 1
#define CONFIG_AURA2_DECODER 1
#define CONFIG_AVRP_DECODER 1
#define CONFIG_AVRN_DECODER 1
#define CONFIG_AVS_DECODER 1
#define CONFIG_AVUI_DECODER 1
#define CONFIG_BETHSOFTVID_DECODER 1
#define CONFIG_BFI_DECODER 1
#define CONFIG_BINK_DECODER 1
#define CONFIG_BITPACKED_DECODER 1
#define CONFIG_BMP_DECODER 1
#define CONFIG_BMV_VIDEO_DECODER 1
#define CONFIG_BRENDER_PIX_DECODER 1
#define CONFIG_C93_DECODER 1
#define CONFIG_CAVS_DECODER 1
#define CONFIG_CDGRAPHICS_DECODER 1
#define CONFIG_CDTOONS_DECODER 1
#define CONFIG_CDXL_DECODER 1
#define CONFIG_CFHD_DECODER 1
#define CONFIG_CINEPAK_DECODER 1
#define CONFIG_CLEARVIDEO_DECODER 1
#define CONFIG_CLJR_DECODER 1
#define CONFIG_CLLC_DECODER 1
#define CONFIG_COMFORTNOISE_DECODER 1
#define CONFIG_CPIA_DECODER 1
#define CONFIG_CRI_DECODER 1
#define CONFIG_CSCD_DECODER 1
#define CONFIG_CYUV_DECODER 1
#define CONFIG_DDS_DECODER 1
#define CONFIG_DFA_DECODER 1
#define CONFIG_DIRAC_DECODER 1
#define CONFIG_DNXHD_DECODER 1
#define CONFIG_DPX_DECODER 1
#define CONFIG_DSICINVIDEO_DECODER 1
#define CONFIG_DVAUDIO_DECODER 1
#define CONFIG_DVVIDEO_DECODER 1
#define CONFIG_DXA_DECODER 0
#define CONFIG_DXTORY_DECODER 1
#define CONFIG_DXV_DECODER 1
#define CONFIG_EACMV_DECODER 1
#define CONFIG_EAMAD_DECODER 1
#define CONFIG_EATGQ_DECODER 1
#define CONFIG_EATGV_DECODER 1
#define CONFIG_EATQI_DECODER 1
#define CONFIG_EIGHTBPS_DECODER 1
#define CONFIG_EIGHTSVX_EXP_DECODER 1
#define CONFIG_EIGHTSVX_FIB_DECODER 1
#define CONFIG_ESCAPE124_DECODER 1
#define CONFIG_ESCAPE130_DECODER 1
#define CONFIG_EXR_DECODER 0
#define CONFIG_FFV1_DECODER 1
#define CONFIG_FFVHUFF_DECODER 1
#define CONFIG_FIC_DECODER 1
#define CONFIG_FITS_DECODER 1
#define CONFIG_FLASHSV_DECODER 0
#define CONFIG_FLASHSV2_DECODER 0
#define CONFIG_FLIC_DECODER 1
#define CONFIG_FLV_DECODER 1
#define CONFIG_FMVC_DECODER 1
#define CONFIG_FOURXM_DECODER 1
#define CONFIG_FRAPS_DECODER 1
#define CONFIG_FRWU_DECODER 1
#define CONFIG_G2M_DECODER 0
#define CONFIG_GDV_DECODER 1
#define CONFIG_GEM_DECODER 1
#define CONFIG_GIF_DECODER 1
#define CONFIG_H261_DECODER 1
#define CONFIG_H263_DECODER 1
#define CONFIG_H263I_DECODER 1
#define CONFIG_H263P_DECODER 1
#define CONFIG_H263_V4L2M2M_DECODER 0
#define CONFIG_H264_DECODER 1
#define CONFIG_H264_V4L2M2M_DECODER 0
#define CONFIG_H264_MEDIACODEC_DECODER 0
#define CONFIG_H264_MMAL_DECODER 0
#define CONFIG_H264_QSV_DECODER 0
#define CONFIG_H264_RKMPP_DECODER 0
#define CONFIG_HAP_DECODER 1
#define CONFIG_HEVC_DECODER 1
#define CONFIG_HEVC_QSV_DECODER 0
#define CONFIG_HEVC_RKMPP_DECODER 0
#define CONFIG_HEVC_V4L2M2M_DECODER 0
#define CONFIG_HNM4_VIDEO_DECODER 1
#define CONFIG_HQ_HQA_DECODER 1
#define CONFIG_HQX_DECODER 1
#define CONFIG_HUFFYUV_DECODER 1
#define CONFIG_HYMT_DECODER 1
#define CONFIG_IDCIN_DECODER 1
#define CONFIG_IFF_ILBM_DECODER 1
#define CONFIG_IMM4_DECODER 1
#define CONFIG_IMM5_DECODER 1
#define CONFIG_INDEO2_DECODER 1
#define CONFIG_INDEO3_DECODER 1
#define CONFIG_INDEO4_DECODER 1
#define CONFIG_INDEO5_DECODER 1
#define CONFIG_INTERPLAY_VIDEO_DECODER 1
#define CONFIG_IPU_DECODER 1
#define CONFIG_JPEG2000_DECODER 1
#define CONFIG_JPEGLS_DECODER 1
#define CONFIG_JV_DECODER 1
#define CONFIG_KGV1_DECODER 1
#define CONFIG_KMVC_DECODER 1
#define CONFIG_LAGARITH_DECODER 1
#define CONFIG_LEAD_DECODER 1
#define CONFIG_LOCO_DECODER 1
#define CONFIG_LSCR_DECODER 0
#define CONFIG_M101_DECODER 1
#define CONFIG_MAGICYUV_DECODER 1
#define CONFIG_MDEC_DECODER 1
#define CONFIG_MEDIA100_DECODER 1
#define CONFIG_MIMIC_DECODER 1
#define CONFIG_MJPEG_DECODER 1
#define CONFIG_MJPEGB_DECODER 1
#define CONFIG_MMVIDEO_DECODER 1
#define CONFIG_MOBICLIP_DECODER 1
#define CONFIG_MOTIONPIXELS_DECODER 1
#define CONFIG_MPEG1VIDEO_DECODER 1
#define CONFIG_MPEG2VIDEO_DECODER 1
#define CONFIG_MPEG4_DECODER 1
#define CONFIG_MPEG4_V4L2M2M_DECODER 0
#define CONFIG_MPEG4_MMAL_DECODER 0
#define CONFIG_MPEGVIDEO_DECODER 1
#define CONFIG_MPEG1_V4L2M2M_DECODER 0
#define CONFIG_MPEG2_MMAL_DECODER 0
#define CONFIG_MPEG2_V4L2M2M_DECODER 0
#define CONFIG_MPEG2_QSV_DECODER 0
#define CONFIG_MPEG2_MEDIACODEC_DECODER 0
#define CONFIG_MSA1_DECODER 1
#define CONFIG_MSCC_DECODER 0
#define CONFIG_MSMPEG4V1_DECODER 1
#define CONFIG_MSMPEG4V2_DECODER 1
#define CONFIG_MSMPEG4V3_DECODER 1
#define CONFIG_MSP2_DECODER 1
#define CONFIG_MSRLE_DECODER 1
#define CONFIG_MSS1_DECODER 1
#define CONFIG_MSS2_DECODER 1
#define CONFIG_MSVIDEO1_DECODER 1
#define CONFIG_MSZH_DECODER 1
#define CONFIG_MTS2_DECODER 1
#define CONFIG_MV30_DECODER 1
#define CONFIG_MVC1_DECODER 1
#define CONFIG_MVC2_DECODER 1
#define CONFIG_MVDV_DECODER 1
#define CONFIG_MVHA_DECODER 0
#define CONFIG_MWSC_DECODER 0
#define CONFIG_MXPEG_DECODER 1
#define CONFIG_NOTCHLC_DECODER 1
#define CONFIG_NUV_DECODER 1
#define CONFIG_PAF_VIDEO_DECODER 1
#define CONFIG_PAM_DECODER 1
#define CONFIG_PBM_DECODER 1
#define CONFIG_PCX_DECODER 1
#define CONFIG_PDV_DECODER 0
#define CONFIG_PFM_DECODER 1
#define CONFIG_PGM_DECODER 1
#define CONFIG_PGMYUV_DECODER 1
#define CONFIG_PGX_DECODER 1
#define CONFIG_PHM_DECODER 1
#define CONFIG_PHOTOCD_DECODER 1
#define CONFIG_PICTOR_DECODER 1
#define CONFIG_PIXLET_DECODER 1
#define CONFIG_PNG_DECODER 0
#define CONFIG_PPM_DECODER 1
#define CONFIG_PRORES_DECODER 1
#define CONFIG_PRORES_RAW_DECODER 1
#define CONFIG_PROSUMER_DECODER 1
#define CONFIG_PSD_DECODER 1
#define CONFIG_PTX_DECODER 1
#define CONFIG_QDRAW_DECODER 1
#define CONFIG_QOI_DECODER 1
#define CONFIG_QPEG_DECODER 1
#define CONFIG_QTRLE_DECODER 1
#define CONFIG_R10K_DECODER 1
#define CONFIG_R210_DECODER 1
#define CONFIG_RASC_DECODER 0
#define CONFIG_RAWVIDEO_DECODER 1
#define CONFIG_RKA_DECODER 1
#define CONFIG_RL2_DECODER 1
#define CONFIG_ROQ_DECODER 1
#define CONFIG_RPZA_DECODER 1
#define CONFIG_RSCC_DECODER 0
#define CONFIG_RTV1_DECODER 1
#define CONFIG_RV10_DECODER 1
#define CONFIG_RV20_DECODER 1
#define CONFIG_RV30_DECODER 1
#define CONFIG_RV40_DECODER 1
#define CONFIG_RV60_DECODER 1
#define CONFIG_S302M_DECODER 1
#define CONFIG_SANM_DECODER 1
#define CONFIG_SCPR_DECODER 1
#define CONFIG_SCREENPRESSO_DECODER 0
#define CONFIG_SGA_DECODER 1
#define CONFIG_SGI_DECODER 1
#define CONFIG_SGIRLE_DECODER 1
#define CONFIG_SHEERVIDEO_DECODER 1
#define CONFIG_SIMBIOSIS_IMX_DECODER 1
#define CONFIG_SMACKER_DECODER 1
#define CONFIG_SMC_DECODER 1
#define CONFIG_SMVJPEG_DECODER 1
#define CONFIG_SNOW_DECODER 1
#define CONFIG_SP5X_DECODER 1
#define CONFIG_SPEEDHQ_DECODER 1
#define CONFIG_SPEEX_DECODER 1
#define CONFIG_SRGC_DECODER 0
#define CONFIG_SUNRAST_DECODER 1
#define CONFIG_SVQ1_DECODER 1
#define CONFIG_SVQ3_DECODER 1
#define CONFIG_TARGA_DECODER 1
#define CONFIG_TARGA_Y216_DECODER 1
#define CONFIG_TDSC_DECODER 0
#define CONFIG_THEORA_DECODER 1
#define CONFIG_THP_DECODER 1
#define CONFIG_TIERTEXSEQVIDEO_DECODER 1
#define CONFIG_TIFF_DECODER 1
#define CONFIG_TMV_DECODER 1
#define CONFIG_TRUEMOTION1_DECODER 1
#define CONFIG_TRUEMOTION2_DECODER 1
#define CONFIG_TRUEMOTION2RT_DECODER 1
#define CONFIG_TSCC_DECODER 0
#define CONFIG_TSCC2_DECODER 1
#define CONFIG_TXD_DECODER 1
#define CONFIG_ULTI_DECODER 1
#define CONFIG_UTVIDEO_DECODER 1
#define CONFIG_V210_DECODER 1
#define CONFIG_V210X_DECODER 1
#define CONFIG_V308_DECODER 1
#define CONFIG_V408_DECODER 1
#define CONFIG_V410_DECODER 1
#define CONFIG_VB_DECODER 1
#define CONFIG_VBN_DECODER 1
#define CONFIG_VBLE_DECODER 1
#define CONFIG_VC1_DECODER 1
#define CONFIG_VC1IMAGE_DECODER 1
#define CONFIG_VC1_MMAL_DECODER 0
#define CONFIG_VC1_QSV_DECODER 0
#define CONFIG_VC1_V4L2M2M_DECODER 0
#define CONFIG_VCR1_DECODER 1
#define CONFIG_VMDVIDEO_DECODER 1
#define CONFIG_VMIX_DECODER 1
#define CONFIG_VMNC_DECODER 1
#define CONFIG_VP3_DECODER 1
#define CONFIG_VP4_DECODER 1
#define CONFIG_VP5_DECODER 1
#define CONFIG_VP6_DECODER 1
#define CONFIG_VP6A_DECODER 1
#define CONFIG_VP6F_DECODER 1
#define CONFIG_VP7_DECODER 1
#define CONFIG_VP8_DECODER 1
#define CONFIG_VP8_RKMPP_DECODER 0
#define CONFIG_VP8_V4L2M2M_DECODER 0
#define CONFIG_VP9_DECODER 1
#define CONFIG_VP9_RKMPP_DECODER 0
#define CONFIG_VP9_V4L2M2M_DECODER 0
#define CONFIG_VQA_DECODER 1
#define CONFIG_VQC_DECODER 1
#define CONFIG_VVC_DECODER 1
#define CONFIG_WBMP_DECODER 1
#define CONFIG_WEBP_DECODER 1
#define CONFIG_WCMV_DECODER 0
#define CONFIG_WRAPPED_AVFRAME_DECODER 1
#define CONFIG_WMV1_DECODER 1
#define CONFIG_WMV2_DECODER 1
#define CONFIG_WMV3_DECODER 1
#define CONFIG_WMV3IMAGE_DECODER 1
#define CONFIG_WNV1_DECODER 1
#define CONFIG_XAN_WC3_DECODER 1
#define CONFIG_XAN_WC4_DECODER 1
#define CONFIG_XBM_DECODER 1
#define CONFIG_XFACE_DECODER 1
#define CONFIG_XL_DECODER 1
#define CONFIG_XPM_DECODER 1
#define CONFIG_XWD_DECODER 1
#define CONFIG_Y41P_DECODER 1
#define CONFIG_YLC_DECODER 1
#define CONFIG_YOP_DECODER 1
#define CONFIG_YUV4_DECODER 1
#define CONFIG_ZERO12V_DECODER 1
#define CONFIG_ZEROCODEC_DECODER 0
#define CONFIG_ZLIB_DECODER 0
#define CONFIG_ZMBV_DECODER 0
#define CONFIG_AAC_DECODER 1
#define CONFIG_AAC_FIXED_DECODER 1
#define CONFIG_AAC_LATM_DECODER 1
#define CONFIG_AC3_DECODER 1
#define CONFIG_AC3_FIXED_DECODER 1
#define CONFIG_ACELP_KELVIN_DECODER 1
#define CONFIG_AHX_DECODER 0
#define CONFIG_ALAC_DECODER 1
#define CONFIG_ALS_DECODER 1
#define CONFIG_AMRNB_DECODER 1
#define CONFIG_AMRWB_DECODER 1
#define CONFIG_APAC_DECODER 1
#define CONFIG_APE_DECODER 1
#define CONFIG_APTX_DECODER 1
#define CONFIG_APTX_HD_DECODER 1
#define CONFIG_ATRAC1_DECODER 1
#define CONFIG_ATRAC3_DECODER 1
#define CONFIG_ATRAC3AL_DECODER 1
#define CONFIG_ATRAC3P_DECODER 1
#define CONFIG_ATRAC3PAL_DECODER 1
#define CONFIG_ATRAC9_DECODER 1
#define CONFIG_BINKAUDIO_DCT_DECODER 1
#define CONFIG_BINKAUDIO_RDFT_DECODER 1
#define CONFIG_BMV_AUDIO_DECODER 1
#define CONFIG_BONK_DECODER 1
#define CONFIG_COOK_DECODER 1
#define CONFIG_DCA_DECODER 1
#define CONFIG_DFPWM_DECODER 1
#define CONFIG_DOLBY_E_DECODER 1
#define CONFIG_DSD_LSBF_DECODER 1
#define CONFIG_DSD_MSBF_DECODER 1
#define CONFIG_DSD_LSBF_PLANAR_DECODER 1
#define CONFIG_DSD_MSBF_PLANAR_DECODER 1
#define CONFIG_DSICINAUDIO_DECODER 1
#define CONFIG_DSS_SP_DECODER 1
#define CONFIG_DST_DECODER 1
#define CONFIG_EAC3_DECODER 1
#define CONFIG_EVRC_DECODER 1
#define CONFIG_FASTAUDIO_DECODER 1
#define CONFIG_FFWAVESYNTH_DECODER 1
#define CONFIG_FLAC_DECODER 1
#define CONFIG_FTR_DECODER 1
#define CONFIG_G723_1_DECODER 1
#define CONFIG_G728_DECODER 1
#define CONFIG_G729_DECODER 1
#define CONFIG_GSM_DECODER 1
#define CONFIG_GSM_MS_DECODER 1
#define CONFIG_HCA_DECODER 1
#define CONFIG_HCOM_DECODER 1
#define CONFIG_HDR_DECODER 1
#define CONFIG_IAC_DECODER 1
#define CONFIG_ILBC_DECODER 1
#define CONFIG_IMC_DECODER 1
#define CONFIG_INTERPLAY_ACM_DECODER 1
#define CONFIG_MACE3_DECODER 1
#define CONFIG_MACE6_DECODER 1
#define CONFIG_METASOUND_DECODER 1
#define CONFIG_MISC4_DECODER 1
#define CONFIG_MLP_DECODER 1
#define CONFIG_MP1_DECODER 1
#define CONFIG_MP1FLOAT_DECODER 1
#define CONFIG_MP2_DECODER 1
#define CONFIG_MP2FLOAT_DECODER 1
#define CONFIG_MP3FLOAT_DECODER 1
#define CONFIG_MP3_DECODER 1
#define CONFIG_MP3ADUFLOAT_DECODER 1
#define CONFIG_MP3ADU_DECODER 1
#define CONFIG_MP3ON4FLOAT_DECODER 1
#define CONFIG_MP3ON4_DECODER 1
#define CONFIG_MPC7_DECODER 1
#define CONFIG_MPC8_DECODER 1
#define CONFIG_MSNSIREN_DECODER 1
#define CONFIG_NELLYMOSER_DECODER 1
#define CONFIG_ON2AVC_DECODER 1
#define CONFIG_OPUS_DECODER 1
#define CONFIG_OSQ_DECODER 1
#define CONFIG_PAF_AUDIO_DECODER 1
#define CONFIG_QCELP_DECODER 1
#define CONFIG_QDM2_DECODER 1
#define CONFIG_QDMC_DECODER 1
#define CONFIG_QOA_DECODER 1
#define CONFIG_RA_144_DECODER 1
#define CONFIG_RA_288_DECODER 1
#define CONFIG_RALF_DECODER 1
#define CONFIG_SBC_DECODER 1
#define CONFIG_SHORTEN_DECODER 1
#define CONFIG_SIPR_DECODER 1
#define CONFIG_SIREN_DECODER 1
#define CONFIG_SMACKAUD_DECODER 1
#define CONFIG_SONIC_DECODER 1
#define CONFIG_TAK_DECODER 1
#define CONFIG_TRUEHD_DECODER 1
#define CONFIG_TRUESPEECH_DECODER 1
#define CONFIG_TTA_DECODER 1
#define CONFIG_TWINVQ_DECODER 1
#define CONFIG_VMDAUDIO_DECODER 1
#define CONFIG_VORBIS_DECODER 1
#define CONFIG_WAVARC_DECODER 1
#define CONFIG_WAVPACK_DECODER 1
#define CONFIG_WMALOSSLESS_DECODER 1
#define CONFIG_WMAPRO_DECODER 1
#define CONFIG_WMAV1_DECODER 1
#define CONFIG_WMAV2_DECODER 1
#define CONFIG_WMAVOICE_DECODER 1
#define CONFIG_WS_SND1_DECODER 1
#define CONFIG_XMA1_DECODER 1
#define CONFIG_XMA2_DECODER 1
#define CONFIG_PCM_ALAW_DECODER 1
#define CONFIG_PCM_BLURAY_DECODER 1
#define CONFIG_PCM_DVD_DECODER 1
#define CONFIG_PCM_F16LE_DECODER 1
#define CONFIG_PCM_F24LE_DECODER 1
#define CONFIG_PCM_F32BE_DECODER 1
#define CONFIG_PCM_F32LE_DECODER 1
#define CONFIG_PCM_F64BE_DECODER 1
#define CONFIG_PCM_F64LE_DECODER 1
#define CONFIG_PCM_LXF_DECODER 1
#define CONFIG_PCM_MULAW_DECODER 1
#define CONFIG_PCM_S8_DECODER 1
#define CONFIG_PCM_S8_PLANAR_DECODER 1
#define CONFIG_PCM_S16BE_DECODER 1
#define CONFIG_PCM_S16BE_PLANAR_DECODER 1
#define CONFIG_PCM_S16LE_DECODER 1
#define CONFIG_PCM_S16LE_PLANAR_DECODER 1
#define CONFIG_PCM_S24BE_DECODER 1
#define CONFIG_PCM_S24DAUD_DECODER 1
#define CONFIG_PCM_S24LE_DECODER 1
#define CONFIG_PCM_S24LE_PLANAR_DECODER 1
#define CONFIG_PCM_S32BE_DECODER 1
#define CONFIG_PCM_S32LE_DECODER 1
#define CONFIG_PCM_S32LE_PLANAR_DECODER 1
#define CONFIG_PCM_S64BE_DECODER 1
#define CONFIG_PCM_S64LE_DECODER 1
#define CONFIG_PCM_SGA_DECODER 1
#define CONFIG_PCM_U8_DECODER 1
#define CONFIG_PCM_U16BE_DECODER 1
#define CONFIG_PCM_U16LE_DECODER 1
#define CONFIG_PCM_U24BE_DECODER 1
#define CONFIG_PCM_U24LE_DECODER 1
#define CONFIG_PCM_U32BE_DECODER 1
#define CONFIG_PCM_U32LE_DECODER 1
#define CONFIG_PCM_VIDC_DECODER 1
#define CONFIG_CBD2_DPCM_DECODER 1
#define CONFIG_DERF_DPCM_DECODER 1
#define CONFIG_GREMLIN_DPCM_DECODER 1
#define CONFIG_INTERPLAY_DPCM_DECODER 1
#define CONFIG_ROQ_DPCM_DECODER 1
#define CONFIG_SDX2_DPCM_DECODER 1
#define CONFIG_SOL_DPCM_DECODER 1
#define CONFIG_XAN_DPCM_DECODER 1
#define CONFIG_WADY_DPCM_DECODER 1
#define CONFIG_ADPCM_4XM_DECODER 1
#define CONFIG_ADPCM_ADX_DECODER 1
#define CONFIG_ADPCM_AFC_DECODER 1
#define CONFIG_ADPCM_AGM_DECODER 1
#define CONFIG_ADPCM_AICA_DECODER 1
#define CONFIG_ADPCM_ARGO_DECODER 1
#define CONFIG_ADPCM_CIRCUS_DECODER 0
#define CONFIG_ADPCM_CT_DECODER 1
#define CONFIG_ADPCM_DTK_DECODER 1
#define CONFIG_ADPCM_EA_DECODER 1
#define CONFIG_ADPCM_EA_MAXIS_XA_DECODER 1
#define CONFIG_ADPCM_EA_R1_DECODER 1
#define CONFIG_ADPCM_EA_R2_DECODER 1
#define CONFIG_ADPCM_EA_R3_DECODER 1
#define CONFIG_ADPCM_EA_XAS_DECODER 1
#define CONFIG_ADPCM_G722_DECODER 1
#define CONFIG_ADPCM_G726_DECODER 1
#define CONFIG_ADPCM_G726LE_DECODER 1
#define CONFIG_ADPCM_IMA_ACORN_DECODER 1
#define CONFIG_ADPCM_IMA_AMV_DECODER 1
#define CONFIG_ADPCM_IMA_ALP_DECODER 1
#define CONFIG_ADPCM_IMA_APC_DECODER 1
#define CONFIG_ADPCM_IMA_APM_DECODER 1
#define CONFIG_ADPCM_IMA_CUNNING_DECODER 1
#define CONFIG_ADPCM_IMA_DAT4_DECODER 1
#define CONFIG_ADPCM_IMA_DK3_DECODER 1
#define CONFIG_ADPCM_IMA_DK4_DECODER 1
#define CONFIG_ADPCM_IMA_EA_EACS_DECODER 1
#define CONFIG_ADPCM_IMA_EA_SEAD_DECODER 1
#define CONFIG_ADPCM_IMA_ESCAPE_DECODER 0
#define CONFIG_ADPCM_IMA_HVQM2_DECODER 0
#define CONFIG_ADPCM_IMA_HVQM4_DECODER 0
#define CONFIG_ADPCM_IMA_ISS_DECODER 1
#define CONFIG_ADPCM_IMA_MAGIX_DECODER 0
#define CONFIG_ADPCM_IMA_MOFLEX_DECODER 1
#define CONFIG_ADPCM_IMA_MTF_DECODER 1
#define CONFIG_ADPCM_IMA_OKI_DECODER 1
#define CONFIG_ADPCM_IMA_PDA_DECODER 0
#define CONFIG_ADPCM_IMA_QT_DECODER 1
#define CONFIG_ADPCM_IMA_RAD_DECODER 1
#define CONFIG_ADPCM_IMA_SSI_DECODER 1
#define CONFIG_ADPCM_IMA_SMJPEG_DECODER 1
#define CONFIG_ADPCM_IMA_WAV_DECODER 1
#define CONFIG_ADPCM_IMA_WS_DECODER 1
#define CONFIG_ADPCM_IMA_XBOX_DECODER 1
#define CONFIG_ADPCM_MS_DECODER 1
#define CONFIG_ADPCM_MTAF_DECODER 1
#define CONFIG_ADPCM_N64_DECODER 0
#define CONFIG_ADPCM_PSX_DECODER 1
#define CONFIG_ADPCM_PSXC_DECODER 0
#define CONFIG_ADPCM_SANYO_DECODER 1
#define CONFIG_ADPCM_SBPRO_2_DECODER 1
#define CONFIG_ADPCM_SBPRO_3_DECODER 1
#define CONFIG_ADPCM_SBPRO_4_DECODER 1
#define CONFIG_ADPCM_SWF_DECODER 1
#define CONFIG_ADPCM_THP_DECODER 1
#define CONFIG_ADPCM_THP_LE_DECODER 1
#define CONFIG_ADPCM_VIMA_DECODER 1
#define CONFIG_ADPCM_XA_DECODER 1
#define CONFIG_ADPCM_XMD_DECODER 1
#define CONFIG_ADPCM_YAMAHA_DECODER 1
#define CONFIG_ADPCM_ZORK_DECODER 1
#define CONFIG_SSA_DECODER 1
#define CONFIG_ASS_DECODER 1
#define CONFIG_CCAPTION_DECODER 1
#define CONFIG_DVBSUB_DECODER 1
#define CONFIG_DVDSUB_DECODER 1
#define CONFIG_JACOSUB_DECODER 1
#define CONFIG_MICRODVD_DECODER 1
#define CONFIG_MOVTEXT_DECODER 1
#define CONFIG_MPL2_DECODER 1
#define CONFIG_PGSSUB_DECODER 1
#define CONFIG_PJS_DECODER 1
#define CONFIG_REALTEXT_DECODER 1
#define CONFIG_SAMI_DECODER 1
#define CONFIG_SRT_DECODER 1
#define CONFIG_STL_DECODER 1
#define CONFIG_SUBRIP_DECODER 1
#define CONFIG_SUBVIEWER_DECODER 1
#define CONFIG_SUBVIEWER1_DECODER 1
#define CONFIG_TEXT_DECODER 1
#define CONFIG_VPLAYER_DECODER 1
#define CONFIG_WEBVTT_DECODER 1
#define CONFIG_XSUB_DECODER 1
#define CONFIG_AAC_AT_DECODER 0
#define CONFIG_AC3_AT_DECODER 0
#define CONFIG_ADPCM_IMA_QT_AT_DECODER 0
#define CONFIG_ALAC_AT_DECODER 0
#define CONFIG_AMR_NB_AT_DECODER 0
#define CONFIG_EAC3_AT_DECODER 0
#define CONFIG_GSM_MS_AT_DECODER 0
#define CONFIG_ILBC_AT_DECODER 0
#define CONFIG_MP1_AT_DECODER 0
#define CONFIG_MP2_AT_DECODER 0
#define CONFIG_MP3_AT_DECODER 0
#define CONFIG_PCM_ALAW_AT_DECODER 0
#define CONFIG_PCM_MULAW_AT_DECODER 0
#define CONFIG_QDMC_AT_DECODER 0
#define CONFIG_QDM2_AT_DECODER 0
#define CONFIG_LIBARIBCAPTION_DECODER 0
#define CONFIG_LIBARIBB24_DECODER 0
#define CONFIG_LIBCELT_DECODER 0
#define CONFIG_LIBCODEC2_DECODER 0
#define CONFIG_LIBDAV1D_DECODER 0
#define CONFIG_LIBDAVS2_DECODER 0
#define CONFIG_LIBFDK_AAC_DECODER 0
#define CONFIG_LIBGSM_DECODER 0
#define CONFIG_LIBGSM_MS_DECODER 0
#define CONFIG_LIBILBC_DECODER 0
#define CONFIG_LIBJXL_ANIM_DECODER 0
#define CONFIG_LIBJXL_DECODER 0
#define CONFIG_LIBLC3_DECODER 0
#define CONFIG_LIBMPEGHDEC_DECODER 0
#define CONFIG_LIBOPENCORE_AMRNB_DECODER 0
#define CONFIG_LIBOPENCORE_AMRWB_DECODER 0
#define CONFIG_LIBOPUS_DECODER 0
#define CONFIG_LIBRSVG_DECODER 0
#define CONFIG_LIBSPEEX_DECODER 0
#define CONFIG_LIBSVTJPEGXS_DECODER 0
#define CONFIG_LIBUAVS3D_DECODER 0
#define CONFIG_LIBVORBIS_DECODER 0
#define CONFIG_LIBVPX_VP8_DECODER 0
#define CONFIG_LIBVPX_VP9_DECODER 0
#define CONFIG_LIBXEVD_DECODER 0
#define CONFIG_LIBZVBI_TELETEXT_DECODER 0
#define CONFIG_BINTEXT_DECODER 1
#define CONFIG_XBIN_DECODER 1
#define CONFIG_IDF_DECODER 1
#define CONFIG_AAC_MEDIACODEC_DECODER 0
#define CONFIG_AMRNB_MEDIACODEC_DECODER 0
#define CONFIG_AMRWB_MEDIACODEC_DECODER 0
#define CONFIG_LIBAOM_AV1_DECODER 0
#define CONFIG_AV1_DECODER 1
#define CONFIG_AV1_CUVID_DECODER 0
#define CONFIG_AV1_MEDIACODEC_DECODER 0
#define CONFIG_AV1_QSV_DECODER 0
#define CONFIG_AV1_AMF_DECODER 0
#define CONFIG_LIBOPENH264_DECODER 0
#define CONFIG_H264_AMF_DECODER 0
#define CONFIG_H264_CUVID_DECODER 0
#define CONFIG_H264_OH_DECODER 0
#define CONFIG_HEVC_AMF_DECODER 0
#define CONFIG_HEVC_CUVID_DECODER 0
#define CONFIG_HEVC_MEDIACODEC_DECODER 0
#define CONFIG_HEVC_OH_DECODER 0
#define CONFIG_MJPEG_CUVID_DECODER 0
#define CONFIG_MJPEG_QSV_DECODER 0
#define CONFIG_MP3_MEDIACODEC_DECODER 0
#define CONFIG_MPEG1_CUVID_DECODER 0
#define CONFIG_MPEG2_CUVID_DECODER 0
#define CONFIG_MPEG4_CUVID_DECODER 0
#define CONFIG_MPEG4_MEDIACODEC_DECODER 0
#define CONFIG_VC1_CUVID_DECODER 0
#define CONFIG_VP8_CUVID_DECODER 0
#define CONFIG_VP8_MEDIACODEC_DECODER 0
#define CONFIG_VP8_QSV_DECODER 0
#define CONFIG_VP9_AMF_DECODER 0
#define CONFIG_VP9_CUVID_DECODER 0
#define CONFIG_VP9_MEDIACODEC_DECODER 0
#define CONFIG_VP9_QSV_DECODER 0
#define CONFIG_VVC_QSV_DECODER 0
#define CONFIG_VNULL_DECODER 1
#define CONFIG_ANULL_DECODER 1
#define CONFIG_A64MULTI_ENCODER 1
#define CONFIG_A64MULTI5_ENCODER 1
#define CONFIG_ALIAS_PIX_ENCODER 1
#define CONFIG_AMV_ENCODER 1
#define CONFIG_APNG_ENCODER 0
#define CONFIG_ASV1_ENCODER 1
#define CONFIG_ASV2_ENCODER 1
#define CONFIG_AVRP_ENCODER 1
#define CONFIG_AVUI_ENCODER 1
#define CONFIG_BITPACKED_ENCODER 1
#define CONFIG_BMP_ENCODER 1
#define CONFIG_CFHD_ENCODER 1
#define CONFIG_CINEPAK_ENCODER 1
#define CONFIG_CLJR_ENCODER 1
#define CONFIG_COMFORTNOISE_ENCODER 1
#define CONFIG_DNXHD_ENCODER 1
#define CONFIG_DPX_ENCODER 1
#define CONFIG_DVVIDEO_ENCODER 1
#define CONFIG_DXV_ENCODER 1
#define CONFIG_EXR_ENCODER 0
#define CONFIG_FFV1_ENCODER 1
#define CONFIG_FFV1_VULKAN_ENCODER 0
#define CONFIG_FFVHUFF_ENCODER 1
#define CONFIG_FITS_ENCODER 1
#define CONFIG_FLASHSV_ENCODER 0
#define CONFIG_FLASHSV2_ENCODER 0
#define CONFIG_FLV_ENCODER 1
#define CONFIG_GIF_ENCODER 1
#define CONFIG_H261_ENCODER 1
#define CONFIG_H263_ENCODER 1
#define CONFIG_H263P_ENCODER 1
#define CONFIG_H264_MEDIACODEC_ENCODER 0
#define CONFIG_H264_RKMPP_ENCODER 0
#define CONFIG_HAP_ENCODER 0
#define CONFIG_HEVC_RKMPP_ENCODER 0
#define CONFIG_HUFFYUV_ENCODER 1
#define CONFIG_JPEG2000_ENCODER 1
#define CONFIG_JPEGLS_ENCODER 1
#define CONFIG_LJPEG_ENCODER 1
#define CONFIG_MAGICYUV_ENCODER 1
#define CONFIG_MJPEG_ENCODER 1
#define CONFIG_MPEG1VIDEO_ENCODER 1
#define CONFIG_MPEG2VIDEO_ENCODER 1
#define CONFIG_MPEG4_ENCODER 1
#define CONFIG_MSMPEG4V2_ENCODER 1
#define CONFIG_MSMPEG4V3_ENCODER 1
#define CONFIG_MSRLE_ENCODER 1
#define CONFIG_MSVIDEO1_ENCODER 1
#define CONFIG_PAM_ENCODER 1
#define CONFIG_PBM_ENCODER 1
#define CONFIG_PCX_ENCODER 1
#define CONFIG_PFM_ENCODER 1
#define CONFIG_PGM_ENCODER 1
#define CONFIG_PGMYUV_ENCODER 1
#define CONFIG_PHM_ENCODER 1
#define CONFIG_PNG_ENCODER 0
#define CONFIG_PPM_ENCODER 1
#define CONFIG_PRORES_ENCODER 1
#define CONFIG_PRORES_AW_ENCODER 1
#define CONFIG_PRORES_KS_ENCODER 1
#define CONFIG_PRORES_KS_VULKAN_ENCODER 0
#define CONFIG_QOI_ENCODER 1
#define CONFIG_QTRLE_ENCODER 1
#define CONFIG_R10K_ENCODER 1
#define CONFIG_R210_ENCODER 1
#define CONFIG_RAWVIDEO_ENCODER 1
#define CONFIG_ROQ_ENCODER 1
#define CONFIG_RPZA_ENCODER 1
#define CONFIG_RV10_ENCODER 1
#define CONFIG_RV20_ENCODER 1
#define CONFIG_S302M_ENCODER 1
#define CONFIG_SGI_ENCODER 1
#define CONFIG_SMC_ENCODER 1
#define CONFIG_SNOW_ENCODER 1
#define CONFIG_SPEEDHQ_ENCODER 1
#define CONFIG_SUNRAST_ENCODER 1
#define CONFIG_SVQ1_ENCODER 1
#define CONFIG_TARGA_ENCODER 1
#define CONFIG_TIFF_ENCODER 1
#define CONFIG_UTVIDEO_ENCODER 1
#define CONFIG_V210_ENCODER 1
#define CONFIG_V308_ENCODER 1
#define CONFIG_V408_ENCODER 1
#define CONFIG_V410_ENCODER 1
#define CONFIG_VBN_ENCODER 1
#define CONFIG_VC2_ENCODER 1
#define CONFIG_WBMP_ENCODER 1
#define CONFIG_WRAPPED_AVFRAME_ENCODER 1
#define CONFIG_WMV1_ENCODER 1
#define CONFIG_WMV2_ENCODER 1
#define CONFIG_XBM_ENCODER 1
#define CONFIG_XFACE_ENCODER 1
#define CONFIG_XWD_ENCODER 1
#define CONFIG_Y41P_ENCODER 1
#define CONFIG_YUV4_ENCODER 1
#define CONFIG_ZLIB_ENCODER 0
#define CONFIG_ZMBV_ENCODER 0
#define CONFIG_AAC_ENCODER 1
#define CONFIG_AC3_ENCODER 1
#define CONFIG_AC3_FIXED_ENCODER 1
#define CONFIG_ALAC_ENCODER 1
#define CONFIG_APTX_ENCODER 1
#define CONFIG_APTX_HD_ENCODER 1
#define CONFIG_DCA_ENCODER 1
#define CONFIG_DFPWM_ENCODER 1
#define CONFIG_EAC3_ENCODER 1
#define CONFIG_FLAC_ENCODER 1
#define CONFIG_G723_1_ENCODER 1
#define CONFIG_HDR_ENCODER 1
#define CONFIG_MLP_ENCODER 1
#define CONFIG_MP2_ENCODER 1
#define CONFIG_MP2FIXED_ENCODER 1
#define CONFIG_NELLYMOSER_ENCODER 1
#define CONFIG_OPUS_ENCODER 1
#define CONFIG_RA_144_ENCODER 1
#define CONFIG_SBC_ENCODER 1
#define CONFIG_SONIC_ENCODER 0
#define CONFIG_SONIC_LS_ENCODER 0
#define CONFIG_TRUEHD_ENCODER 1
#define CONFIG_TTA_ENCODER 1
#define CONFIG_VORBIS_ENCODER 1
#define CONFIG_WAVPACK_ENCODER 1
#define CONFIG_WMAV1_ENCODER 1
#define CONFIG_WMAV2_ENCODER 1
#define CONFIG_PCM_ALAW_ENCODER 1
#define CONFIG_PCM_BLURAY_ENCODER 1
#define CONFIG_PCM_DVD_ENCODER 1
#define CONFIG_PCM_F32BE_ENCODER 1
#define CONFIG_PCM_F32LE_ENCODER 1
#define CONFIG_PCM_F64BE_ENCODER 1
#define CONFIG_PCM_F64LE_ENCODER 1
#define CONFIG_PCM_MULAW_ENCODER 1
#define CONFIG_PCM_S8_ENCODER 1
#define CONFIG_PCM_S8_PLANAR_ENCODER 1
#define CONFIG_PCM_S16BE_ENCODER 1
#define CONFIG_PCM_S16BE_PLANAR_ENCODER 1
#define CONFIG_PCM_S16LE_ENCODER 1
#define CONFIG_PCM_S16LE_PLANAR_ENCODER 1
#define CONFIG_PCM_S24BE_ENCODER 1
#define CONFIG_PCM_S24DAUD_ENCODER 1
#define CONFIG_PCM_S24LE_ENCODER 1
#define CONFIG_PCM_S24LE_PLANAR_ENCODER 1
#define CONFIG_PCM_S32BE_ENCODER 1
#define CONFIG_PCM_S32LE_ENCODER 1
#define CONFIG_PCM_S32LE_PLANAR_ENCODER 1
#define CONFIG_PCM_S64BE_ENCODER 1
#define CONFIG_PCM_S64LE_ENCODER 1
#define CONFIG_PCM_U8_ENCODER 1
#define CONFIG_PCM_U16BE_ENCODER 1
#define CONFIG_PCM_U16LE_ENCODER 1
#define CONFIG_PCM_U24BE_ENCODER 1
#define CONFIG_PCM_U24LE_ENCODER 1
#define CONFIG_PCM_U32BE_ENCODER 1
#define CONFIG_PCM_U32LE_ENCODER 1
#define CONFIG_PCM_VIDC_ENCODER 1
#define CONFIG_ROQ_DPCM_ENCODER 1
#define CONFIG_ADPCM_ADX_ENCODER 1
#define CONFIG_ADPCM_ARGO_ENCODER 1
#define CONFIG_ADPCM_G722_ENCODER 1
#define CONFIG_ADPCM_G726_ENCODER 1
#define CONFIG_ADPCM_G726LE_ENCODER 1
#define CONFIG_ADPCM_IMA_AMV_ENCODER 1
#define CONFIG_ADPCM_IMA_ALP_ENCODER 1
#define CONFIG_ADPCM_IMA_APM_ENCODER 1
#define CONFIG_ADPCM_IMA_QT_ENCODER 1
#define CONFIG_ADPCM_IMA_SSI_ENCODER 1
#define CONFIG_ADPCM_IMA_WAV_ENCODER 1
#define CONFIG_ADPCM_IMA_WS_ENCODER 1
#define CONFIG_ADPCM_MS_ENCODER 1
#define CONFIG_ADPCM_SWF_ENCODER 1
#define CONFIG_ADPCM_YAMAHA_ENCODER 1
#define CONFIG_SSA_ENCODER 1
#define CONFIG_ASS_ENCODER 1
#define CONFIG_DVBSUB_ENCODER 1
#define CONFIG_DVDSUB_ENCODER 1
#define CONFIG_MOVTEXT_ENCODER 1
#define CONFIG_SRT_ENCODER 1
#define CONFIG_SUBRIP_ENCODER 1
#define CONFIG_TEXT_ENCODER 1
#define CONFIG_TTML_ENCODER 1
#define CONFIG_WEBVTT_ENCODER 1
#define CONFIG_XSUB_ENCODER 1
#define CONFIG_AAC_AT_ENCODER 0
#define CONFIG_ALAC_AT_ENCODER 0
#define CONFIG_ILBC_AT_ENCODER 0
#define CONFIG_PCM_ALAW_AT_ENCODER 0
#define CONFIG_PCM_MULAW_AT_ENCODER 0
#define CONFIG_LIBAOM_AV1_ENCODER 0
#define CONFIG_LIBCODEC2_ENCODER 0
#define CONFIG_LIBFDK_AAC_ENCODER 0
#define CONFIG_LIBGSM_ENCODER 0
#define CONFIG_LIBGSM_MS_ENCODER 0
#define CONFIG_LIBILBC_ENCODER 0
#define CONFIG_LIBJXL_ANIM_ENCODER 0
#define CONFIG_LIBJXL_ENCODER 0
#define CONFIG_LIBLC3_ENCODER 0
#define CONFIG_LIBMP3LAME_ENCODER 0
#define CONFIG_LIBOAPV_ENCODER 0
#define CONFIG_LIBOPENCORE_AMRNB_ENCODER 0
#define CONFIG_LIBOPENJPEG_ENCODER 0
#define CONFIG_LIBOPUS_ENCODER 0
#define CONFIG_LIBRAV1E_ENCODER 0
#define CONFIG_LIBSHINE_ENCODER 0
#define CONFIG_LIBSPEEX_ENCODER 0
#define CONFIG_LIBSVTAV1_ENCODER 0
#define CONFIG_LIBSVTJPEGXS_ENCODER 0
#define CONFIG_LIBTHEORA_ENCODER 0
#define CONFIG_LIBTWOLAME_ENCODER 0
#define CONFIG_LIBVO_AMRWBENC_ENCODER 0
#define CONFIG_LIBVORBIS_ENCODER 0
#define CONFIG_LIBVPX_VP8_ENCODER 0
#define CONFIG_LIBVPX_VP9_ENCODER 0
#define CONFIG_LIBVVENC_ENCODER 0
#define CONFIG_LIBWEBP_ANIM_ENCODER 0
#define CONFIG_LIBWEBP_ENCODER 0
#define CONFIG_LIBX262_ENCODER 0
#define CONFIG_LIBX264_ENCODER 0
#define CONFIG_LIBX264RGB_ENCODER 0
#define CONFIG_LIBX265_ENCODER 0
#define CONFIG_LIBXEVE_ENCODER 0
#define CONFIG_LIBXAVS_ENCODER 0
#define CONFIG_LIBXAVS2_ENCODER 0
#define CONFIG_LIBXVID_ENCODER 0
#define CONFIG_AAC_MF_ENCODER 0
#define CONFIG_AC3_MF_ENCODER 0
#define CONFIG_H263_V4L2M2M_ENCODER 0
#define CONFIG_AV1_D3D12VA_ENCODER 0
#define CONFIG_AV1_MEDIACODEC_ENCODER 0
#define CONFIG_AV1_NVENC_ENCODER 0
#define CONFIG_AV1_QSV_ENCODER 0
#define CONFIG_AV1_AMF_ENCODER 0
#define CONFIG_AV1_MF_ENCODER 0
#define CONFIG_AV1_VAAPI_ENCODER 0
#define CONFIG_AV1_VULKAN_ENCODER 0
#define CONFIG_LIBOPENH264_ENCODER 0
#define CONFIG_H264_AMF_ENCODER 0
#define CONFIG_H264_D3D12VA_ENCODER 0
#define CONFIG_H264_MF_ENCODER 0
#define CONFIG_H264_NVENC_ENCODER 0
#define CONFIG_H264_OH_ENCODER 0
#define CONFIG_H264_OMX_ENCODER 0
#define CONFIG_H264_QSV_ENCODER 0
#define CONFIG_H264_V4L2M2M_ENCODER 0
#define CONFIG_H264_VAAPI_ENCODER 0
#define CONFIG_H264_VIDEOTOOLBOX_ENCODER 0
#define CONFIG_H264_VULKAN_ENCODER 0
#define CONFIG_HEVC_AMF_ENCODER 0
#define CONFIG_HEVC_D3D12VA_ENCODER 0
#define CONFIG_HEVC_MEDIACODEC_ENCODER 0
#define CONFIG_HEVC_MF_ENCODER 0
#define CONFIG_HEVC_NVENC_ENCODER 0
#define CONFIG_HEVC_OH_ENCODER 0
#define CONFIG_HEVC_QSV_ENCODER 0
#define CONFIG_HEVC_V4L2M2M_ENCODER 0
#define CONFIG_HEVC_VAAPI_ENCODER 0
#define CONFIG_HEVC_VIDEOTOOLBOX_ENCODER 0
#define CONFIG_HEVC_VULKAN_ENCODER 0
#define CONFIG_LIBKVAZAAR_ENCODER 0
#define CONFIG_MJPEG_QSV_ENCODER 0
#define CONFIG_MJPEG_VAAPI_ENCODER 0
#define CONFIG_MP3_MF_ENCODER 0
#define CONFIG_MPEG2_QSV_ENCODER 0
#define CONFIG_MPEG2_VAAPI_ENCODER 0
#define CONFIG_MPEG4_MEDIACODEC_ENCODER 0
#define CONFIG_MPEG4_OMX_ENCODER 0
#define CONFIG_MPEG4_V4L2M2M_ENCODER 0
#define CONFIG_PRORES_VIDEOTOOLBOX_ENCODER 0
#define CONFIG_VP8_MEDIACODEC_ENCODER 0
#define CONFIG_VP8_V4L2M2M_ENCODER 0
#define CONFIG_VP8_VAAPI_ENCODER 0
#define CONFIG_VP9_MEDIACODEC_ENCODER 0
#define CONFIG_VP9_VAAPI_ENCODER 0
#define CONFIG_VP9_QSV_ENCODER 0
#define CONFIG_VNULL_ENCODER 1
#define CONFIG_ANULL_ENCODER 1
#define CONFIG_AV1_D3D11VA_HWACCEL 0
#define CONFIG_AV1_D3D11VA2_HWACCEL 0
#define CONFIG_AV1_D3D12VA_HWACCEL 0
#define CONFIG_AV1_DXVA2_HWACCEL 0
#define CONFIG_AV1_NVDEC_HWACCEL 0
#define CONFIG_AV1_VAAPI_HWACCEL 0
#define CONFIG_AV1_VDPAU_HWACCEL 0
#define CONFIG_AV1_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_AV1_VULKAN_HWACCEL 0
#define CONFIG_DPX_VULKAN_HWACCEL 0
#define CONFIG_FFV1_VULKAN_HWACCEL 0
#define CONFIG_H263_VAAPI_HWACCEL 0
#define CONFIG_H263_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_H264_D3D11VA_HWACCEL 0
#define CONFIG_H264_D3D11VA2_HWACCEL 0
#define CONFIG_H264_D3D12VA_HWACCEL 0
#define CONFIG_H264_DXVA2_HWACCEL 0
#define CONFIG_H264_NVDEC_HWACCEL 0
#define CONFIG_H264_VAAPI_HWACCEL 0
#define CONFIG_H264_VDPAU_HWACCEL 0
#define CONFIG_H264_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_H264_VULKAN_HWACCEL 0
#define CONFIG_HEVC_D3D11VA_HWACCEL 0
#define CONFIG_HEVC_D3D11VA2_HWACCEL 0
#define CONFIG_HEVC_D3D12VA_HWACCEL 0
#define CONFIG_HEVC_DXVA2_HWACCEL 0
#define CONFIG_HEVC_NVDEC_HWACCEL 0
#define CONFIG_HEVC_VAAPI_HWACCEL 0
#define CONFIG_HEVC_VDPAU_HWACCEL 0
#define CONFIG_HEVC_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_HEVC_VULKAN_HWACCEL 0
#define CONFIG_MJPEG_NVDEC_HWACCEL 0
#define CONFIG_MJPEG_VAAPI_HWACCEL 0
#define CONFIG_MPEG1_NVDEC_HWACCEL 0
#define CONFIG_MPEG1_VDPAU_HWACCEL 0
#define CONFIG_MPEG1_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_MPEG2_D3D11VA_HWACCEL 0
#define CONFIG_MPEG2_D3D11VA2_HWACCEL 0
#define CONFIG_MPEG2_D3D12VA_HWACCEL 0
#define CONFIG_MPEG2_DXVA2_HWACCEL 0
#define CONFIG_MPEG2_NVDEC_HWACCEL 0
#define CONFIG_MPEG2_VAAPI_HWACCEL 0
#define CONFIG_MPEG2_VDPAU_HWACCEL 0
#define CONFIG_MPEG2_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_MPEG4_NVDEC_HWACCEL 0
#define CONFIG_MPEG4_VAAPI_HWACCEL 0
#define CONFIG_MPEG4_VDPAU_HWACCEL 0
#define CONFIG_MPEG4_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_PRORES_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_PRORES_VULKAN_HWACCEL 0
#define CONFIG_PRORES_RAW_VULKAN_HWACCEL 0
#define CONFIG_VC1_D3D11VA_HWACCEL 0
#define CONFIG_VC1_D3D11VA2_HWACCEL 0
#define CONFIG_VC1_D3D12VA_HWACCEL 0
#define CONFIG_VC1_DXVA2_HWACCEL 0
#define CONFIG_VC1_NVDEC_HWACCEL 0
#define CONFIG_VC1_VAAPI_HWACCEL 0
#define CONFIG_VC1_VDPAU_HWACCEL 0
#define CONFIG_VP8_NVDEC_HWACCEL 0
#define CONFIG_VP8_VAAPI_HWACCEL 0
#define CONFIG_VP9_D3D11VA_HWACCEL 0
#define CONFIG_VP9_D3D11VA2_HWACCEL 0
#define CONFIG_VP9_D3D12VA_HWACCEL 0
#define CONFIG_VP9_DXVA2_HWACCEL 0
#define CONFIG_VP9_NVDEC_HWACCEL 0
#define CONFIG_VP9_VAAPI_HWACCEL 0
#define CONFIG_VP9_VDPAU_HWACCEL 0
#define CONFIG_VP9_VIDEOTOOLBOX_HWACCEL 0
#define CONFIG_VP9_VULKAN_HWACCEL 0
#define CONFIG_VVC_VAAPI_HWACCEL 0
#define CONFIG_WMV3_D3D11VA_HWACCEL 0
#define CONFIG_WMV3_D3D11VA2_HWACCEL 0
#define CONFIG_WMV3_D3D12VA_HWACCEL 0
#define CONFIG_WMV3_DXVA2_HWACCEL 0
#define CONFIG_WMV3_NVDEC_HWACCEL 0
#define CONFIG_WMV3_VAAPI_HWACCEL 0
#define CONFIG_WMV3_VDPAU_HWACCEL 0
#define CONFIG_AAC_PARSER 1
#define CONFIG_AAC_LATM_PARSER 1
#define CONFIG_AC3_PARSER 1
#define CONFIG_ADX_PARSER 1
#define CONFIG_AHX_PARSER 0
#define CONFIG_AMR_PARSER 1
#define CONFIG_APV_PARSER 1
#define CONFIG_AV1_PARSER 1
#define CONFIG_AVS2_PARSER 1
#define CONFIG_AVS3_PARSER 1
#define CONFIG_BMP_PARSER 1
#define CONFIG_CAVSVIDEO_PARSER 1
#define CONFIG_COOK_PARSER 1
#define CONFIG_CRI_PARSER 1
#define CONFIG_DCA_PARSER 1
#define CONFIG_DIRAC_PARSER 1
#define CONFIG_DNXHD_PARSER 1
#define CONFIG_DNXUC_PARSER 1
#define CONFIG_DOLBY_E_PARSER 1
#define CONFIG_DPX_PARSER 1
#define CONFIG_DVAUDIO_PARSER 1
#define CONFIG_DVBSUB_PARSER 1
#define CONFIG_DVDSUB_PARSER 1
#define CONFIG_DVD_NAV_PARSER 1
#define CONFIG_EVC_PARSER 1
#define CONFIG_FLAC_PARSER 1
#define CONFIG_FTR_PARSER 1
#define CONFIG_FFV1_PARSER 1
#define CONFIG_G723_1_PARSER 1
#define CONFIG_G729_PARSER 1
#define CONFIG_GIF_PARSER 1
#define CONFIG_GSM_PARSER 1
#define CONFIG_H261_PARSER 1
#define CONFIG_H263_PARSER 1
#define CONFIG_H264_PARSER 1
#define CONFIG_HEVC_PARSER 1
#define CONFIG_HDR_PARSER 1
#define CONFIG_IPU_PARSER 1
#define CONFIG_JPEG2000_PARSER 1
#define CONFIG_JPEGXL_PARSER 1
#define CONFIG_JPEGXS_PARSER 1
#define CONFIG_LCEVC_PARSER 1
#define CONFIG_MISC4_PARSER 1
#define CONFIG_MJPEG_PARSER 1
#define CONFIG_MLP_PARSER 1
#define CONFIG_MPEG4VIDEO_PARSER 1
#define CONFIG_MPEGAUDIO_PARSER 1
#define CONFIG_MPEGVIDEO_PARSER 1
#define CONFIG_OPUS_PARSER 1
#define CONFIG_PRORES_PARSER 1
#define CONFIG_PNG_PARSER 1
#define CONFIG_PNM_PARSER 1
#define CONFIG_PRORES_RAW_PARSER 1
#define CONFIG_QOI_PARSER 1
#define CONFIG_RV34_PARSER 1
#define CONFIG_SBC_PARSER 1
#define CONFIG_SIPR_PARSER 1
#define CONFIG_TAK_PARSER 1
#define CONFIG_VC1_PARSER 1
#define CONFIG_VORBIS_PARSER 1
#define CONFIG_VP3_PARSER 1
#define CONFIG_VP8_PARSER 1
#define CONFIG_VP9_PARSER 1
#define CONFIG_VVC_PARSER 1
#define CONFIG_WEBP_PARSER 1
#define CONFIG_XBM_PARSER 1
#define CONFIG_XMA_PARSER 1
#define CONFIG_XWD_PARSER 1
#define CONFIG_ALSA_INDEV 0
#define CONFIG_ANDROID_CAMERA_INDEV 0
#define CONFIG_AVFOUNDATION_INDEV 0
#define CONFIG_DECKLINK_INDEV 0
#define CONFIG_DSHOW_INDEV 1
#define CONFIG_FBDEV_INDEV 0
#define CONFIG_GDIGRAB_INDEV 1
#define CONFIG_IEC61883_INDEV 0
#define CONFIG_JACK_INDEV 0
#define CONFIG_KMSGRAB_INDEV 0
#define CONFIG_LAVFI_INDEV 1
#define CONFIG_OPENAL_INDEV 0
#define CONFIG_OSS_INDEV 0
#define CONFIG_PULSE_INDEV 0
#define CONFIG_SNDIO_INDEV 0
#define CONFIG_V4L2_INDEV 0
#define CONFIG_VFWCAP_INDEV 1
#define CONFIG_XCBGRAB_INDEV 0
#define CONFIG_LIBCDIO_INDEV 0
#define CONFIG_LIBDC1394_INDEV 0
#define CONFIG_ALSA_OUTDEV 0
#define CONFIG_AUDIOTOOLBOX_OUTDEV 0
#define CONFIG_CACA_OUTDEV 0
#define CONFIG_DECKLINK_OUTDEV 0
#define CONFIG_FBDEV_OUTDEV 0
#define CONFIG_OSS_OUTDEV 0
#define CONFIG_PULSE_OUTDEV 0
#define CONFIG_SNDIO_OUTDEV 0
#define CONFIG_V4L2_OUTDEV 0
#define CONFIG_XV_OUTDEV 0
#define CONFIG_AAP_FILTER 1
#define CONFIG_ABENCH_FILTER 1
#define CONFIG_ACOMPRESSOR_FILTER 1
#define CONFIG_ACONTRAST_FILTER 1
#define CONFIG_ACOPY_FILTER 1
#define CONFIG_ACUE_FILTER 1
#define CONFIG_ACROSSFADE_FILTER 1
#define CONFIG_ACROSSOVER_FILTER 1
#define CONFIG_ACRUSHER_FILTER 1
#define CONFIG_ADECLICK_FILTER 1
#define CONFIG_ADECLIP_FILTER 1
#define CONFIG_ADECORRELATE_FILTER 1
#define CONFIG_ADELAY_FILTER 1
#define CONFIG_ADENORM_FILTER 1
#define CONFIG_ADERIVATIVE_FILTER 1
#define CONFIG_ADRC_FILTER 1
#define CONFIG_ADYNAMICEQUALIZER_FILTER 1
#define CONFIG_ADYNAMICSMOOTH_FILTER 1
#define CONFIG_AECHO_FILTER 1
#define CONFIG_AEMPHASIS_FILTER 1
#define CONFIG_AEVAL_FILTER 1
#define CONFIG_AEXCITER_FILTER 1
#define CONFIG_AFADE_FILTER 1
#define CONFIG_AFFTDN_FILTER 1
#define CONFIG_AFFTFILT_FILTER 1
#define CONFIG_AFIR_FILTER 1
#define CONFIG_AFORMAT_FILTER 1
#define CONFIG_AFREQSHIFT_FILTER 1
#define CONFIG_AFWTDN_FILTER 1
#define CONFIG_AGATE_FILTER 1
#define CONFIG_AIIR_FILTER 1
#define CONFIG_AINTEGRAL_FILTER 1
#define CONFIG_AINTERLEAVE_FILTER 1
#define CONFIG_ALATENCY_FILTER 1
#define CONFIG_ALIMITER_FILTER 1
#define CONFIG_ALLPASS_FILTER 1
#define CONFIG_ALOOP_FILTER 1
#define CONFIG_AMERGE_FILTER 1
#define CONFIG_AMETADATA_FILTER 1
#define CONFIG_AMIX_FILTER 1
#define CONFIG_AMULTIPLY_FILTER 1
#define CONFIG_ANEQUALIZER_FILTER 1
#define CONFIG_ANLMDN_FILTER 1
#define CONFIG_ANLMF_FILTER 1
#define CONFIG_ANLMS_FILTER 1
#define CONFIG_ANULL_FILTER 1
#define CONFIG_APAD_FILTER 1
#define CONFIG_APERMS_FILTER 1
#define CONFIG_APHASER_FILTER 1
#define CONFIG_APHASESHIFT_FILTER 1
#define CONFIG_APSNR_FILTER 1
#define CONFIG_APSYCLIP_FILTER 1
#define CONFIG_APULSATOR_FILTER 1
#define CONFIG_AREALTIME_FILTER 1
#define CONFIG_ARESAMPLE_FILTER 1
#define CONFIG_AREVERSE_FILTER 1
#define CONFIG_ARLS_FILTER 1
#define CONFIG_ARNNDN_FILTER 1
#define CONFIG_ASDR_FILTER 1
#define CONFIG_ASEGMENT_FILTER 1
#define CONFIG_ASELECT_FILTER 1
#define CONFIG_ASENDCMD_FILTER 1
#define CONFIG_ASETNSAMPLES_FILTER 1
#define CONFIG_ASETPTS_FILTER 1
#define CONFIG_ASETRATE_FILTER 1
#define CONFIG_ASETTB_FILTER 1
#define CONFIG_ASHOWINFO_FILTER 1
#define CONFIG_ASIDEDATA_FILTER 1
#define CONFIG_ASISDR_FILTER 1
#define CONFIG_ASOFTCLIP_FILTER 1
#define CONFIG_ASPECTRALSTATS_FILTER 1
#define CONFIG_ASPLIT_FILTER 1
#define CONFIG_ASR_FILTER 0
#define CONFIG_ASTATS_FILTER 1
#define CONFIG_ASTREAMSELECT_FILTER 1
#define CONFIG_ASUBBOOST_FILTER 1
#define CONFIG_ASUBCUT_FILTER 1
#define CONFIG_ASUPERCUT_FILTER 1
#define CONFIG_ASUPERPASS_FILTER 1
#define CONFIG_ASUPERSTOP_FILTER 1
#define CONFIG_ATEMPO_FILTER 1
#define CONFIG_ATILT_FILTER 1
#define CONFIG_ATRIM_FILTER 1
#define CONFIG_AXCORRELATE_FILTER 1
#define CONFIG_AZMQ_FILTER 0
#define CONFIG_BANDPASS_FILTER 1
#define CONFIG_BANDREJECT_FILTER 1
#define CONFIG_BASS_FILTER 1
#define CONFIG_BIQUAD_FILTER 1
#define CONFIG_BS2B_FILTER 0
#define CONFIG_CHANNELMAP_FILTER 1
#define CONFIG_CHANNELSPLIT_FILTER 1
#define CONFIG_CHORUS_FILTER 1
#define CONFIG_COMPAND_FILTER 1
#define CONFIG_COMPENSATIONDELAY_FILTER 1
#define CONFIG_CROSSFEED_FILTER 1
#define CONFIG_CRYSTALIZER_FILTER 1
#define CONFIG_DCSHIFT_FILTER 1
#define CONFIG_DEESSER_FILTER 1
#define CONFIG_DIALOGUENHANCE_FILTER 1
#define CONFIG_DRMETER_FILTER 1
#define CONFIG_DYNAUDNORM_FILTER 1
#define CONFIG_EARWAX_FILTER 1
#define CONFIG_EBUR128_FILTER 1
#define CONFIG_EQUALIZER_FILTER 1
#define CONFIG_EXTRASTEREO_FILTER 1
#define CONFIG_FIREQUALIZER_FILTER 1
#define CONFIG_FLANGER_FILTER 1
#define CONFIG_HAAS_FILTER 1
#define CONFIG_HDCD_FILTER 1
#define CONFIG_HEADPHONE_FILTER 1
#define CONFIG_HIGHPASS_FILTER 1
#define CONFIG_HIGHSHELF_FILTER 1
#define CONFIG_JOIN_FILTER 1
#define CONFIG_LADSPA_FILTER 0
#define CONFIG_LOUDNORM_FILTER 1
#define CONFIG_LOWPASS_FILTER 1
#define CONFIG_LOWSHELF_FILTER 1
#define CONFIG_LV2_FILTER 0
#define CONFIG_MCOMPAND_FILTER 1
#define CONFIG_PAN_FILTER 1
#define CONFIG_REPLAYGAIN_FILTER 1
#define CONFIG_RUBBERBAND_FILTER 0
#define CONFIG_SIDECHAINCOMPRESS_FILTER 1
#define CONFIG_SIDECHAINGATE_FILTER 1
#define CONFIG_SILENCEDETECT_FILTER 1
#define CONFIG_SILENCEREMOVE_FILTER 1
#define CONFIG_SOFALIZER_FILTER 0
#define CONFIG_SPEECHNORM_FILTER 1
#define CONFIG_STEREOTOOLS_FILTER 1
#define CONFIG_STEREOWIDEN_FILTER 1
#define CONFIG_SUPEREQUALIZER_FILTER 1
#define CONFIG_SURROUND_FILTER 1
#define CONFIG_TILTSHELF_FILTER 1
#define CONFIG_TREBLE_FILTER 1
#define CONFIG_TREMOLO_FILTER 1
#define CONFIG_VIBRATO_FILTER 1
#define CONFIG_VIRTUALBASS_FILTER 1
#define CONFIG_VOLUME_FILTER 1
#define CONFIG_VOLUMEDETECT_FILTER 1
#define CONFIG_WHISPER_FILTER 0
#define CONFIG_AEVALSRC_FILTER 1
#define CONFIG_AFDELAYSRC_FILTER 1
#define CONFIG_AFIREQSRC_FILTER 1
#define CONFIG_AFIRSRC_FILTER 1
#define CONFIG_ANOISESRC_FILTER 1
#define CONFIG_ANULLSRC_FILTER 1
#define CONFIG_FLITE_FILTER 0
#define CONFIG_HILBERT_FILTER 1
#define CONFIG_SINC_FILTER 1
#define CONFIG_SINE_FILTER 1
#define CONFIG_ANULLSINK_FILTER 1
#define CONFIG_ADDROI_FILTER 1
#define CONFIG_ALPHAEXTRACT_FILTER 1
#define CONFIG_ALPHAMERGE_FILTER 1
#define CONFIG_AMPLIFY_FILTER 1
#define CONFIG_ASS_FILTER 0
#define CONFIG_ATADENOISE_FILTER 1
#define CONFIG_AVGBLUR_FILTER 1
#define CONFIG_AVGBLUR_OPENCL_FILTER 0
#define CONFIG_AVGBLUR_VULKAN_FILTER 0
#define CONFIG_BACKGROUNDKEY_FILTER 1
#define CONFIG_BBOX_FILTER 1
#define CONFIG_BENCH_FILTER 1
#define CONFIG_BILATERAL_FILTER 1
#define CONFIG_BILATERAL_CUDA_FILTER 0
#define CONFIG_BITPLANENOISE_FILTER 1
#define CONFIG_BLACKDETECT_FILTER 1
#define CONFIG_BLACKDETECT_VULKAN_FILTER 0
#define CONFIG_BLACKFRAME_FILTER 0
#define CONFIG_BLEND_FILTER 1
#define CONFIG_BLEND_VULKAN_FILTER 0
#define CONFIG_BLOCKDETECT_FILTER 1
#define CONFIG_BLURDETECT_FILTER 1
#define CONFIG_BM3D_FILTER 1
#define CONFIG_BOXBLUR_FILTER 0
#define CONFIG_BOXBLUR_OPENCL_FILTER 0
#define CONFIG_BWDIF_FILTER 1
#define CONFIG_BWDIF_CUDA_FILTER 0
#define CONFIG_BWDIF_VULKAN_FILTER 0
#define CONFIG_CAS_FILTER 1
#define CONFIG_CCREPACK_FILTER 1
#define CONFIG_CHROMABER_VULKAN_FILTER 0
#define CONFIG_CHROMAHOLD_FILTER 1
#define CONFIG_CHROMAKEY_FILTER 1
#define CONFIG_CHROMAKEY_CUDA_FILTER 0
#define CONFIG_CHROMANR_FILTER 1
#define CONFIG_CHROMASHIFT_FILTER 1
#define CONFIG_CIESCOPE_FILTER 1
#define CONFIG_CODECVIEW_FILTER 1
#define CONFIG_COLORBALANCE_FILTER 1
#define CONFIG_COLORCHANNELMIXER_FILTER 1
#define CONFIG_COLORCONTRAST_FILTER 1
#define CONFIG_COLORCORRECT_FILTER 1
#define CONFIG_COLORDETECT_FILTER 1
#define CONFIG_COLORIZE_FILTER 1
#define CONFIG_COLORKEY_FILTER 1
#define CONFIG_COLORKEY_OPENCL_FILTER 0
#define CONFIG_COLORHOLD_FILTER 1
#define CONFIG_COLORLEVELS_FILTER 1
#define CONFIG_COLORMAP_FILTER 1
#define CONFIG_COLORMATRIX_FILTER 0
#define CONFIG_COLORSPACE_FILTER 1
#define CONFIG_COLORSPACE_CUDA_FILTER 0
#define CONFIG_COLORTEMPERATURE_FILTER 1
#define CONFIG_CONVOLUTION_FILTER 1
#define CONFIG_CONVOLUTION_OPENCL_FILTER 0
#define CONFIG_CONVOLVE_FILTER 1
#define CONFIG_COPY_FILTER 1
#define CONFIG_COREIMAGE_FILTER 0
#define CONFIG_CORR_FILTER 1
#define CONFIG_COVER_RECT_FILTER 0
#define CONFIG_CROP_FILTER 1
#define CONFIG_CROPDETECT_FILTER 0
#define CONFIG_CUE_FILTER 1
#define CONFIG_CURVES_FILTER 1
#define CONFIG_DATASCOPE_FILTER 1
#define CONFIG_DBLUR_FILTER 1
#define CONFIG_DCTDNOIZ_FILTER 1
#define CONFIG_DEBAND_FILTER 1
#define CONFIG_DEBLOCK_FILTER 1
#define CONFIG_DECIMATE_FILTER 1
#define CONFIG_DECONVOLVE_FILTER 1
#define CONFIG_DEDOT_FILTER 1
#define CONFIG_DEFLATE_FILTER 1
#define CONFIG_DEFLICKER_FILTER 1
#define CONFIG_DEINTERLACE_QSV_FILTER 0
#define CONFIG_DEINTERLACE_D3D12_FILTER 0
#define CONFIG_DEINTERLACE_VAAPI_FILTER 0
#define CONFIG_DEJUDDER_FILTER 1
#define CONFIG_DELOGO_FILTER 0
#define CONFIG_DENOISE_VAAPI_FILTER 0
#define CONFIG_DERAIN_FILTER 0
#define CONFIG_DESHAKE_FILTER 1
#define CONFIG_DESHAKE_OPENCL_FILTER 0
#define CONFIG_DESPILL_FILTER 1
#define CONFIG_DETELECINE_FILTER 1
#define CONFIG_DILATION_FILTER 1
#define CONFIG_DILATION_OPENCL_FILTER 0
#define CONFIG_DISPLACE_FILTER 1
#define CONFIG_DNN_CLASSIFY_FILTER 0
#define CONFIG_DNN_DETECT_FILTER 0
#define CONFIG_DNN_PROCESSING_FILTER 0
#define CONFIG_DOUBLEWEAVE_FILTER 1
#define CONFIG_DRAWBOX_FILTER 1
#define CONFIG_DRAWGRAPH_FILTER 1
#define CONFIG_DRAWGRID_FILTER 1
#define CONFIG_DRAWTEXT_FILTER 0
#define CONFIG_DRAWVG_FILTER 0
#define CONFIG_EDGEDETECT_FILTER 1
#define CONFIG_ELBG_FILTER 1
#define CONFIG_ENTROPY_FILTER 1
#define CONFIG_EPX_FILTER 1
#define CONFIG_EQ_FILTER 0
#define CONFIG_EROSION_FILTER 1
#define CONFIG_EROSION_OPENCL_FILTER 0
#define CONFIG_ESTDIF_FILTER 1
#define CONFIG_EXPOSURE_FILTER 1
#define CONFIG_EXTRACTPLANES_FILTER 1
#define CONFIG_FADE_FILTER 1
#define CONFIG_FEEDBACK_FILTER 1
#define CONFIG_FFTDNOIZ_FILTER 1
#define CONFIG_FFTFILT_FILTER 1
#define CONFIG_FIELD_FILTER 1
#define CONFIG_FIELDHINT_FILTER 1
#define CONFIG_FIELDMATCH_FILTER 1
#define CONFIG_FIELDORDER_FILTER 1
#define CONFIG_FILLBORDERS_FILTER 1
#define CONFIG_FIND_RECT_FILTER 0
#define CONFIG_FLIP_VULKAN_FILTER 0
#define CONFIG_FLOODFILL_FILTER 1
#define CONFIG_FORMAT_FILTER 1
#define CONFIG_FPS_FILTER 1
#define CONFIG_FRAMEPACK_FILTER 1
#define CONFIG_FRAMERATE_FILTER 1
#define CONFIG_FRAMESTEP_FILTER 1
#define CONFIG_FREEZEDETECT_FILTER 1
#define CONFIG_FREEZEFRAMES_FILTER 1
#define CONFIG_FREI0R_FILTER 0
#define CONFIG_FSPP_FILTER 0
#define CONFIG_FSYNC_FILTER 1
#define CONFIG_GBLUR_FILTER 1
#define CONFIG_GBLUR_VULKAN_FILTER 0
#define CONFIG_GEQ_FILTER 1
#define CONFIG_GRADFUN_FILTER 1
#define CONFIG_GRAPHMONITOR_FILTER 1
#define CONFIG_GRAYWORLD_FILTER 1
#define CONFIG_GREYEDGE_FILTER 1
#define CONFIG_GUIDED_FILTER 1
#define CONFIG_HALDCLUT_FILTER 1
#define CONFIG_HFLIP_FILTER 1
#define CONFIG_HFLIP_VULKAN_FILTER 0
#define CONFIG_HISTEQ_FILTER 0
#define CONFIG_HISTOGRAM_FILTER 1
#define CONFIG_HQDN3D_FILTER 0
#define CONFIG_HQX_FILTER 1
#define CONFIG_HSTACK_FILTER 1
#define CONFIG_HSVHOLD_FILTER 1
#define CONFIG_HSVKEY_FILTER 1
#define CONFIG_HUE_FILTER 1
#define CONFIG_HUESATURATION_FILTER 1
#define CONFIG_HWDOWNLOAD_FILTER 1
#define CONFIG_HWMAP_FILTER 1
#define CONFIG_HWUPLOAD_FILTER 1
#define CONFIG_HWUPLOAD_CUDA_FILTER 0
#define CONFIG_HYSTERESIS_FILTER 1
#define CONFIG_ICCDETECT_FILTER 0
#define CONFIG_ICCGEN_FILTER 0
#define CONFIG_IDENTITY_FILTER 1
#define CONFIG_IDET_FILTER 1
#define CONFIG_IL_FILTER 1
#define CONFIG_INFLATE_FILTER 1
#define CONFIG_INTERLACE_FILTER 0
#define CONFIG_INTERLACE_VULKAN_FILTER 0
#define CONFIG_INTERLEAVE_FILTER 1
#define CONFIG_KERNDEINT_FILTER 0
#define CONFIG_KIRSCH_FILTER 1
#define CONFIG_LAGFUN_FILTER 1
#define CONFIG_LATENCY_FILTER 1
#define CONFIG_LCEVC_FILTER 0
#define CONFIG_LENSCORRECTION_FILTER 1
#define CONFIG_LENSFUN_FILTER 0
#define CONFIG_LIBPLACEBO_FILTER 0
#define CONFIG_LIBVMAF_FILTER 0
#define CONFIG_LIBVMAF_CUDA_FILTER 0
#define CONFIG_LIMITDIFF_FILTER 1
#define CONFIG_LIMITER_FILTER 1
#define CONFIG_LOOP_FILTER 1
#define CONFIG_LUMAKEY_FILTER 1
#define CONFIG_LUT_FILTER 1
#define CONFIG_LUT1D_FILTER 1
#define CONFIG_LUT2_FILTER 1
#define CONFIG_LUT3D_FILTER 1
#define CONFIG_LUTRGB_FILTER 1
#define CONFIG_LUTYUV_FILTER 1
#define CONFIG_MASKEDCLAMP_FILTER 1
#define CONFIG_MASKEDMAX_FILTER 1
#define CONFIG_MASKEDMERGE_FILTER 1
#define CONFIG_MASKEDMIN_FILTER 1
#define CONFIG_MASKEDTHRESHOLD_FILTER 1
#define CONFIG_MASKFUN_FILTER 1
#define CONFIG_MCDEINT_FILTER 0
#define CONFIG_MEDIAN_FILTER 1
#define CONFIG_MERGEPLANES_FILTER 1
#define CONFIG_MESTIMATE_FILTER 1
#define CONFIG_MESTIMATE_D3D12_FILTER 0
#define CONFIG_METADATA_FILTER 1
#define CONFIG_MIDEQUALIZER_FILTER 1
#define CONFIG_MINTERPOLATE_FILTER 1
#define CONFIG_MIX_FILTER 1
#define CONFIG_MONOCHROME_FILTER 1
#define CONFIG_MORPHO_FILTER 1
#define CONFIG_MPDECIMATE_FILTER 0
#define CONFIG_MSAD_FILTER 1
#define CONFIG_MULTIPLY_FILTER 1
#define CONFIG_NEGATE_FILTER 1
#define CONFIG_NLMEANS_FILTER 1
#define CONFIG_NLMEANS_OPENCL_FILTER 0
#define CONFIG_NLMEANS_VULKAN_FILTER 0
#define CONFIG_NNEDI_FILTER 0
#define CONFIG_NOFORMAT_FILTER 1
#define CONFIG_NOISE_FILTER 1
#define CONFIG_NORMALIZE_FILTER 1
#define CONFIG_NULL_FILTER 1
#define CONFIG_OCR_FILTER 0
#define CONFIG_OCV_FILTER 0
#define CONFIG_OSCILLOSCOPE_FILTER 1
#define CONFIG_OCIO_FILTER 0
#define CONFIG_OVERLAY_FILTER 1
#define CONFIG_OVERLAY_OPENCL_FILTER 0
#define CONFIG_OVERLAY_QSV_FILTER 0
#define CONFIG_OVERLAY_VAAPI_FILTER 0
#define CONFIG_OVERLAY_VULKAN_FILTER 0
#define CONFIG_OVERLAY_CUDA_FILTER 0
#define CONFIG_OWDENOISE_FILTER 0
#define CONFIG_PAD_FILTER 1
#define CONFIG_PAD_CUDA_FILTER 0
#define CONFIG_PAD_OPENCL_FILTER 0
#define CONFIG_PALETTEGEN_FILTER 1
#define CONFIG_PALETTEUSE_FILTER 1
#define CONFIG_PERMS_FILTER 1
#define CONFIG_PERSPECTIVE_FILTER 0
#define CONFIG_PHASE_FILTER 0
#define CONFIG_PHOTOSENSITIVITY_FILTER 1
#define CONFIG_PIXDESCTEST_FILTER 1
#define CONFIG_PIXELIZE_FILTER 1
#define CONFIG_PIXSCOPE_FILTER 1
#define CONFIG_PP7_FILTER 0
#define CONFIG_PREMULTIPLY_FILTER 1
#define CONFIG_PREMULTIPLY_DYNAMIC_FILTER 1
#define CONFIG_PREWITT_FILTER 1
#define CONFIG_PREWITT_OPENCL_FILTER 0
#define CONFIG_PROCAMP_VAAPI_FILTER 0
#define CONFIG_PROGRAM_OPENCL_FILTER 0
#define CONFIG_PSEUDOCOLOR_FILTER 1
#define CONFIG_PSNR_FILTER 1
#define CONFIG_PULLUP_FILTER 0
#define CONFIG_QP_FILTER 1
#define CONFIG_QRENCODE_FILTER 0
#define CONFIG_QUIRC_FILTER 0
#define CONFIG_RANDOM_FILTER 1
#define CONFIG_READEIA608_FILTER 1
#define CONFIG_READVITC_FILTER 1
#define CONFIG_REALTIME_FILTER 1
#define CONFIG_REMAP_FILTER 1
#define CONFIG_REMAP_OPENCL_FILTER 0
#define CONFIG_REMOVEGRAIN_FILTER 1
#define CONFIG_REMOVELOGO_FILTER 1
#define CONFIG_REPEATFIELDS_FILTER 0
#define CONFIG_REVERSE_FILTER 1
#define CONFIG_RGBASHIFT_FILTER 1
#define CONFIG_ROBERTS_FILTER 1
#define CONFIG_ROBERTS_OPENCL_FILTER 0
#define CONFIG_ROTATE_FILTER 1
#define CONFIG_SAB_FILTER 0
#define CONFIG_SCALE_FILTER 1
#define CONFIG_VPP_AMF_FILTER 0
#define CONFIG_SR_AMF_FILTER 0
#define CONFIG_SCALE_CUDA_FILTER 0
#define CONFIG_SCALE_D3D11_FILTER 0
#define CONFIG_SCALE_D3D12_FILTER 0
#define CONFIG_SCALE_NPP_FILTER 0
#define CONFIG_SCALE_QSV_FILTER 0
#define CONFIG_SCALE_VAAPI_FILTER 0
#define CONFIG_SCALE_VT_FILTER 0
#define CONFIG_SCALE_VULKAN_FILTER 0
#define CONFIG_SCALE2REF_FILTER 1
#define CONFIG_SCALE2REF_NPP_FILTER 0
#define CONFIG_SCDET_FILTER 1
#define CONFIG_SCDET_VULKAN_FILTER 0
#define CONFIG_SCHARR_FILTER 1
#define CONFIG_SCROLL_FILTER 1
#define CONFIG_SEGMENT_FILTER 1
#define CONFIG_SELECT_FILTER 1
#define CONFIG_SELECTIVECOLOR_FILTER 1
#define CONFIG_SENDCMD_FILTER 1
#define CONFIG_SEPARATEFIELDS_FILTER 1
#define CONFIG_SETDAR_FILTER 1
#define CONFIG_SETFIELD_FILTER 1
#define CONFIG_SETPARAMS_FILTER 1
#define CONFIG_SETPTS_FILTER 1
#define CONFIG_SETRANGE_FILTER 1
#define CONFIG_SETSAR_FILTER 1
#define CONFIG_SETTB_FILTER 1
#define CONFIG_SHARPEN_NPP_FILTER 0
#define CONFIG_SHARPNESS_VAAPI_FILTER 0
#define CONFIG_SHEAR_FILTER 1
#define CONFIG_SHOWINFO_FILTER 1
#define CONFIG_SHOWPALETTE_FILTER 1
#define CONFIG_SHUFFLEFRAMES_FILTER 1
#define CONFIG_SHUFFLEPIXELS_FILTER 1
#define CONFIG_SHUFFLEPLANES_FILTER 1
#define CONFIG_SIDEDATA_FILTER 1
#define CONFIG_SIGNALSTATS_FILTER 1
#define CONFIG_SIGNATURE_FILTER 0
#define CONFIG_SITI_FILTER 1
#define CONFIG_SMARTBLUR_FILTER 0
#define CONFIG_SOBEL_FILTER 1
#define CONFIG_SOBEL_OPENCL_FILTER 0
#define CONFIG_SPLIT_FILTER 1
#define CONFIG_SPP_FILTER 0
#define CONFIG_SR_FILTER 0
#define CONFIG_SSIM_FILTER 1
#define CONFIG_SSIM360_FILTER 1
#define CONFIG_STEREO3D_FILTER 0
#define CONFIG_STREAMSELECT_FILTER 1
#define CONFIG_SUBTITLES_FILTER 0
#define CONFIG_SUPER2XSAI_FILTER 0
#define CONFIG_SWAPRECT_FILTER 1
#define CONFIG_SWAPUV_FILTER 1
#define CONFIG_TBLEND_FILTER 1
#define CONFIG_TELECINE_FILTER 1
#define CONFIG_THISTOGRAM_FILTER 1
#define CONFIG_THRESHOLD_FILTER 1
#define CONFIG_THUMBNAIL_FILTER 1
#define CONFIG_THUMBNAIL_CUDA_FILTER 0
#define CONFIG_TILE_FILTER 1
#define CONFIG_TILTANDSHIFT_FILTER 1
#define CONFIG_TINTERLACE_FILTER 0
#define CONFIG_TLUT2_FILTER 1
#define CONFIG_TMEDIAN_FILTER 1
#define CONFIG_TMIDEQUALIZER_FILTER 1
#define CONFIG_TMIX_FILTER 1
#define CONFIG_TONEMAP_FILTER 1
#define CONFIG_TONEMAP_OPENCL_FILTER 0
#define CONFIG_TONEMAP_VAAPI_FILTER 0
#define CONFIG_TPAD_FILTER 1
#define CONFIG_TRANSPOSE_FILTER 1
#define CONFIG_TRANSPOSE_NPP_FILTER 0
#define CONFIG_TRANSPOSE_OPENCL_FILTER 0
#define CONFIG_TRANSPOSE_VAAPI_FILTER 0
#define CONFIG_TRANSPOSE_VT_FILTER 0
#define CONFIG_TRANSPOSE_VULKAN_FILTER 0
#define CONFIG_TRIM_FILTER 1
#define CONFIG_UNPREMULTIPLY_FILTER 1
#define CONFIG_UNSHARP_FILTER 1
#define CONFIG_UNSHARP_OPENCL_FILTER 0
#define CONFIG_UNTILE_FILTER 1
#define CONFIG_USPP_FILTER 0
#define CONFIG_V360_FILTER 1
#define CONFIG_VAGUEDENOISER_FILTER 0
#define CONFIG_VARBLUR_FILTER 1
#define CONFIG_VECTORSCOPE_FILTER 1
#define CONFIG_VFLIP_FILTER 1
#define CONFIG_VFLIP_VULKAN_FILTER 0
#define CONFIG_VFRDET_FILTER 1
#define CONFIG_VIBRANCE_FILTER 1
#define CONFIG_VIDSTABDETECT_FILTER 0
#define CONFIG_VIDSTABTRANSFORM_FILTER 0
#define CONFIG_VIF_FILTER 1
#define CONFIG_VIGNETTE_FILTER 1
#define CONFIG_VMAFMOTION_FILTER 1
#define CONFIG_VPP_QSV_FILTER 0
#define CONFIG_VSTACK_FILTER 1
#define CONFIG_W3FDIF_FILTER 1
#define CONFIG_WAVEFORM_FILTER 1
#define CONFIG_WEAVE_FILTER 1
#define CONFIG_XBR_FILTER 1
#define CONFIG_XCORRELATE_FILTER 1
#define CONFIG_XFADE_FILTER 1
#define CONFIG_XFADE_OPENCL_FILTER 0
#define CONFIG_XFADE_VULKAN_FILTER 0
#define CONFIG_XMEDIAN_FILTER 1
#define CONFIG_XPSNR_FILTER 1
#define CONFIG_XSTACK_FILTER 1
#define CONFIG_YADIF_FILTER 1
#define CONFIG_YADIF_CUDA_FILTER 0
#define CONFIG_YADIF_VIDEOTOOLBOX_FILTER 0
#define CONFIG_YAEPBLUR_FILTER 1
#define CONFIG_ZMQ_FILTER 0
#define CONFIG_ZOOMPAN_FILTER 1
#define CONFIG_ZSCALE_FILTER 0
#define CONFIG_HSTACK_VAAPI_FILTER 0
#define CONFIG_VSTACK_VAAPI_FILTER 0
#define CONFIG_XSTACK_VAAPI_FILTER 0
#define CONFIG_HSTACK_QSV_FILTER 0
#define CONFIG_VSTACK_QSV_FILTER 0
#define CONFIG_XSTACK_QSV_FILTER 0
#define CONFIG_PAD_VAAPI_FILTER 0
#define CONFIG_DRAWBOX_VAAPI_FILTER 0
#define CONFIG_ALLRGB_FILTER 1
#define CONFIG_ALLYUV_FILTER 1
#define CONFIG_AMF_CAPTURE_FILTER 0
#define CONFIG_CELLAUTO_FILTER 1
#define CONFIG_COLOR_FILTER 1
#define CONFIG_COLOR_VULKAN_FILTER 0
#define CONFIG_COLORCHART_FILTER 1
#define CONFIG_COLORSPECTRUM_FILTER 1
#define CONFIG_COREIMAGESRC_FILTER 0
#define CONFIG_DDAGRAB_FILTER 0
#define CONFIG_FREI0R_SRC_FILTER 0
#define CONFIG_GFXCAPTURE_FILTER 0
#define CONFIG_GRADIENTS_FILTER 1
#define CONFIG_HALDCLUTSRC_FILTER 1
#define CONFIG_LIFE_FILTER 1
#define CONFIG_MANDELBROT_FILTER 1
#define CONFIG_MPTESTSRC_FILTER 0
#define CONFIG_NULLSRC_FILTER 1
#define CONFIG_OPENCLSRC_FILTER 0
#define CONFIG_QRENCODESRC_FILTER 0
#define CONFIG_PAL75BARS_FILTER 1
#define CONFIG_PAL100BARS_FILTER 1
#define CONFIG_PERLIN_FILTER 1
#define CONFIG_RGBTESTSRC_FILTER 1
#define CONFIG_SIERPINSKI_FILTER 1
#define CONFIG_SMPTEBARS_FILTER 1
#define CONFIG_SMPTEHDBARS_FILTER 1
#define CONFIG_TESTSRC_FILTER 1
#define CONFIG_TESTSRC2_FILTER 1
#define CONFIG_YUVTESTSRC_FILTER 1
#define CONFIG_ZONEPLATE_FILTER 1
#define CONFIG_NULLSINK_FILTER 1
#define CONFIG_A3DSCOPE_FILTER 1
#define CONFIG_ABITSCOPE_FILTER 1
#define CONFIG_ADRAWGRAPH_FILTER 1
#define CONFIG_AGRAPHMONITOR_FILTER 1
#define CONFIG_AHISTOGRAM_FILTER 1
#define CONFIG_APHASEMETER_FILTER 1
#define CONFIG_AVECTORSCOPE_FILTER 1
#define CONFIG_CONCAT_FILTER 1
#define CONFIG_SHOWCQT_FILTER 1
#define CONFIG_SHOWCWT_FILTER 1
#define CONFIG_SHOWFREQS_FILTER 1
#define CONFIG_SHOWSPATIAL_FILTER 1
#define CONFIG_SHOWSPECTRUM_FILTER 1
#define CONFIG_SHOWSPECTRUMPIC_FILTER 1
#define CONFIG_SHOWVOLUME_FILTER 1
#define CONFIG_SHOWWAVES_FILTER 1
#define CONFIG_SHOWWAVESPIC_FILTER 1
#define CONFIG_SPECTRUMSYNTH_FILTER 1
#define CONFIG_AVSYNCTEST_FILTER 1
#define CONFIG_AMOVIE_FILTER 1
#define CONFIG_MOVIE_FILTER 1
#define CONFIG_AA_DEMUXER 1
#define CONFIG_AAC_DEMUXER 1
#define CONFIG_AAX_DEMUXER 1
#define CONFIG_AC3_DEMUXER 1
#define CONFIG_AC4_DEMUXER 1
#define CONFIG_ACE_DEMUXER 1
#define CONFIG_ACM_DEMUXER 1
#define CONFIG_ACT_DEMUXER 1
#define CONFIG_ADF_DEMUXER 1
#define CONFIG_ADP_DEMUXER 1
#define CONFIG_ADS_DEMUXER 1
#define CONFIG_ADX_DEMUXER 1
#define CONFIG_AEA_DEMUXER 1
#define CONFIG_AFC_DEMUXER 1
#define CONFIG_AIFF_DEMUXER 1
#define CONFIG_AIX_DEMUXER 1
#define CONFIG_ALP_DEMUXER 1
#define CONFIG_AMR_DEMUXER 1
#define CONFIG_AMRNB_DEMUXER 1
#define CONFIG_AMRWB_DEMUXER 1
#define CONFIG_ANM_DEMUXER 1
#define CONFIG_APAC_DEMUXER 1
#define CONFIG_APC_DEMUXER 1
#define CONFIG_APE_DEMUXER 1
#define CONFIG_APM_DEMUXER 1
#define CONFIG_APNG_DEMUXER 1
#define CONFIG_APTX_DEMUXER 1
#define CONFIG_APTX_HD_DEMUXER 1
#define CONFIG_APV_DEMUXER 1
#define CONFIG_AQTITLE_DEMUXER 1
#define CONFIG_ARGO_ASF_DEMUXER 1
#define CONFIG_ARGO_BRP_DEMUXER 1
#define CONFIG_ARGO_CVG_DEMUXER 1
#define CONFIG_ASF_DEMUXER 1
#define CONFIG_ASF_O_DEMUXER 1
#define CONFIG_ASS_DEMUXER 1
#define CONFIG_AST_DEMUXER 1
#define CONFIG_AU_DEMUXER 1
#define CONFIG_AV1_DEMUXER 1
#define CONFIG_AVI_DEMUXER 1
#define CONFIG_AVR_DEMUXER 1
#define CONFIG_AVS_DEMUXER 1
#define CONFIG_AVS2_DEMUXER 1
#define CONFIG_AVS3_DEMUXER 1
#define CONFIG_BETHSOFTVID_DEMUXER 1
#define CONFIG_BFI_DEMUXER 1
#define CONFIG_BINTEXT_DEMUXER 1
#define CONFIG_BINK_DEMUXER 1
#define CONFIG_BINKA_DEMUXER 1
#define CONFIG_BIT_DEMUXER 1
#define CONFIG_BITPACKED_DEMUXER 1
#define CONFIG_BMV_DEMUXER 1
#define CONFIG_BFSTM_DEMUXER 1
#define CONFIG_BRSTM_DEMUXER 1
#define CONFIG_BOA_DEMUXER 1
#define CONFIG_BONK_DEMUXER 1
#define CONFIG_C93_DEMUXER 1
#define CONFIG_CAF_DEMUXER 1
#define CONFIG_CAVSVIDEO_DEMUXER 1
#define CONFIG_CDG_DEMUXER 1
#define CONFIG_CDXL_DEMUXER 1
#define CONFIG_CINE_DEMUXER 1
#define CONFIG_CODEC2_DEMUXER 1
#define CONFIG_CODEC2RAW_DEMUXER 1
#define CONFIG_CONCAT_DEMUXER 1
#define CONFIG_DASH_DEMUXER 0
#define CONFIG_DATA_DEMUXER 1
#define CONFIG_DAUD_DEMUXER 1
#define CONFIG_DCSTR_DEMUXER 1
#define CONFIG_DERF_DEMUXER 1
#define CONFIG_DFA_DEMUXER 1
#define CONFIG_DFPWM_DEMUXER 1
#define CONFIG_DHAV_DEMUXER 1
#define CONFIG_DIRAC_DEMUXER 1
#define CONFIG_DNXHD_DEMUXER 1
#define CONFIG_DSF_DEMUXER 1
#define CONFIG_DSICIN_DEMUXER 1
#define CONFIG_DSS_DEMUXER 1
#define CONFIG_DTS_DEMUXER 1
#define CONFIG_DTSHD_DEMUXER 1
#define CONFIG_DV_DEMUXER 1
#define CONFIG_DVBSUB_DEMUXER 1
#define CONFIG_DVBTXT_DEMUXER 1
#define CONFIG_DXA_DEMUXER 1
#define CONFIG_EA_DEMUXER 1
#define CONFIG_EA_CDATA_DEMUXER 1
#define CONFIG_EAC3_DEMUXER 1
#define CONFIG_EPAF_DEMUXER 1
#define CONFIG_EVC_DEMUXER 1
#define CONFIG_FFMETADATA_DEMUXER 1
#define CONFIG_FILMSTRIP_DEMUXER 1
#define CONFIG_FITS_DEMUXER 1
#define CONFIG_FLAC_DEMUXER 1
#define CONFIG_FLIC_DEMUXER 1
#define CONFIG_FLV_DEMUXER 1
#define CONFIG_LIVE_FLV_DEMUXER 1
#define CONFIG_FOURXM_DEMUXER 1
#define CONFIG_FRM_DEMUXER 1
#define CONFIG_FSB_DEMUXER 1
#define CONFIG_FWSE_DEMUXER 1
#define CONFIG_G722_DEMUXER 1
#define CONFIG_G723_1_DEMUXER 1
#define CONFIG_G726_DEMUXER 1
#define CONFIG_G726LE_DEMUXER 1
#define CONFIG_G728_DEMUXER 1
#define CONFIG_G729_DEMUXER 1
#define CONFIG_GDV_DEMUXER 1
#define CONFIG_GENH_DEMUXER 1
#define CONFIG_GIF_DEMUXER 1
#define CONFIG_GSM_DEMUXER 1
#define CONFIG_GXF_DEMUXER 1
#define CONFIG_H261_DEMUXER 1
#define CONFIG_H263_DEMUXER 1
#define CONFIG_H264_DEMUXER 1
#define CONFIG_HCA_DEMUXER 1
#define CONFIG_HCOM_DEMUXER 1
#define CONFIG_HEVC_DEMUXER 1
#define CONFIG_HLS_DEMUXER 1
#define CONFIG_HNM_DEMUXER 1
#define CONFIG_HXVS_DEMUXER 1
#define CONFIG_IAMF_DEMUXER 1
#define CONFIG_ICO_DEMUXER 1
#define CONFIG_IDCIN_DEMUXER 1
#define CONFIG_IDF_DEMUXER 1
#define CONFIG_IFF_DEMUXER 1
#define CONFIG_IFV_DEMUXER 1
#define CONFIG_ILBC_DEMUXER 1
#define CONFIG_IMAGE2_DEMUXER 1
#define CONFIG_IMAGE2PIPE_DEMUXER 1
#define CONFIG_IMAGE2_ALIAS_PIX_DEMUXER 1
#define CONFIG_IMAGE2_BRENDER_PIX_DEMUXER 1
#define CONFIG_IMF_DEMUXER 0
#define CONFIG_INGENIENT_DEMUXER 1
#define CONFIG_IPMOVIE_DEMUXER 1
#define CONFIG_IPU_DEMUXER 1
#define CONFIG_IRCAM_DEMUXER 1
#define CONFIG_ISS_DEMUXER 1
#define CONFIG_IV8_DEMUXER 1
#define CONFIG_IVF_DEMUXER 1
#define CONFIG_IVR_DEMUXER 1
#define CONFIG_JACOSUB_DEMUXER 1
#define CONFIG_JV_DEMUXER 1
#define CONFIG_JPEGXL_ANIM_DEMUXER 1
#define CONFIG_KUX_DEMUXER 1
#define CONFIG_KVAG_DEMUXER 1
#define CONFIG_LAF_DEMUXER 1
#define CONFIG_LC3_DEMUXER 1
#define CONFIG_LMLM4_DEMUXER 1
#define CONFIG_LOAS_DEMUXER 1
#define CONFIG_LUODAT_DEMUXER 1
#define CONFIG_LRC_DEMUXER 1
#define CONFIG_LVF_DEMUXER 1
#define CONFIG_LXF_DEMUXER 1
#define CONFIG_M4V_DEMUXER 1
#define CONFIG_MCA_DEMUXER 1
#define CONFIG_MCC_DEMUXER 1
#define CONFIG_MATROSKA_DEMUXER 1
#define CONFIG_MGSTS_DEMUXER 1
#define CONFIG_MICRODVD_DEMUXER 1
#define CONFIG_MJPEG_DEMUXER 1
#define CONFIG_MJPEG_2000_DEMUXER 1
#define CONFIG_MLP_DEMUXER 1
#define CONFIG_MLV_DEMUXER 1
#define CONFIG_MM_DEMUXER 1
#define CONFIG_MMF_DEMUXER 1
#define CONFIG_MODS_DEMUXER 1
#define CONFIG_MOFLEX_DEMUXER 1
#define CONFIG_MOV_DEMUXER 1
#define CONFIG_MP3_DEMUXER 1
#define CONFIG_MPC_DEMUXER 1
#define CONFIG_MPC8_DEMUXER 1
#define CONFIG_MPEGPS_DEMUXER 1
#define CONFIG_MPEGTS_DEMUXER 1
#define CONFIG_MPEGTSRAW_DEMUXER 1
#define CONFIG_MPEGVIDEO_DEMUXER 1
#define CONFIG_MPJPEG_DEMUXER 1
#define CONFIG_MPL2_DEMUXER 1
#define CONFIG_MPSUB_DEMUXER 1
#define CONFIG_MSF_DEMUXER 1
#define CONFIG_MSNWC_TCP_DEMUXER 1
#define CONFIG_MSP_DEMUXER 1
#define CONFIG_MTAF_DEMUXER 1
#define CONFIG_MTV_DEMUXER 1
#define CONFIG_MUSX_DEMUXER 1
#define CONFIG_MV_DEMUXER 1
#define CONFIG_MVI_DEMUXER 1
#define CONFIG_MXF_DEMUXER 1
#define CONFIG_MXG_DEMUXER 1
#define CONFIG_NC_DEMUXER 1
#define CONFIG_NISTSPHERE_DEMUXER 1
#define CONFIG_NSP_DEMUXER 1
#define CONFIG_NSV_DEMUXER 1
#define CONFIG_NUT_DEMUXER 1
#define CONFIG_NUV_DEMUXER 1
#define CONFIG_OBU_DEMUXER 1
#define CONFIG_OGG_DEMUXER 1
#define CONFIG_OMA_DEMUXER 1
#define CONFIG_OSQ_DEMUXER 1
#define CONFIG_PAF_DEMUXER 1
#define CONFIG_PCM_ALAW_DEMUXER 1
#define CONFIG_PCM_MULAW_DEMUXER 1
#define CONFIG_PCM_VIDC_DEMUXER 1
#define CONFIG_PCM_F64BE_DEMUXER 1
#define CONFIG_PCM_F64LE_DEMUXER 1
#define CONFIG_PCM_F32BE_DEMUXER 1
#define CONFIG_PCM_F32LE_DEMUXER 1
#define CONFIG_PCM_S32BE_DEMUXER 1
#define CONFIG_PCM_S32LE_DEMUXER 1
#define CONFIG_PCM_S24BE_DEMUXER 1
#define CONFIG_PCM_S24LE_DEMUXER 1
#define CONFIG_PCM_S16BE_DEMUXER 1
#define CONFIG_PCM_S16LE_DEMUXER 1
#define CONFIG_PCM_S8_DEMUXER 1
#define CONFIG_PCM_U32BE_DEMUXER 1
#define CONFIG_PCM_U32LE_DEMUXER 1
#define CONFIG_PCM_U24BE_DEMUXER 1
#define CONFIG_PCM_U24LE_DEMUXER 1
#define CONFIG_PCM_U16BE_DEMUXER 1
#define CONFIG_PCM_U16LE_DEMUXER 1
#define CONFIG_PCM_U8_DEMUXER 1
#define CONFIG_PDV_DEMUXER 1
#define CONFIG_PJS_DEMUXER 1
#define CONFIG_PMP_DEMUXER 1
#define CONFIG_PP_BNK_DEMUXER 1
#define CONFIG_PVA_DEMUXER 1
#define CONFIG_PVF_DEMUXER 1
#define CONFIG_QCP_DEMUXER 1
#define CONFIG_QOA_DEMUXER 1
#define CONFIG_R3D_DEMUXER 1
#define CONFIG_RAWVIDEO_DEMUXER 1
#define CONFIG_RCWT_DEMUXER 1
#define CONFIG_REALTEXT_DEMUXER 1
#define CONFIG_REDSPARK_DEMUXER 1
#define CONFIG_RKA_DEMUXER 1
#define CONFIG_RL2_DEMUXER 1
#define CONFIG_RM_DEMUXER 1
#define CONFIG_ROQ_DEMUXER 1
#define CONFIG_RPL_DEMUXER 1
#define CONFIG_RSD_DEMUXER 1
#define CONFIG_RSO_DEMUXER 1
#define CONFIG_RTP_DEMUXER 1
#define CONFIG_RTSP_DEMUXER 1
#define CONFIG_S337M_DEMUXER 1
#define CONFIG_SAMI_DEMUXER 1
#define CONFIG_SAP_DEMUXER 1
#define CONFIG_SBC_DEMUXER 1
#define CONFIG_SBG_DEMUXER 1
#define CONFIG_SCC_DEMUXER 1
#define CONFIG_SCD_DEMUXER 1
#define CONFIG_SDNS_DEMUXER 1
#define CONFIG_SDP_DEMUXER 1
#define CONFIG_SDR2_DEMUXER 1
#define CONFIG_SDS_DEMUXER 1
#define CONFIG_SDX_DEMUXER 1
#define CONFIG_SEGAFILM_DEMUXER 1
#define CONFIG_SER_DEMUXER 1
#define CONFIG_SGA_DEMUXER 1
#define CONFIG_SHORTEN_DEMUXER 1
#define CONFIG_SIFF_DEMUXER 1
#define CONFIG_SIMBIOSIS_IMX_DEMUXER 1
#define CONFIG_SLN_DEMUXER 1
#define CONFIG_SMACKER_DEMUXER 1
#define CONFIG_SMJPEG_DEMUXER 1
#define CONFIG_SMUSH_DEMUXER 1
#define CONFIG_SOL_DEMUXER 1
#define CONFIG_SOX_DEMUXER 1
#define CONFIG_SPDIF_DEMUXER 1
#define CONFIG_SRT_DEMUXER 1
#define CONFIG_STR_DEMUXER 1
#define CONFIG_STL_DEMUXER 1
#define CONFIG_SUBVIEWER1_DEMUXER 1
#define CONFIG_SUBVIEWER_DEMUXER 1
#define CONFIG_SUP_DEMUXER 1
#define CONFIG_SVAG_DEMUXER 1
#define CONFIG_SVS_DEMUXER 1
#define CONFIG_SWF_DEMUXER 1
#define CONFIG_TAK_DEMUXER 1
#define CONFIG_TEDCAPTIONS_DEMUXER 1
#define CONFIG_THP_DEMUXER 1
#define CONFIG_THREEDOSTR_DEMUXER 1
#define CONFIG_TIERTEXSEQ_DEMUXER 1
#define CONFIG_TMV_DEMUXER 1
#define CONFIG_TRUEHD_DEMUXER 1
#define CONFIG_TTA_DEMUXER 1
#define CONFIG_TXD_DEMUXER 1
#define CONFIG_TTY_DEMUXER 1
#define CONFIG_TY_DEMUXER 1
#define CONFIG_USM_DEMUXER 1
#define CONFIG_V210_DEMUXER 1
#define CONFIG_V210X_DEMUXER 1
#define CONFIG_VAG_DEMUXER 1
#define CONFIG_VC1_DEMUXER 1
#define CONFIG_VC1T_DEMUXER 1
#define CONFIG_VIVIDAS_DEMUXER 1
#define CONFIG_VIVO_DEMUXER 1
#define CONFIG_VMD_DEMUXER 1
#define CONFIG_VOBSUB_DEMUXER 1
#define CONFIG_VOC_DEMUXER 1
#define CONFIG_VPK_DEMUXER 1
#define CONFIG_VPLAYER_DEMUXER 1
#define CONFIG_VQF_DEMUXER 1
#define CONFIG_VVC_DEMUXER 1
#define CONFIG_W64_DEMUXER 1
#define CONFIG_WADY_DEMUXER 1
#define CONFIG_WAVARC_DEMUXER 1
#define CONFIG_WAV_DEMUXER 1
#define CONFIG_WC3_DEMUXER 1
#define CONFIG_WEBM_DASH_MANIFEST_DEMUXER 1
#define CONFIG_WEBVTT_DEMUXER 1
#define CONFIG_WSAUD_DEMUXER 1
#define CONFIG_WSD_DEMUXER 1
#define CONFIG_WSVQA_DEMUXER 1
#define CONFIG_WTV_DEMUXER 1
#define CONFIG_WVE_DEMUXER 1
#define CONFIG_WV_DEMUXER 1
#define CONFIG_XA_DEMUXER 1
#define CONFIG_XBIN_DEMUXER 1
#define CONFIG_XMD_DEMUXER 1
#define CONFIG_XMV_DEMUXER 1
#define CONFIG_XVAG_DEMUXER 1
#define CONFIG_XWMA_DEMUXER 1
#define CONFIG_YOP_DEMUXER 1
#define CONFIG_YUV4MPEGPIPE_DEMUXER 1
#define CONFIG_IMAGE_BMP_PIPE_DEMUXER 1
#define CONFIG_IMAGE_CRI_PIPE_DEMUXER 1
#define CONFIG_IMAGE_DDS_PIPE_DEMUXER 1
#define CONFIG_IMAGE_DPX_PIPE_DEMUXER 1
#define CONFIG_IMAGE_EXR_PIPE_DEMUXER 1
#define CONFIG_IMAGE_GEM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_GIF_PIPE_DEMUXER 1
#define CONFIG_IMAGE_HDR_PIPE_DEMUXER 1
#define CONFIG_IMAGE_J2K_PIPE_DEMUXER 1
#define CONFIG_IMAGE_JPEG_PIPE_DEMUXER 1
#define CONFIG_IMAGE_JPEGLS_PIPE_DEMUXER 1
#define CONFIG_IMAGE_JPEGXL_PIPE_DEMUXER 1
#define CONFIG_IMAGE_JPEGXS_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PAM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PBM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PCX_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PFM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PGMYUV_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PGM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PGX_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PHM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PHOTOCD_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PICTOR_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PNG_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PPM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_PSD_PIPE_DEMUXER 1
#define CONFIG_IMAGE_QDRAW_PIPE_DEMUXER 1
#define CONFIG_IMAGE_QOI_PIPE_DEMUXER 1
#define CONFIG_IMAGE_SGI_PIPE_DEMUXER 1
#define CONFIG_IMAGE_SVG_PIPE_DEMUXER 1
#define CONFIG_IMAGE_SUNRAST_PIPE_DEMUXER 1
#define CONFIG_IMAGE_TIFF_PIPE_DEMUXER 1
#define CONFIG_IMAGE_VBN_PIPE_DEMUXER 1
#define CONFIG_IMAGE_WEBP_PIPE_DEMUXER 1
#define CONFIG_IMAGE_XBM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_XPM_PIPE_DEMUXER 1
#define CONFIG_IMAGE_XWD_PIPE_DEMUXER 1
#define CONFIG_AVISYNTH_DEMUXER 0
#define CONFIG_DVDVIDEO_DEMUXER 0
#define CONFIG_LIBGME_DEMUXER 0
#define CONFIG_LIBMODPLUG_DEMUXER 0
#define CONFIG_LIBOPENMPT_DEMUXER 0
#define CONFIG_VAPOURSYNTH_DEMUXER 0
#define CONFIG_A64_MUXER 1
#define CONFIG_AC3_MUXER 1
#define CONFIG_AC4_MUXER 1
#define CONFIG_ADTS_MUXER 1
#define CONFIG_ADX_MUXER 1
#define CONFIG_AEA_MUXER 1
#define CONFIG_AIFF_MUXER 1
#define CONFIG_ALP_MUXER 1
#define CONFIG_AMR_MUXER 1
#define CONFIG_AMV_MUXER 1
#define CONFIG_APM_MUXER 1
#define CONFIG_APNG_MUXER 1
#define CONFIG_APTX_MUXER 1
#define CONFIG_APTX_HD_MUXER 1
#define CONFIG_APV_MUXER 1
#define CONFIG_ARGO_ASF_MUXER 1
#define CONFIG_ARGO_CVG_MUXER 1
#define CONFIG_ASF_MUXER 1
#define CONFIG_ASS_MUXER 1
#define CONFIG_AST_MUXER 1
#define CONFIG_ASF_STREAM_MUXER 1
#define CONFIG_AU_MUXER 1
#define CONFIG_AVI_MUXER 1
#define CONFIG_AVIF_MUXER 1
#define CONFIG_AVM2_MUXER 1
#define CONFIG_AVS2_MUXER 1
#define CONFIG_AVS3_MUXER 1
#define CONFIG_BIT_MUXER 1
#define CONFIG_CAF_MUXER 1
#define CONFIG_CAVSVIDEO_MUXER 1
#define CONFIG_CODEC2_MUXER 1
#define CONFIG_CODEC2RAW_MUXER 1
#define CONFIG_CRC_MUXER 1
#define CONFIG_DASH_MUXER 1
#define CONFIG_DATA_MUXER 1
#define CONFIG_DAUD_MUXER 1
#define CONFIG_DFPWM_MUXER 1
#define CONFIG_DIRAC_MUXER 1
#define CONFIG_DNXHD_MUXER 1
#define CONFIG_DTS_MUXER 1
#define CONFIG_DV_MUXER 1
#define CONFIG_EAC3_MUXER 1
#define CONFIG_EVC_MUXER 1
#define CONFIG_F4V_MUXER 1
#define CONFIG_FFMETADATA_MUXER 1
#define CONFIG_FIFO_MUXER 1
#define CONFIG_FILMSTRIP_MUXER 1
#define CONFIG_FITS_MUXER 1
#define CONFIG_FLAC_MUXER 1
#define CONFIG_FLV_MUXER 1
#define CONFIG_FRAMECRC_MUXER 1
#define CONFIG_FRAMEHASH_MUXER 1
#define CONFIG_FRAMEMD5_MUXER 1
#define CONFIG_G722_MUXER 1
#define CONFIG_G723_1_MUXER 1
#define CONFIG_G726_MUXER 1
#define CONFIG_G726LE_MUXER 1
#define CONFIG_GIF_MUXER 1
#define CONFIG_GSM_MUXER 1
#define CONFIG_GXF_MUXER 1
#define CONFIG_H261_MUXER 1
#define CONFIG_H263_MUXER 1
#define CONFIG_H264_MUXER 1
#define CONFIG_HASH_MUXER 1
#define CONFIG_HDS_MUXER 1
#define CONFIG_HEVC_MUXER 1
#define CONFIG_HLS_MUXER 1
#define CONFIG_IAMF_MUXER 1
#define CONFIG_ICO_MUXER 1
#define CONFIG_ILBC_MUXER 1
#define CONFIG_IMAGE2_MUXER 1
#define CONFIG_IMAGE2PIPE_MUXER 1
#define CONFIG_IPOD_MUXER 1
#define CONFIG_IRCAM_MUXER 1
#define CONFIG_ISMV_MUXER 1
#define CONFIG_IVF_MUXER 1
#define CONFIG_JACOSUB_MUXER 1
#define CONFIG_KVAG_MUXER 1
#define CONFIG_LATM_MUXER 1
#define CONFIG_LC3_MUXER 1
#define CONFIG_LRC_MUXER 1
#define CONFIG_M4V_MUXER 1
#define CONFIG_MCC_MUXER 1
#define CONFIG_MD5_MUXER 1
#define CONFIG_MATROSKA_MUXER 1
#define CONFIG_MATROSKA_AUDIO_MUXER 1
#define CONFIG_MICRODVD_MUXER 1
#define CONFIG_MJPEG_MUXER 1
#define CONFIG_MLP_MUXER 1
#define CONFIG_MMF_MUXER 1
#define CONFIG_MOV_MUXER 1
#define CONFIG_MP2_MUXER 1
#define CONFIG_MP3_MUXER 1
#define CONFIG_MP4_MUXER 1
#define CONFIG_MPEG1SYSTEM_MUXER 1
#define CONFIG_MPEG1VCD_MUXER 1
#define CONFIG_MPEG1VIDEO_MUXER 1
#define CONFIG_MPEG2DVD_MUXER 1
#define CONFIG_MPEG2SVCD_MUXER 1
#define CONFIG_MPEG2VIDEO_MUXER 1
#define CONFIG_MPEG2VOB_MUXER 1
#define CONFIG_MPEGTS_MUXER 1
#define CONFIG_MPJPEG_MUXER 1
#define CONFIG_MXF_MUXER 1
#define CONFIG_MXF_D10_MUXER 1
#define CONFIG_MXF_OPATOM_MUXER 1
#define CONFIG_NULL_MUXER 1
#define CONFIG_NUT_MUXER 1
#define CONFIG_OBU_MUXER 1
#define CONFIG_OGA_MUXER 1
#define CONFIG_OGG_MUXER 1
#define CONFIG_OGV_MUXER 1
#define CONFIG_OMA_MUXER 1
#define CONFIG_OPUS_MUXER 1
#define CONFIG_PCM_ALAW_MUXER 1
#define CONFIG_PCM_MULAW_MUXER 1
#define CONFIG_PCM_VIDC_MUXER 1
#define CONFIG_PCM_F64BE_MUXER 1
#define CONFIG_PCM_F64LE_MUXER 1
#define CONFIG_PCM_F32BE_MUXER 1
#define CONFIG_PCM_F32LE_MUXER 1
#define CONFIG_PCM_S32BE_MUXER 1
#define CONFIG_PCM_S32LE_MUXER 1
#define CONFIG_PCM_S24BE_MUXER 1
#define CONFIG_PCM_S24LE_MUXER 1
#define CONFIG_PCM_S16BE_MUXER 1
#define CONFIG_PCM_S16LE_MUXER 1
#define CONFIG_PCM_S8_MUXER 1
#define CONFIG_PCM_U32BE_MUXER 1
#define CONFIG_PCM_U32LE_MUXER 1
#define CONFIG_PCM_U24BE_MUXER 1
#define CONFIG_PCM_U24LE_MUXER 1
#define CONFIG_PCM_U16BE_MUXER 1
#define CONFIG_PCM_U16LE_MUXER 1
#define CONFIG_PCM_U8_MUXER 1
#define CONFIG_PSP_MUXER 1
#define CONFIG_RAWVIDEO_MUXER 1
#define CONFIG_RCWT_MUXER 1
#define CONFIG_RM_MUXER 1
#define CONFIG_ROQ_MUXER 1
#define CONFIG_RSO_MUXER 1
#define CONFIG_RTP_MUXER 1
#define CONFIG_RTP_MPEGTS_MUXER 1
#define CONFIG_RTSP_MUXER 1
#define CONFIG_SAP_MUXER 1
#define CONFIG_SBC_MUXER 1
#define CONFIG_SCC_MUXER 1
#define CONFIG_SEGAFILM_MUXER 1
#define CONFIG_SEGMENT_MUXER 1
#define CONFIG_STREAM_SEGMENT_MUXER 1
#define CONFIG_SMJPEG_MUXER 1
#define CONFIG_SMOOTHSTREAMING_MUXER 1
#define CONFIG_SOX_MUXER 1
#define CONFIG_SPX_MUXER 1
#define CONFIG_SPDIF_MUXER 1
#define CONFIG_SRT_MUXER 1
#define CONFIG_STREAMHASH_MUXER 1
#define CONFIG_SUP_MUXER 1
#define CONFIG_SWF_MUXER 1
#define CONFIG_TEE_MUXER 1
#define CONFIG_TG2_MUXER 1
#define CONFIG_TGP_MUXER 1
#define CONFIG_MKVTIMESTAMP_V2_MUXER 1
#define CONFIG_TRUEHD_MUXER 1
#define CONFIG_TTA_MUXER 1
#define CONFIG_TTML_MUXER 1
#define CONFIG_UNCODEDFRAMECRC_MUXER 1
#define CONFIG_VC1_MUXER 1
#define CONFIG_VC1T_MUXER 1
#define CONFIG_VOC_MUXER 1
#define CONFIG_VVC_MUXER 1
#define CONFIG_W64_MUXER 1
#define CONFIG_WAV_MUXER 1
#define CONFIG_WEBM_MUXER 1
#define CONFIG_WEBM_DASH_MANIFEST_MUXER 1
#define CONFIG_WEBM_CHUNK_MUXER 1
#define CONFIG_WEBP_MUXER 1
#define CONFIG_WEBVTT_MUXER 1
#define CONFIG_WHIP_MUXER 0
#define CONFIG_WSAUD_MUXER 1
#define CONFIG_WTV_MUXER 1
#define CONFIG_WV_MUXER 1
#define CONFIG_YUV4MPEGPIPE_MUXER 1
#define CONFIG_CHROMAPRINT_MUXER 0
#define CONFIG_ANDROID_CONTENT_PROTOCOL 0
#define CONFIG_ASYNC_PROTOCOL 1
#define CONFIG_BLURAY_PROTOCOL 0
#define CONFIG_CACHE_PROTOCOL 1
#define CONFIG_CONCAT_PROTOCOL 1
#define CONFIG_CONCATF_PROTOCOL 1
#define CONFIG_CRYPTO_PROTOCOL 1
#define CONFIG_DATA_PROTOCOL 1
#define CONFIG_FD_PROTOCOL 1
#define CONFIG_FFRTMPCRYPT_PROTOCOL 0
#define CONFIG_FFRTMPHTTP_PROTOCOL 1
#define CONFIG_FILE_PROTOCOL 1
#define CONFIG_FTP_PROTOCOL 1
#define CONFIG_GOPHER_PROTOCOL 1
#define CONFIG_GOPHERS_PROTOCOL 0
#define CONFIG_HTTP_PROTOCOL 1
#define CONFIG_HTTPPROXY_PROTOCOL 1
#define CONFIG_HTTPS_PROTOCOL 0
#define CONFIG_ICECAST_PROTOCOL 1
#define CONFIG_MMSH_PROTOCOL 1
#define CONFIG_MMST_PROTOCOL 1
#define CONFIG_MD5_PROTOCOL 1
#define CONFIG_PIPE_PROTOCOL 1
#define CONFIG_PROMPEG_PROTOCOL 1
#define CONFIG_RTMP_PROTOCOL 1
#define CONFIG_RTMPE_PROTOCOL 0
#define CONFIG_RTMPS_PROTOCOL 0
#define CONFIG_RTMPT_PROTOCOL 1
#define CONFIG_RTMPTE_PROTOCOL 0
#define CONFIG_RTMPTS_PROTOCOL 0
#define CONFIG_RTP_PROTOCOL 1
#define CONFIG_SCTP_PROTOCOL 0
#define CONFIG_SRTP_PROTOCOL 1
#define CONFIG_SUBFILE_PROTOCOL 1
#define CONFIG_TEE_PROTOCOL 1
#define CONFIG_TCP_PROTOCOL 1
#define CONFIG_TLS_PROTOCOL 0
#define CONFIG_DTLS_PROTOCOL 0
#define CONFIG_UDP_PROTOCOL 1
#define CONFIG_UDPLITE_PROTOCOL 1
#define CONFIG_UNIX_PROTOCOL 0
#define CONFIG_LIBAMQP_PROTOCOL 0
#define CONFIG_LIBRIST_PROTOCOL 0
#define CONFIG_LIBRTMP_PROTOCOL 0
#define CONFIG_LIBRTMPE_PROTOCOL 0
#define CONFIG_LIBRTMPS_PROTOCOL 0
#define CONFIG_LIBRTMPT_PROTOCOL 0
#define CONFIG_LIBRTMPTE_PROTOCOL 0
#define CONFIG_LIBSRT_PROTOCOL 0
#define CONFIG_LIBSSH_PROTOCOL 0
#define CONFIG_LIBSMBCLIENT_PROTOCOL 0
#define CONFIG_LIBZMQ_PROTOCOL 0
#define CONFIG_IPFS_GATEWAY_PROTOCOL 0
#define CONFIG_IPNS_GATEWAY_PROTOCOL 0
#endif /* FFMPEG_CONFIG_COMPONENTS_H */
]==],
        ["mcpp_generated/config.asm"] = [==[
; Automatically generated by configure - do not modify!
%define ARCH_AARCH64 0
%define ARCH_ARM 0
%define ARCH_IA64 0
%define ARCH_LOONGARCH 0
%define ARCH_LOONGARCH32 0
%define ARCH_LOONGARCH64 0
%define ARCH_M68K 0
%define ARCH_MIPS 0
%define ARCH_MIPS64 0
%define ARCH_PARISC 0
%define ARCH_PPC 0
%define ARCH_PPC64 0
%define ARCH_RISCV 0
%define ARCH_S390 0
%define ARCH_SPARC 0
%define ARCH_SPARC64 0
%define ARCH_TILEGX 0
%define ARCH_TILEPRO 0
%define ARCH_WASM 0
%define ARCH_X86 1
%define ARCH_X86_32 0
%define ARCH_X86_64 1
%define HAVE_ARMV5TE 0
%define HAVE_ARMV6 0
%define HAVE_ARMV6T2 0
%define HAVE_ARMV8 0
%define HAVE_ARM_CRC 0
%define HAVE_DOTPROD 0
%define HAVE_I8MM 0
%define HAVE_NEON 0
%define HAVE_VFP 0
%define HAVE_VFPV3 0
%define HAVE_SETEND 0
%define HAVE_SVE 0
%define HAVE_SVE2 0
%define HAVE_SME 0
%define HAVE_SME_I16I64 0
%define HAVE_SME2 0
%define HAVE_ALTIVEC 0
%define HAVE_DCBZL 0
%define HAVE_LDBRX 0
%define HAVE_POWER8 0
%define HAVE_PPC4XX 0
%define HAVE_VEC_XL 0
%define HAVE_VSX 0
%define HAVE_RV 0
%define HAVE_RVV 0
%define HAVE_RV_ZICBOP 1
%define HAVE_RV_ZVBB 0
%define HAVE_SIMD128 0
%define HAVE_AESNI 1
%define HAVE_CLMUL 1
%define HAVE_AMD3DNOW 1
%define HAVE_AMD3DNOWEXT 1
%define HAVE_AVX 1
%define HAVE_AVX2 1
%define HAVE_AVX512 1
%define HAVE_AVX512ICL 1
%define HAVE_FMA3 1
%define HAVE_FMA4 1
%define HAVE_MMX 1
%define HAVE_MMXEXT 1
%define HAVE_SSE 1
%define HAVE_SSE2 1
%define HAVE_SSE3 1
%define HAVE_SSE4 1
%define HAVE_SSE42 1
%define HAVE_SSSE3 1
%define HAVE_XOP 1
%define HAVE_I686 1
%define HAVE_MIPSFPU 0
%define HAVE_MIPS32R2 0
%define HAVE_MIPS32R5 0
%define HAVE_MIPS64R2 0
%define HAVE_MIPS32R6 0
%define HAVE_MIPS64R6 0
%define HAVE_MIPSDSP 0
%define HAVE_MIPSDSPR2 0
%define HAVE_MSA 0
%define HAVE_LOONGSON2 0
%define HAVE_LOONGSON3 0
%define HAVE_MMI 0
%define HAVE_LSX 0
%define HAVE_LASX 0
%define HAVE_ARMV5TE_EXTERNAL 0
%define HAVE_ARMV6_EXTERNAL 0
%define HAVE_ARMV6T2_EXTERNAL 0
%define HAVE_ARMV8_EXTERNAL 0
%define HAVE_ARM_CRC_EXTERNAL 0
%define HAVE_DOTPROD_EXTERNAL 0
%define HAVE_I8MM_EXTERNAL 0
%define HAVE_NEON_EXTERNAL 0
%define HAVE_VFP_EXTERNAL 0
%define HAVE_VFPV3_EXTERNAL 0
%define HAVE_SETEND_EXTERNAL 0
%define HAVE_SVE_EXTERNAL 0
%define HAVE_SVE2_EXTERNAL 0
%define HAVE_SME_EXTERNAL 0
%define HAVE_SME_I16I64_EXTERNAL 0
%define HAVE_SME2_EXTERNAL 0
%define HAVE_ALTIVEC_EXTERNAL 0
%define HAVE_DCBZL_EXTERNAL 0
%define HAVE_LDBRX_EXTERNAL 0
%define HAVE_POWER8_EXTERNAL 0
%define HAVE_PPC4XX_EXTERNAL 0
%define HAVE_VEC_XL_EXTERNAL 0
%define HAVE_VSX_EXTERNAL 0
%define HAVE_RV_EXTERNAL 0
%define HAVE_RVV_EXTERNAL 0
%define HAVE_RV_ZICBOP_EXTERNAL 0
%define HAVE_RV_ZVBB_EXTERNAL 0
%define HAVE_SIMD128_EXTERNAL 0
%define HAVE_AESNI_EXTERNAL 1
%define HAVE_CLMUL_EXTERNAL 1
%define HAVE_AMD3DNOW_EXTERNAL 0
%define HAVE_AMD3DNOWEXT_EXTERNAL 0
%define HAVE_AVX_EXTERNAL 1
%define HAVE_AVX2_EXTERNAL 1
%define HAVE_AVX512_EXTERNAL 1
%define HAVE_AVX512ICL_EXTERNAL 1
%define HAVE_FMA3_EXTERNAL 1
%define HAVE_FMA4_EXTERNAL 1
%define HAVE_MMX_EXTERNAL 1
%define HAVE_MMXEXT_EXTERNAL 1
%define HAVE_SSE_EXTERNAL 1
%define HAVE_SSE2_EXTERNAL 1
%define HAVE_SSE3_EXTERNAL 1
%define HAVE_SSE4_EXTERNAL 1
%define HAVE_SSE42_EXTERNAL 1
%define HAVE_SSSE3_EXTERNAL 1
%define HAVE_XOP_EXTERNAL 1
%define HAVE_I686_EXTERNAL 0
%define HAVE_MIPSFPU_EXTERNAL 0
%define HAVE_MIPS32R2_EXTERNAL 0
%define HAVE_MIPS32R5_EXTERNAL 0
%define HAVE_MIPS64R2_EXTERNAL 0
%define HAVE_MIPS32R6_EXTERNAL 0
%define HAVE_MIPS64R6_EXTERNAL 0
%define HAVE_MIPSDSP_EXTERNAL 0
%define HAVE_MIPSDSPR2_EXTERNAL 0
%define HAVE_MSA_EXTERNAL 0
%define HAVE_LOONGSON2_EXTERNAL 0
%define HAVE_LOONGSON3_EXTERNAL 0
%define HAVE_MMI_EXTERNAL 0
%define HAVE_LSX_EXTERNAL 0
%define HAVE_LASX_EXTERNAL 0
%define HAVE_ARMV5TE_INLINE 0
%define HAVE_ARMV6_INLINE 0
%define HAVE_ARMV6T2_INLINE 0
%define HAVE_ARMV8_INLINE 0
%define HAVE_ARM_CRC_INLINE 0
%define HAVE_DOTPROD_INLINE 0
%define HAVE_I8MM_INLINE 0
%define HAVE_NEON_INLINE 0
%define HAVE_VFP_INLINE 0
%define HAVE_VFPV3_INLINE 0
%define HAVE_SETEND_INLINE 0
%define HAVE_SVE_INLINE 0
%define HAVE_SVE2_INLINE 0
%define HAVE_SME_INLINE 0
%define HAVE_SME_I16I64_INLINE 0
%define HAVE_SME2_INLINE 0
%define HAVE_ALTIVEC_INLINE 0
%define HAVE_DCBZL_INLINE 0
%define HAVE_LDBRX_INLINE 0
%define HAVE_POWER8_INLINE 0
%define HAVE_PPC4XX_INLINE 0
%define HAVE_VEC_XL_INLINE 0
%define HAVE_VSX_INLINE 0
%define HAVE_RV_INLINE 0
%define HAVE_RVV_INLINE 0
%define HAVE_RV_ZICBOP_INLINE 0
%define HAVE_RV_ZVBB_INLINE 0
%define HAVE_SIMD128_INLINE 0
%define HAVE_AESNI_INLINE 0
%define HAVE_CLMUL_INLINE 0
%define HAVE_AMD3DNOW_INLINE 0
%define HAVE_AMD3DNOWEXT_INLINE 0
%define HAVE_AVX_INLINE 0
%define HAVE_AVX2_INLINE 0
%define HAVE_AVX512_INLINE 0
%define HAVE_AVX512ICL_INLINE 0
%define HAVE_FMA3_INLINE 0
%define HAVE_FMA4_INLINE 0
%define HAVE_MMX_INLINE 0
%define HAVE_MMXEXT_INLINE 0
%define HAVE_SSE_INLINE 0
%define HAVE_SSE2_INLINE 0
%define HAVE_SSE3_INLINE 0
%define HAVE_SSE4_INLINE 0
%define HAVE_SSE42_INLINE 0
%define HAVE_SSSE3_INLINE 0
%define HAVE_XOP_INLINE 0
%define HAVE_I686_INLINE 0
%define HAVE_MIPSFPU_INLINE 0
%define HAVE_MIPS32R2_INLINE 0
%define HAVE_MIPS32R5_INLINE 0
%define HAVE_MIPS64R2_INLINE 0
%define HAVE_MIPS32R6_INLINE 0
%define HAVE_MIPS64R6_INLINE 0
%define HAVE_MIPSDSP_INLINE 0
%define HAVE_MIPSDSPR2_INLINE 0
%define HAVE_MSA_INLINE 0
%define HAVE_LOONGSON2_INLINE 0
%define HAVE_LOONGSON3_INLINE 0
%define HAVE_MMI_INLINE 0
%define HAVE_LSX_INLINE 0
%define HAVE_LASX_INLINE 0
%define HAVE_ALIGNED_STACK 1
%define HAVE_FAST_64BIT 1
%define HAVE_FAST_CLZ 1
%define HAVE_FAST_CMOV 1
%define HAVE_FAST_FLOAT16 0
%define HAVE_SIMD_ALIGN_16 1
%define HAVE_SIMD_ALIGN_32 1
%define HAVE_SIMD_ALIGN_64 1
%define HAVE_MEMORYBARRIER 1
%define HAVE_MM_EMPTY 0
%define HAVE_RDTSC 1
%define HAVE_SEM_TIMEDWAIT 0
%define HAVE_INLINE_ASM 0
%define HAVE_SYMVER 0
%define HAVE_X86ASM 1
%define HAVE_BIGENDIAN 0
%define HAVE_FAST_UNALIGNED 1
%define HAVE_ARPA_INET_H 0
%define HAVE_ASM_HWPROBE_H 0
%define HAVE_ASM_TYPES_H 0
%define HAVE_CDIO_PARANOIA_H 0
%define HAVE_CDIO_PARANOIA_PARANOIA_H 0
%define HAVE_CUDA_H 0
%define HAVE_DISPATCH_DISPATCH_H 0
%define HAVE_DIRECT_H 1
%define HAVE_DIRENT_H 0
%define HAVE_DXGIDEBUG_H 1
%define HAVE_DXVA_H 1
%define HAVE_ES2_GL_H 0
%define HAVE_GSM_H 0
%define HAVE_IO_H 1
%define HAVE_LINUX_DMA_BUF_H 0
%define HAVE_LINUX_PERF_EVENT_H 0
%define HAVE_MALLOC_H 1
%define HAVE_POLL_H 0
%define HAVE_PTHREAD_NP_H 0
%define HAVE_SYS_HWPROBE_H 0
%define HAVE_SYS_PARAM_H 0
%define HAVE_SYS_RESOURCE_H 0
%define HAVE_SYS_SELECT_H 0
%define HAVE_SYS_SOUNDCARD_H 0
%define HAVE_SYS_TIME_H 0
%define HAVE_SYS_UN_H 0
%define HAVE_SYS_VIDEOIO_H 0
%define HAVE_TERMIOS_H 0
%define HAVE_UDPLITE_H 0
%define HAVE_UNISTD_H 0
%define HAVE_VALGRIND_VALGRIND_H 0
%define HAVE_WINDOWS_H 1
%define HAVE_WINSOCK2_H 1
%define HAVE_INTRINSICS_NEON 0
%define HAVE_INTRINSICS_SSE2 1
%define HAVE_ATANF 1
%define HAVE_ATAN2F 1
%define HAVE_CBRT 1
%define HAVE_CBRTF 1
%define HAVE_COPYSIGN 1
%define HAVE_COSF 1
%define HAVE_ERF 1
%define HAVE_EXP2 1
%define HAVE_EXP2F 1
%define HAVE_EXPF 1
%define HAVE_HYPOT 1
%define HAVE_ISFINITE 1
%define HAVE_ISINF 1
%define HAVE_ISNAN 1
%define HAVE_LDEXPF 1
%define HAVE_LLRINT 1
%define HAVE_LLRINTF 1
%define HAVE_LOG2 1
%define HAVE_LOG2F 1
%define HAVE_LOG10F 1
%define HAVE_LRINT 1
%define HAVE_LRINTF 1
%define HAVE_POWF 1
%define HAVE_RINT 1
%define HAVE_ROUND 1
%define HAVE_ROUNDF 1
%define HAVE_SINF 1
%define HAVE_TRUNC 1
%define HAVE_TRUNCF 1
%define HAVE_DOS_PATHS 1
%define HAVE_LIBC_MSVCRT 1
%define HAVE_MMAL_PARAMETER_VIDEO_MAX_NUM_CALLBACKS 0
%define HAVE_SECTION_DATA_REL_RO 0
%define HAVE_THREADS 1
%define HAVE_UWP 0
%define HAVE_WINRT 0
%define HAVE_ACCESS 1
%define HAVE_ALIGNED_MALLOC 1
%define HAVE_ARC4RANDOM_BUF 0
%define HAVE_CLOCK_GETTIME 0
%define HAVE_CLOSESOCKET 1
%define HAVE_COMMANDLINETOARGVW 1
%define HAVE_ELF_AUX_INFO 0
%define HAVE_FCNTL 0
%define HAVE_GETADDRINFO 1
%define HAVE_GETAUXVAL 0
%define HAVE_GETENV 1
%define HAVE_GETHRTIME 0
%define HAVE_GETOPT 0
%define HAVE_GETMODULEHANDLE 1
%define HAVE_GETPROCESSAFFINITYMASK 1
%define HAVE_GETPROCESSMEMORYINFO 1
%define HAVE_GETPROCESSTIMES 1
%define HAVE_GETRUSAGE 0
%define HAVE_GETSTDHANDLE 1
%define HAVE_GETSYSTEMTIMEASFILETIME 1
%define HAVE_GETTIMEOFDAY 0
%define HAVE_GLOB 0
%define HAVE_GLXGETPROCADDRESS 0
%define HAVE_GMTIME_R 0
%define HAVE_INET_ATON 0
%define HAVE_ISATTY 1
%define HAVE_KBHIT 1
%define HAVE_LOCALTIME_R 0
%define HAVE_LSTAT 0
%define HAVE_LZO1X_999_COMPRESS 0
%define HAVE_MACH_ABSOLUTE_TIME 0
%define HAVE_MAPVIEWOFFILE 1
%define HAVE_MEMALIGN 0
%define HAVE_MKSTEMP 0
%define HAVE_MMAP 0
%define HAVE_MPROTECT 0
%define HAVE_NANOSLEEP 0
%define HAVE_PEEKNAMEDPIPE 1
%define HAVE_POSIX_MEMALIGN 0
%define HAVE_PRCTL 0
%define HAVE_PTHREAD_CANCEL 0
%define HAVE_PTHREAD_SET_NAME_NP 0
%define HAVE_PTHREAD_SETNAME_NP 0
%define HAVE_SCHED_GETAFFINITY 0
%define HAVE_SECITEMIMPORT 0
%define HAVE_SETCONSOLETEXTATTRIBUTE 1
%define HAVE_SETCONSOLECTRLHANDLER 1
%define HAVE_SETDLLDIRECTORY 1
%define HAVE_SETMODE 1
%define HAVE_SETRLIMIT 0
%define HAVE_SLEEP 1
%define HAVE_STRERROR_R 0
%define HAVE_SYSCONF 0
%define HAVE_SYSCTL 0
%define HAVE_SYSCTLBYNAME 0
%define HAVE_TEMPNAM 1
%define HAVE_USLEEP 0
%define HAVE_UTGETOSTYPEFROMSTRING 0
%define HAVE_VIRTUALALLOC 1
%define HAVE_WGLGETPROCADDRESS 0
%define HAVE_BCRYPT 1
%define HAVE_VAAPI_DRM 0
%define HAVE_VAAPI_X11 0
%define HAVE_VAAPI_WIN32 0
%define HAVE_VDPAU_X11 0
%define HAVE_PTHREADS 0
%define HAVE_OS2THREADS 0
%define HAVE_W32THREADS 1
%define HAVE_AS_ARCH_DIRECTIVE 0
%define HAVE_AS_ARCHEXT_CRC_DIRECTIVE 0
%define HAVE_AS_ARCHEXT_DOTPROD_DIRECTIVE 0
%define HAVE_AS_ARCHEXT_I8MM_DIRECTIVE 0
%define HAVE_AS_ARCHEXT_SVE_DIRECTIVE 0
%define HAVE_AS_ARCHEXT_SVE2_DIRECTIVE 0
%define HAVE_AS_ARCHEXT_SME_DIRECTIVE 0
%define HAVE_AS_ARCHEXT_SME_I16I64_DIRECTIVE 0
%define HAVE_AS_ARCHEXT_SME2_DIRECTIVE 0
%define HAVE_AS_DN_DIRECTIVE 0
%define HAVE_AS_FPU_DIRECTIVE 0
%define HAVE_AS_FUNC 0
%define HAVE_AS_OBJECT_ARCH 0
%define HAVE_ASM_MOD_Q 0
%define HAVE_BLOCKS_EXTENSION 0
%define HAVE_EBP_AVAILABLE 0
%define HAVE_EBX_AVAILABLE 0
%define HAVE_GNU_AS 0
%define HAVE_GNU_WINDRES 1
%define HAVE_IBM_ASM 0
%define HAVE_INLINE_ASM_DIRECT_SYMBOL_REFS 0
%define HAVE_INLINE_ASM_LABELS 0
%define HAVE_INLINE_ASM_NONLOCAL_LABELS 0
%define HAVE_PRAGMA_DEPRECATED 1
%define HAVE_RSYNC_CONTIMEOUT 0
%define HAVE_SYMVER_ASM_LABEL 0
%define HAVE_SYMVER_GNU_ASM 0
%define HAVE_VFP_ARGS 0
%define HAVE_XFORM_ASM 0
%define HAVE_XMM_CLOBBERS 0
%define HAVE_DPI_AWARENESS_CONTEXT 1
%define HAVE_IDXGIOUTPUT5 1
%define HAVE___X_ABI_CWINDOWS_CGRAPHICS_CCAPTURE_CIGRAPHICSCAPTURESESSION5 1
%define HAVE_IDIRECT3DDXGIINTERFACEACCESS 0
%define HAVE_KCMVIDEOCODECTYPE_HEVC 0
%define HAVE_KCMVIDEOCODECTYPE_HEVCWITHALPHA 0
%define HAVE_KCMVIDEOCODECTYPE_VP9 0
%define HAVE_KCMVIDEOCODECTYPE_AV1 0
%define HAVE_KCVPIXELFORMATTYPE_420YPCBCR10BIPLANARVIDEORANGE 0
%define HAVE_KCVPIXELFORMATTYPE_422YPCBCR8BIPLANARVIDEORANGE 0
%define HAVE_KCVPIXELFORMATTYPE_422YPCBCR10BIPLANARVIDEORANGE 0
%define HAVE_KCVPIXELFORMATTYPE_422YPCBCR16BIPLANARVIDEORANGE 0
%define HAVE_KCVPIXELFORMATTYPE_444YPCBCR8BIPLANARVIDEORANGE 0
%define HAVE_KCVPIXELFORMATTYPE_444YPCBCR10BIPLANARVIDEORANGE 0
%define HAVE_KCVPIXELFORMATTYPE_444YPCBCR16BIPLANARVIDEORANGE 0
%define HAVE_KCVPIXELFORMATTYPE_422YPCBCR8_YUVS 0
%define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_SMPTE_ST_2084_PQ 0
%define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_ITU_R_2100_HLG 0
%define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_LINEAR 0
%define HAVE_KCVIMAGEBUFFERYCBCRMATRIX_ITU_R_2020 0
%define HAVE_KCVIMAGEBUFFERCOLORPRIMARIES_ITU_R_2020 0
%define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_ITU_R_2020 0
%define HAVE_KCVIMAGEBUFFERTRANSFERFUNCTION_SMPTE_ST_428_1 0
%define HAVE_KVTQPMODULATIONLEVEL_DEFAULT 0
%define HAVE_SECPKGCONTEXT_KEYINGMATERIALINFO 1
%define HAVE_SOCKLEN_T 1
%define HAVE_STRUCT_ADDRINFO 1
%define HAVE_STRUCT_GROUP_SOURCE_REQ 1
%define HAVE_STRUCT_IP_MREQ_SOURCE 1
%define HAVE_STRUCT_IPV6_MREQ 1
%define HAVE_STRUCT_MSGHDR_MSG_FLAGS 0
%define HAVE_STRUCT_POLLFD 1
%define HAVE_STRUCT_RUSAGE_RU_MAXRSS 0
%define HAVE_STRUCT_SCTP_EVENT_SUBSCRIBE 0
%define HAVE_STRUCT_SOCKADDR_IN6 1
%define HAVE_STRUCT_SOCKADDR_SA_LEN 0
%define HAVE_STRUCT_SOCKADDR_STORAGE 1
%define HAVE_STRUCT_STAT_ST_MTIM_TV_NSEC 0
%define HAVE_STRUCT_V4L2_FRMIVALENUM_DISCRETE 0
%define HAVE_STRUCT_MFXCONFIGINTERFACE 0
%define HAVE_GZIP 1
%define HAVE_IOCTL_POSIX 0
%define HAVE_LIBDRM_GETFB2 0
%define HAVE_MAKEINFO 0
%define HAVE_MAKEINFO_HTML 0
%define HAVE_OPENCL_D3D11 0
%define HAVE_OPENCL_DRM_ARM 0
%define HAVE_OPENCL_DRM_BEIGNET 0
%define HAVE_OPENCL_DXVA2 0
%define HAVE_OPENCL_VAAPI_BEIGNET 0
%define HAVE_OPENCL_VAAPI_INTEL_MEDIA 0
%define HAVE_OPENCL_VIDEOTOOLBOX 0
%define HAVE_PERL 1
%define HAVE_POD2MAN 1
%define HAVE_TEXI2HTML 0
%define HAVE_XMLLINT 1
%define HAVE_ZLIB_GZIP 0
%define HAVE_OPENVINO2 0
%define CONFIG_DOC 0
%define CONFIG_HTMLPAGES 0
%define CONFIG_MANPAGES 1
%define CONFIG_PODPAGES 1
%define CONFIG_TXTPAGES 0
%define CONFIG_AVIO_HTTP_SERVE_FILES_EXAMPLE 1
%define CONFIG_AVIO_LIST_DIR_EXAMPLE 1
%define CONFIG_AVIO_READ_CALLBACK_EXAMPLE 1
%define CONFIG_DECODE_AUDIO_EXAMPLE 1
%define CONFIG_DECODE_FILTER_AUDIO_EXAMPLE 1
%define CONFIG_DECODE_FILTER_VIDEO_EXAMPLE 1
%define CONFIG_DECODE_VIDEO_EXAMPLE 1
%define CONFIG_DEMUX_DECODE_EXAMPLE 1
%define CONFIG_ENCODE_AUDIO_EXAMPLE 1
%define CONFIG_ENCODE_VIDEO_EXAMPLE 1
%define CONFIG_EXTRACT_MVS_EXAMPLE 1
%define CONFIG_FILTER_AUDIO_EXAMPLE 1
%define CONFIG_HW_DECODE_EXAMPLE 1
%define CONFIG_MUX_EXAMPLE 1
%define CONFIG_QSV_DECODE_EXAMPLE 0
%define CONFIG_REMUX_EXAMPLE 1
%define CONFIG_RESAMPLE_AUDIO_EXAMPLE 1
%define CONFIG_SCALE_VIDEO_EXAMPLE 1
%define CONFIG_SHOW_METADATA_EXAMPLE 1
%define CONFIG_TRANSCODE_AAC_EXAMPLE 1
%define CONFIG_TRANSCODE_EXAMPLE 1
%define CONFIG_VAAPI_ENCODE_EXAMPLE 0
%define CONFIG_VAAPI_TRANSCODE_EXAMPLE 0
%define CONFIG_QSV_TRANSCODE_EXAMPLE 0
%define CONFIG_AVISYNTH 0
%define CONFIG_FREI0R 0
%define CONFIG_LIBCDIO 0
%define CONFIG_LIBDAVS2 0
%define CONFIG_LIBDVDNAV 0
%define CONFIG_LIBDVDREAD 0
%define CONFIG_LIBRUBBERBAND 0
%define CONFIG_LIBVIDSTAB 0
%define CONFIG_LIBX264 0
%define CONFIG_LIBX265 0
%define CONFIG_LIBXAVS 0
%define CONFIG_LIBXAVS2 0
%define CONFIG_LIBXVID 0
%define CONFIG_DECKLINK 0
%define CONFIG_LIBFDK_AAC 0
%define CONFIG_LIBMPEGHDEC 0
%define CONFIG_GMP 0
%define CONFIG_LIBARIBB24 0
%define CONFIG_LIBLENSFUN 0
%define CONFIG_LIBOPENCORE_AMRNB 0
%define CONFIG_LIBOPENCORE_AMRWB 0
%define CONFIG_LIBVO_AMRWBENC 0
%define CONFIG_MBEDTLS 0
%define CONFIG_RKMPP 0
%define CONFIG_LIBSMBCLIENT 0
%define CONFIG_CAIRO 0
%define CONFIG_CHROMAPRINT 0
%define CONFIG_GCRYPT 0
%define CONFIG_GNUTLS 0
%define CONFIG_JNI 0
%define CONFIG_LADSPA 0
%define CONFIG_LCMS2 0
%define CONFIG_LIBAOM 0
%define CONFIG_LIBARIBCAPTION 0
%define CONFIG_LIBASS 0
%define CONFIG_LIBBLURAY 0
%define CONFIG_LIBBS2B 0
%define CONFIG_LIBCACA 0
%define CONFIG_LIBCELT 0
%define CONFIG_LIBCODEC2 0
%define CONFIG_LIBDAV1D 0
%define CONFIG_LIBDC1394 0
%define CONFIG_LIBFLITE 0
%define CONFIG_LIBFONTCONFIG 0
%define CONFIG_LIBFREETYPE 0
%define CONFIG_LIBFRIBIDI 0
%define CONFIG_LIBHARFBUZZ 0
%define CONFIG_LIBGLSLANG 0
%define CONFIG_LIBGME 0
%define CONFIG_LIBGSM 0
%define CONFIG_LIBIEC61883 0
%define CONFIG_LIBILBC 0
%define CONFIG_LIBJACK 0
%define CONFIG_LIBJXL 0
%define CONFIG_LIBKLVANC 0
%define CONFIG_LIBKVAZAAR 0
%define CONFIG_LIBLC3 0
%define CONFIG_LIBLCEVC_DEC 0
%define CONFIG_LIBMODPLUG 0
%define CONFIG_LIBMP3LAME 0
%define CONFIG_LIBMYSOFA 0
%define CONFIG_LIBOAPV 0
%define CONFIG_LIBOPENCV 0
%define CONFIG_LIBOPENCOLORIO 0
%define CONFIG_LIBOPENH264 0
%define CONFIG_LIBOPENJPEG 0
%define CONFIG_LIBOPENMPT 0
%define CONFIG_LIBOPENVINO 0
%define CONFIG_LIBOPUS 0
%define CONFIG_LIBPLACEBO 0
%define CONFIG_LIBPULSE 0
%define CONFIG_LIBQRENCODE 0
%define CONFIG_LIBQUIRC 0
%define CONFIG_LIBRABBITMQ 0
%define CONFIG_LIBRAV1E 0
%define CONFIG_LIBRIST 0
%define CONFIG_LIBRSVG 0
%define CONFIG_LIBRTMP 0
%define CONFIG_LIBSHADERC 0
%define CONFIG_LIBSHINE 0
%define CONFIG_LIBSMBCLIENT 0
%define CONFIG_LIBSNAPPY 0
%define CONFIG_LIBSOXR 0
%define CONFIG_LIBSPEEX 0
%define CONFIG_LIBSRT 0
%define CONFIG_LIBSSH 0
%define CONFIG_LIBSVTAV1 0
%define CONFIG_LIBSVTJPEGXS 0
%define CONFIG_LIBTENSORFLOW 0
%define CONFIG_LIBTESSERACT 0
%define CONFIG_LIBTHEORA 0
%define CONFIG_LIBTLS 0
%define CONFIG_LIBTORCH 0
%define CONFIG_LIBTWOLAME 0
%define CONFIG_LIBUAVS3D 0
%define CONFIG_LIBV4L2 0
%define CONFIG_LIBVMAF 0
%define CONFIG_LIBVORBIS 0
%define CONFIG_LIBVPX 0
%define CONFIG_LIBVVENC 0
%define CONFIG_LIBWEBP 0
%define CONFIG_LIBXEVD 0
%define CONFIG_LIBXEVDB 0
%define CONFIG_LIBXEVE 0
%define CONFIG_LIBXEVEB 0
%define CONFIG_LIBXML2 0
%define CONFIG_LIBZIMG 0
%define CONFIG_LIBZMQ 0
%define CONFIG_LIBZVBI 0
%define CONFIG_LV2 0
%define CONFIG_MEDIACODEC 0
%define CONFIG_OHCODEC 0
%define CONFIG_OPENAL 0
%define CONFIG_OPENGL 0
%define CONFIG_OPENSSL 0
%define CONFIG_POCKETSPHINX 0
%define CONFIG_VAPOURSYNTH 0
%define CONFIG_VULKAN_STATIC 0
%define CONFIG_WHISPER 0
%define CONFIG_ALSA 0
%define CONFIG_APPKIT 0
%define CONFIG_AVFOUNDATION 0
%define CONFIG_BZLIB 0
%define CONFIG_COREIMAGE 0
%define CONFIG_ICONV 0
%define CONFIG_LIBXCB 0
%define CONFIG_LIBXCB_SHM 0
%define CONFIG_LIBXCB_SHAPE 0
%define CONFIG_LIBXCB_XFIXES 0
%define CONFIG_LZMA 0
%define CONFIG_MEDIAFOUNDATION 0
%define CONFIG_METAL 0
%define CONFIG_SCHANNEL 0
%define CONFIG_SDL2 0
%define CONFIG_SECURETRANSPORT 0
%define CONFIG_SNDIO 0
%define CONFIG_XLIB 0
%define CONFIG_ZLIB 0
%define CONFIG_CUDA_NVCC 0
%define CONFIG_CUDA_SDK 0
%define CONFIG_LIBNPP 0
%define CONFIG_LIBMFX 0
%define CONFIG_LIBVPL 0
%define CONFIG_MMAL 0
%define CONFIG_OMX 0
%define CONFIG_OPENCL 0
%define CONFIG_AMF 0
%define CONFIG_AUDIOTOOLBOX 0
%define CONFIG_CUDA 0
%define CONFIG_CUDA_LLVM 0
%define CONFIG_CUVID 0
%define CONFIG_D3D11VA 0
%define CONFIG_D3D12VA 0
%define CONFIG_DXVA2 0
%define CONFIG_FFNVCODEC 0
%define CONFIG_LIBDRM 0
%define CONFIG_NVDEC 0
%define CONFIG_NVENC 0
%define CONFIG_VAAPI 0
%define CONFIG_VDPAU 0
%define CONFIG_VIDEOTOOLBOX 0
%define CONFIG_VULKAN 0
%define CONFIG_V4L2_M2M 0
%define CONFIG_FTRAPV 0
%define CONFIG_GRAY 0
%define CONFIG_HARDCODED_TABLES 0
%define CONFIG_OMX_RPI 0
%define CONFIG_RUNTIME_CPUDETECT 1
%define CONFIG_SAFE_BITSTREAM_READER 1
%define CONFIG_SHARED 0
%define CONFIG_SMALL 0
%define CONFIG_STATIC 1
%define CONFIG_SWSCALE_ALPHA 1
%define CONFIG_UNSTABLE 1
%define CONFIG_GPL 0
%define CONFIG_NONFREE 0
%define CONFIG_VERSION3 0
%define CONFIG_AVDEVICE 1
%define CONFIG_AVFILTER 1
%define CONFIG_SWSCALE 1
%define CONFIG_AVFORMAT 1
%define CONFIG_AVCODEC 1
%define CONFIG_SWRESAMPLE 1
%define CONFIG_AVUTIL 1
%define CONFIG_FFPLAY 0
%define CONFIG_FFPROBE 0
%define CONFIG_FFMPEG 0
%define CONFIG_DWT 1
%define CONFIG_ERROR_RESILIENCE 1
%define CONFIG_FAAN 1
%define CONFIG_FAST_UNALIGNED 1
%define CONFIG_IAMF 1
%define CONFIG_LSP 1
%define CONFIG_PIXELUTILS 1
%define CONFIG_NETWORK 1
%define CONFIG_AUTODETECT 0
%define CONFIG_FONTCONFIG 0
%define CONFIG_LARGE_TESTS 1
%define CONFIG_LINUX_PERF 0
%define CONFIG_MACOS_KPERF 0
%define CONFIG_MEMORY_POISONING 0
%define CONFIG_NEON_CLOBBER_TEST 0
%define CONFIG_OSSFUZZ 0
%define CONFIG_PIC 0
%define CONFIG_SHADER_COMPRESSION 0
%define CONFIG_RESOURCE_COMPRESSION 0
%define CONFIG_THUMB 0
%define CONFIG_VALGRIND_BACKTRACE 0
%define CONFIG_XMM_CLOBBER_TEST 0
%define CONFIG_BSFS 1
%define CONFIG_DECODERS 1
%define CONFIG_ENCODERS 1
%define CONFIG_HWACCELS 0
%define CONFIG_PARSERS 1
%define CONFIG_INDEVS 1
%define CONFIG_OUTDEVS 0
%define CONFIG_FILTERS 1
%define CONFIG_DEMUXERS 1
%define CONFIG_MUXERS 1
%define CONFIG_PROTOCOLS 1
%define CONFIG_AANDCTTABLES 1
%define CONFIG_AC3DSP 1
%define CONFIG_ADTS_HEADER 1
%define CONFIG_ATSC_A53 1
%define CONFIG_AUDIO_FRAME_QUEUE 1
%define CONFIG_AUDIODSP 1
%define CONFIG_BLOCKDSP 1
%define CONFIG_BSWAPDSP 1
%define CONFIG_CABAC 1
%define CONFIG_CBS 1
%define CONFIG_CBS_APV 1
%define CONFIG_CBS_AV1 1
%define CONFIG_CBS_H264 1
%define CONFIG_CBS_H265 1
%define CONFIG_CBS_H266 1
%define CONFIG_CBS_JPEG 0
%define CONFIG_CBS_LCEVC 1
%define CONFIG_CBS_MPEG2 1
%define CONFIG_CBS_VP8 1
%define CONFIG_CBS_VP9 1
%define CONFIG_CELP_MATH 1
%define CONFIG_D3D12_INTRA_REFRESH 1
%define CONFIG_D3D12_MOTION_ESTIMATOR 1
%define CONFIG_D3D12_VIDEO_PROCESS_REFERENCE_INFO 1
%define CONFIG_D3D12VA_ENCODE 0
%define CONFIG_D3D12VA_ME_PRECISION_EIGHTH_PIXEL 1
%define CONFIG_DEFLATE_WRAPPER 0
%define CONFIG_DIRAC_PARSE 1
%define CONFIG_DNN 0
%define CONFIG_DOVI_RPUDEC 1
%define CONFIG_DOVI_RPUENC 1
%define CONFIG_DVPROFILE 1
%define CONFIG_EVCPARSE 1
%define CONFIG_FAANDCT 1
%define CONFIG_FAANIDCT 1
%define CONFIG_FDCTDSP 1
%define CONFIG_FMTCONVERT 1
%define CONFIG_FRAME_THREAD_ENCODER 1
%define CONFIG_G722DSP 1
%define CONFIG_GOLOMB 1
%define CONFIG_GPLV3 0
%define CONFIG_H263DSP 1
%define CONFIG_H264CHROMA 1
%define CONFIG_H264DSP 1
%define CONFIG_H264PARSE 1
%define CONFIG_H264PRED 1
%define CONFIG_H264QPEL 1
%define CONFIG_H264_SEI 1
%define CONFIG_HEVCPARSE 1
%define CONFIG_HEVC_SEI 1
%define CONFIG_HPELDSP 1
%define CONFIG_HUFFMAN 1
%define CONFIG_HUFFYUVDSP 1
%define CONFIG_HUFFYUVENCDSP 1
%define CONFIG_IAMFDEC 1
%define CONFIG_IAMFENC 1
%define CONFIG_IDCTDSP 1
%define CONFIG_INFLATE_WRAPPER 0
%define CONFIG_INTRAX8 1
%define CONFIG_ISO_MEDIA 1
%define CONFIG_ISO_WRITER 1
%define CONFIG_IVIDSP 1
%define CONFIG_JPEGTABLES 1
%define CONFIG_LGPLV3 0
%define CONFIG_LIBX262 0
%define CONFIG_LIBX264_HDR10 0
%define CONFIG_LLAUDDSP 1
%define CONFIG_LLVIDDSP 1
%define CONFIG_LLVIDENCDSP 1
%define CONFIG_LPC 1
%define CONFIG_LZF 1
%define CONFIG_ME_CMP 1
%define CONFIG_MPEG_ER 1
%define CONFIG_MPEGAUDIO 1
%define CONFIG_MPEGAUDIODSP 1
%define CONFIG_MPEGAUDIOHEADER 1
%define CONFIG_MPEG4AUDIO 1
%define CONFIG_MPEGVIDEO 1
%define CONFIG_MPEGVIDEODEC 1
%define CONFIG_MPEGVIDEOENC 1
%define CONFIG_MPEGVIDEOENCDSP 1
%define CONFIG_MSMPEG4DEC 1
%define CONFIG_MSMPEG4ENC 1
%define CONFIG_MSS34DSP 1
%define CONFIG_PIXBLOCKDSP 1
%define CONFIG_QPELDSP 1
%define CONFIG_QSV 0
%define CONFIG_QSVDEC 0
%define CONFIG_QSVENC 0
%define CONFIG_QSVVPP 0
%define CONFIG_RANGECODER 1
%define CONFIG_RIFFDEC 1
%define CONFIG_RIFFENC 1
%define CONFIG_RTPDEC 1
%define CONFIG_RTPENC_CHAIN 1
%define CONFIG_RV34DSP 1
%define CONFIG_SCENE_SAD 1
%define CONFIG_SINEWIN 1
%define CONFIG_SMPTE_436M 1
%define CONFIG_SNAPPY 1
%define CONFIG_SRTP 1
%define CONFIG_STARTCODE 1
%define CONFIG_TEXTUREDSP 1
%define CONFIG_TEXTUREDSPENC 1
%define CONFIG_TPELDSP 1
%define CONFIG_VAAPI_1 0
%define CONFIG_VAAPI_ENCODE 0
%define CONFIG_VULKAN_1_4 0
%define CONFIG_VC1DSP 1
%define CONFIG_VIDEODSP 1
%define CONFIG_VP3DSP 1
%define CONFIG_VP8DSP 1
%define CONFIG_VULKAN_ENCODE 0
%define CONFIG_VVC_SEI 1
%define CONFIG_WMA_FREQS 1
%define CONFIG_WMV2DSP 1
]==],
        ["mcpp_generated/config_components.asm"] = [==[
; Automatically generated by configure - do not modify!
%define CONFIG_AAC_ADTSTOASC_BSF 1
%define CONFIG_AHX_TO_MP2_BSF 0
%define CONFIG_APV_METADATA_BSF 1
%define CONFIG_AV1_FRAME_MERGE_BSF 1
%define CONFIG_AV1_FRAME_SPLIT_BSF 1
%define CONFIG_AV1_METADATA_BSF 1
%define CONFIG_CHOMP_BSF 1
%define CONFIG_DUMP_EXTRADATA_BSF 1
%define CONFIG_DCA_CORE_BSF 1
%define CONFIG_DOVI_RPU_BSF 1
%define CONFIG_DTS2PTS_BSF 1
%define CONFIG_DV_ERROR_MARKER_BSF 1
%define CONFIG_EAC3_CORE_BSF 1
%define CONFIG_EIA608_TO_SMPTE436M_BSF 1
%define CONFIG_EVC_FRAME_MERGE_BSF 1
%define CONFIG_EXTRACT_EXTRADATA_BSF 1
%define CONFIG_FILTER_UNITS_BSF 1
%define CONFIG_H264_METADATA_BSF 1
%define CONFIG_H264_MP4TOANNEXB_BSF 1
%define CONFIG_H264_REDUNDANT_PPS_BSF 1
%define CONFIG_HAPQA_EXTRACT_BSF 1
%define CONFIG_HEVC_METADATA_BSF 1
%define CONFIG_HEVC_MP4TOANNEXB_BSF 1
%define CONFIG_IMX_DUMP_HEADER_BSF 1
%define CONFIG_LCEVC_METADATA_BSF 1
%define CONFIG_MEDIA100_TO_MJPEGB_BSF 1
%define CONFIG_MJPEG2JPEG_BSF 1
%define CONFIG_MJPEGA_DUMP_HEADER_BSF 1
%define CONFIG_MPEG2_METADATA_BSF 1
%define CONFIG_MPEG4_UNPACK_BFRAMES_BSF 1
%define CONFIG_MOV2TEXTSUB_BSF 1
%define CONFIG_NOISE_BSF 1
%define CONFIG_NULL_BSF 1
%define CONFIG_OPUS_METADATA_BSF 1
%define CONFIG_PCM_RECHUNK_BSF 1
%define CONFIG_PGS_FRAME_MERGE_BSF 1
%define CONFIG_PRORES_METADATA_BSF 1
%define CONFIG_REMOVE_EXTRADATA_BSF 1
%define CONFIG_SETTS_BSF 1
%define CONFIG_SHOWINFO_BSF 1
%define CONFIG_SMPTE436M_TO_EIA608_BSF 1
%define CONFIG_TEXT2MOVSUB_BSF 1
%define CONFIG_TRACE_HEADERS_BSF 1
%define CONFIG_TRUEHD_CORE_BSF 1
%define CONFIG_VP9_METADATA_BSF 1
%define CONFIG_VP9_RAW_REORDER_BSF 1
%define CONFIG_VP9_SUPERFRAME_BSF 1
%define CONFIG_VP9_SUPERFRAME_SPLIT_BSF 1
%define CONFIG_VVC_METADATA_BSF 1
%define CONFIG_VVC_MP4TOANNEXB_BSF 1
%define CONFIG_AASC_DECODER 1
%define CONFIG_AIC_DECODER 1
%define CONFIG_ALIAS_PIX_DECODER 1
%define CONFIG_AGM_DECODER 1
%define CONFIG_AMV_DECODER 1
%define CONFIG_ANM_DECODER 1
%define CONFIG_ANSI_DECODER 1
%define CONFIG_APNG_DECODER 0
%define CONFIG_APV_DECODER 1
%define CONFIG_ARBC_DECODER 1
%define CONFIG_ARGO_DECODER 1
%define CONFIG_ASV1_DECODER 1
%define CONFIG_ASV2_DECODER 1
%define CONFIG_AURA_DECODER 1
%define CONFIG_AURA2_DECODER 1
%define CONFIG_AVRP_DECODER 1
%define CONFIG_AVRN_DECODER 1
%define CONFIG_AVS_DECODER 1
%define CONFIG_AVUI_DECODER 1
%define CONFIG_BETHSOFTVID_DECODER 1
%define CONFIG_BFI_DECODER 1
%define CONFIG_BINK_DECODER 1
%define CONFIG_BITPACKED_DECODER 1
%define CONFIG_BMP_DECODER 1
%define CONFIG_BMV_VIDEO_DECODER 1
%define CONFIG_BRENDER_PIX_DECODER 1
%define CONFIG_C93_DECODER 1
%define CONFIG_CAVS_DECODER 1
%define CONFIG_CDGRAPHICS_DECODER 1
%define CONFIG_CDTOONS_DECODER 1
%define CONFIG_CDXL_DECODER 1
%define CONFIG_CFHD_DECODER 1
%define CONFIG_CINEPAK_DECODER 1
%define CONFIG_CLEARVIDEO_DECODER 1
%define CONFIG_CLJR_DECODER 1
%define CONFIG_CLLC_DECODER 1
%define CONFIG_COMFORTNOISE_DECODER 1
%define CONFIG_CPIA_DECODER 1
%define CONFIG_CRI_DECODER 1
%define CONFIG_CSCD_DECODER 1
%define CONFIG_CYUV_DECODER 1
%define CONFIG_DDS_DECODER 1
%define CONFIG_DFA_DECODER 1
%define CONFIG_DIRAC_DECODER 1
%define CONFIG_DNXHD_DECODER 1
%define CONFIG_DPX_DECODER 1
%define CONFIG_DSICINVIDEO_DECODER 1
%define CONFIG_DVAUDIO_DECODER 1
%define CONFIG_DVVIDEO_DECODER 1
%define CONFIG_DXA_DECODER 0
%define CONFIG_DXTORY_DECODER 1
%define CONFIG_DXV_DECODER 1
%define CONFIG_EACMV_DECODER 1
%define CONFIG_EAMAD_DECODER 1
%define CONFIG_EATGQ_DECODER 1
%define CONFIG_EATGV_DECODER 1
%define CONFIG_EATQI_DECODER 1
%define CONFIG_EIGHTBPS_DECODER 1
%define CONFIG_EIGHTSVX_EXP_DECODER 1
%define CONFIG_EIGHTSVX_FIB_DECODER 1
%define CONFIG_ESCAPE124_DECODER 1
%define CONFIG_ESCAPE130_DECODER 1
%define CONFIG_EXR_DECODER 0
%define CONFIG_FFV1_DECODER 1
%define CONFIG_FFVHUFF_DECODER 1
%define CONFIG_FIC_DECODER 1
%define CONFIG_FITS_DECODER 1
%define CONFIG_FLASHSV_DECODER 0
%define CONFIG_FLASHSV2_DECODER 0
%define CONFIG_FLIC_DECODER 1
%define CONFIG_FLV_DECODER 1
%define CONFIG_FMVC_DECODER 1
%define CONFIG_FOURXM_DECODER 1
%define CONFIG_FRAPS_DECODER 1
%define CONFIG_FRWU_DECODER 1
%define CONFIG_G2M_DECODER 0
%define CONFIG_GDV_DECODER 1
%define CONFIG_GEM_DECODER 1
%define CONFIG_GIF_DECODER 1
%define CONFIG_H261_DECODER 1
%define CONFIG_H263_DECODER 1
%define CONFIG_H263I_DECODER 1
%define CONFIG_H263P_DECODER 1
%define CONFIG_H263_V4L2M2M_DECODER 0
%define CONFIG_H264_DECODER 1
%define CONFIG_H264_V4L2M2M_DECODER 0
%define CONFIG_H264_MEDIACODEC_DECODER 0
%define CONFIG_H264_MMAL_DECODER 0
%define CONFIG_H264_QSV_DECODER 0
%define CONFIG_H264_RKMPP_DECODER 0
%define CONFIG_HAP_DECODER 1
%define CONFIG_HEVC_DECODER 1
%define CONFIG_HEVC_QSV_DECODER 0
%define CONFIG_HEVC_RKMPP_DECODER 0
%define CONFIG_HEVC_V4L2M2M_DECODER 0
%define CONFIG_HNM4_VIDEO_DECODER 1
%define CONFIG_HQ_HQA_DECODER 1
%define CONFIG_HQX_DECODER 1
%define CONFIG_HUFFYUV_DECODER 1
%define CONFIG_HYMT_DECODER 1
%define CONFIG_IDCIN_DECODER 1
%define CONFIG_IFF_ILBM_DECODER 1
%define CONFIG_IMM4_DECODER 1
%define CONFIG_IMM5_DECODER 1
%define CONFIG_INDEO2_DECODER 1
%define CONFIG_INDEO3_DECODER 1
%define CONFIG_INDEO4_DECODER 1
%define CONFIG_INDEO5_DECODER 1
%define CONFIG_INTERPLAY_VIDEO_DECODER 1
%define CONFIG_IPU_DECODER 1
%define CONFIG_JPEG2000_DECODER 1
%define CONFIG_JPEGLS_DECODER 1
%define CONFIG_JV_DECODER 1
%define CONFIG_KGV1_DECODER 1
%define CONFIG_KMVC_DECODER 1
%define CONFIG_LAGARITH_DECODER 1
%define CONFIG_LEAD_DECODER 1
%define CONFIG_LOCO_DECODER 1
%define CONFIG_LSCR_DECODER 0
%define CONFIG_M101_DECODER 1
%define CONFIG_MAGICYUV_DECODER 1
%define CONFIG_MDEC_DECODER 1
%define CONFIG_MEDIA100_DECODER 1
%define CONFIG_MIMIC_DECODER 1
%define CONFIG_MJPEG_DECODER 1
%define CONFIG_MJPEGB_DECODER 1
%define CONFIG_MMVIDEO_DECODER 1
%define CONFIG_MOBICLIP_DECODER 1
%define CONFIG_MOTIONPIXELS_DECODER 1
%define CONFIG_MPEG1VIDEO_DECODER 1
%define CONFIG_MPEG2VIDEO_DECODER 1
%define CONFIG_MPEG4_DECODER 1
%define CONFIG_MPEG4_V4L2M2M_DECODER 0
%define CONFIG_MPEG4_MMAL_DECODER 0
%define CONFIG_MPEGVIDEO_DECODER 1
%define CONFIG_MPEG1_V4L2M2M_DECODER 0
%define CONFIG_MPEG2_MMAL_DECODER 0
%define CONFIG_MPEG2_V4L2M2M_DECODER 0
%define CONFIG_MPEG2_QSV_DECODER 0
%define CONFIG_MPEG2_MEDIACODEC_DECODER 0
%define CONFIG_MSA1_DECODER 1
%define CONFIG_MSCC_DECODER 0
%define CONFIG_MSMPEG4V1_DECODER 1
%define CONFIG_MSMPEG4V2_DECODER 1
%define CONFIG_MSMPEG4V3_DECODER 1
%define CONFIG_MSP2_DECODER 1
%define CONFIG_MSRLE_DECODER 1
%define CONFIG_MSS1_DECODER 1
%define CONFIG_MSS2_DECODER 1
%define CONFIG_MSVIDEO1_DECODER 1
%define CONFIG_MSZH_DECODER 1
%define CONFIG_MTS2_DECODER 1
%define CONFIG_MV30_DECODER 1
%define CONFIG_MVC1_DECODER 1
%define CONFIG_MVC2_DECODER 1
%define CONFIG_MVDV_DECODER 1
%define CONFIG_MVHA_DECODER 0
%define CONFIG_MWSC_DECODER 0
%define CONFIG_MXPEG_DECODER 1
%define CONFIG_NOTCHLC_DECODER 1
%define CONFIG_NUV_DECODER 1
%define CONFIG_PAF_VIDEO_DECODER 1
%define CONFIG_PAM_DECODER 1
%define CONFIG_PBM_DECODER 1
%define CONFIG_PCX_DECODER 1
%define CONFIG_PDV_DECODER 0
%define CONFIG_PFM_DECODER 1
%define CONFIG_PGM_DECODER 1
%define CONFIG_PGMYUV_DECODER 1
%define CONFIG_PGX_DECODER 1
%define CONFIG_PHM_DECODER 1
%define CONFIG_PHOTOCD_DECODER 1
%define CONFIG_PICTOR_DECODER 1
%define CONFIG_PIXLET_DECODER 1
%define CONFIG_PNG_DECODER 0
%define CONFIG_PPM_DECODER 1
%define CONFIG_PRORES_DECODER 1
%define CONFIG_PRORES_RAW_DECODER 1
%define CONFIG_PROSUMER_DECODER 1
%define CONFIG_PSD_DECODER 1
%define CONFIG_PTX_DECODER 1
%define CONFIG_QDRAW_DECODER 1
%define CONFIG_QOI_DECODER 1
%define CONFIG_QPEG_DECODER 1
%define CONFIG_QTRLE_DECODER 1
%define CONFIG_R10K_DECODER 1
%define CONFIG_R210_DECODER 1
%define CONFIG_RASC_DECODER 0
%define CONFIG_RAWVIDEO_DECODER 1
%define CONFIG_RKA_DECODER 1
%define CONFIG_RL2_DECODER 1
%define CONFIG_ROQ_DECODER 1
%define CONFIG_RPZA_DECODER 1
%define CONFIG_RSCC_DECODER 0
%define CONFIG_RTV1_DECODER 1
%define CONFIG_RV10_DECODER 1
%define CONFIG_RV20_DECODER 1
%define CONFIG_RV30_DECODER 1
%define CONFIG_RV40_DECODER 1
%define CONFIG_RV60_DECODER 1
%define CONFIG_S302M_DECODER 1
%define CONFIG_SANM_DECODER 1
%define CONFIG_SCPR_DECODER 1
%define CONFIG_SCREENPRESSO_DECODER 0
%define CONFIG_SGA_DECODER 1
%define CONFIG_SGI_DECODER 1
%define CONFIG_SGIRLE_DECODER 1
%define CONFIG_SHEERVIDEO_DECODER 1
%define CONFIG_SIMBIOSIS_IMX_DECODER 1
%define CONFIG_SMACKER_DECODER 1
%define CONFIG_SMC_DECODER 1
%define CONFIG_SMVJPEG_DECODER 1
%define CONFIG_SNOW_DECODER 1
%define CONFIG_SP5X_DECODER 1
%define CONFIG_SPEEDHQ_DECODER 1
%define CONFIG_SPEEX_DECODER 1
%define CONFIG_SRGC_DECODER 0
%define CONFIG_SUNRAST_DECODER 1
%define CONFIG_SVQ1_DECODER 1
%define CONFIG_SVQ3_DECODER 1
%define CONFIG_TARGA_DECODER 1
%define CONFIG_TARGA_Y216_DECODER 1
%define CONFIG_TDSC_DECODER 0
%define CONFIG_THEORA_DECODER 1
%define CONFIG_THP_DECODER 1
%define CONFIG_TIERTEXSEQVIDEO_DECODER 1
%define CONFIG_TIFF_DECODER 1
%define CONFIG_TMV_DECODER 1
%define CONFIG_TRUEMOTION1_DECODER 1
%define CONFIG_TRUEMOTION2_DECODER 1
%define CONFIG_TRUEMOTION2RT_DECODER 1
%define CONFIG_TSCC_DECODER 0
%define CONFIG_TSCC2_DECODER 1
%define CONFIG_TXD_DECODER 1
%define CONFIG_ULTI_DECODER 1
%define CONFIG_UTVIDEO_DECODER 1
%define CONFIG_V210_DECODER 1
%define CONFIG_V210X_DECODER 1
%define CONFIG_V308_DECODER 1
%define CONFIG_V408_DECODER 1
%define CONFIG_V410_DECODER 1
%define CONFIG_VB_DECODER 1
%define CONFIG_VBN_DECODER 1
%define CONFIG_VBLE_DECODER 1
%define CONFIG_VC1_DECODER 1
%define CONFIG_VC1IMAGE_DECODER 1
%define CONFIG_VC1_MMAL_DECODER 0
%define CONFIG_VC1_QSV_DECODER 0
%define CONFIG_VC1_V4L2M2M_DECODER 0
%define CONFIG_VCR1_DECODER 1
%define CONFIG_VMDVIDEO_DECODER 1
%define CONFIG_VMIX_DECODER 1
%define CONFIG_VMNC_DECODER 1
%define CONFIG_VP3_DECODER 1
%define CONFIG_VP4_DECODER 1
%define CONFIG_VP5_DECODER 1
%define CONFIG_VP6_DECODER 1
%define CONFIG_VP6A_DECODER 1
%define CONFIG_VP6F_DECODER 1
%define CONFIG_VP7_DECODER 1
%define CONFIG_VP8_DECODER 1
%define CONFIG_VP8_RKMPP_DECODER 0
%define CONFIG_VP8_V4L2M2M_DECODER 0
%define CONFIG_VP9_DECODER 1
%define CONFIG_VP9_RKMPP_DECODER 0
%define CONFIG_VP9_V4L2M2M_DECODER 0
%define CONFIG_VQA_DECODER 1
%define CONFIG_VQC_DECODER 1
%define CONFIG_VVC_DECODER 1
%define CONFIG_WBMP_DECODER 1
%define CONFIG_WEBP_DECODER 1
%define CONFIG_WCMV_DECODER 0
%define CONFIG_WRAPPED_AVFRAME_DECODER 1
%define CONFIG_WMV1_DECODER 1
%define CONFIG_WMV2_DECODER 1
%define CONFIG_WMV3_DECODER 1
%define CONFIG_WMV3IMAGE_DECODER 1
%define CONFIG_WNV1_DECODER 1
%define CONFIG_XAN_WC3_DECODER 1
%define CONFIG_XAN_WC4_DECODER 1
%define CONFIG_XBM_DECODER 1
%define CONFIG_XFACE_DECODER 1
%define CONFIG_XL_DECODER 1
%define CONFIG_XPM_DECODER 1
%define CONFIG_XWD_DECODER 1
%define CONFIG_Y41P_DECODER 1
%define CONFIG_YLC_DECODER 1
%define CONFIG_YOP_DECODER 1
%define CONFIG_YUV4_DECODER 1
%define CONFIG_ZERO12V_DECODER 1
%define CONFIG_ZEROCODEC_DECODER 0
%define CONFIG_ZLIB_DECODER 0
%define CONFIG_ZMBV_DECODER 0
%define CONFIG_AAC_DECODER 1
%define CONFIG_AAC_FIXED_DECODER 1
%define CONFIG_AAC_LATM_DECODER 1
%define CONFIG_AC3_DECODER 1
%define CONFIG_AC3_FIXED_DECODER 1
%define CONFIG_ACELP_KELVIN_DECODER 1
%define CONFIG_AHX_DECODER 0
%define CONFIG_ALAC_DECODER 1
%define CONFIG_ALS_DECODER 1
%define CONFIG_AMRNB_DECODER 1
%define CONFIG_AMRWB_DECODER 1
%define CONFIG_APAC_DECODER 1
%define CONFIG_APE_DECODER 1
%define CONFIG_APTX_DECODER 1
%define CONFIG_APTX_HD_DECODER 1
%define CONFIG_ATRAC1_DECODER 1
%define CONFIG_ATRAC3_DECODER 1
%define CONFIG_ATRAC3AL_DECODER 1
%define CONFIG_ATRAC3P_DECODER 1
%define CONFIG_ATRAC3PAL_DECODER 1
%define CONFIG_ATRAC9_DECODER 1
%define CONFIG_BINKAUDIO_DCT_DECODER 1
%define CONFIG_BINKAUDIO_RDFT_DECODER 1
%define CONFIG_BMV_AUDIO_DECODER 1
%define CONFIG_BONK_DECODER 1
%define CONFIG_COOK_DECODER 1
%define CONFIG_DCA_DECODER 1
%define CONFIG_DFPWM_DECODER 1
%define CONFIG_DOLBY_E_DECODER 1
%define CONFIG_DSD_LSBF_DECODER 1
%define CONFIG_DSD_MSBF_DECODER 1
%define CONFIG_DSD_LSBF_PLANAR_DECODER 1
%define CONFIG_DSD_MSBF_PLANAR_DECODER 1
%define CONFIG_DSICINAUDIO_DECODER 1
%define CONFIG_DSS_SP_DECODER 1
%define CONFIG_DST_DECODER 1
%define CONFIG_EAC3_DECODER 1
%define CONFIG_EVRC_DECODER 1
%define CONFIG_FASTAUDIO_DECODER 1
%define CONFIG_FFWAVESYNTH_DECODER 1
%define CONFIG_FLAC_DECODER 1
%define CONFIG_FTR_DECODER 1
%define CONFIG_G723_1_DECODER 1
%define CONFIG_G728_DECODER 1
%define CONFIG_G729_DECODER 1
%define CONFIG_GSM_DECODER 1
%define CONFIG_GSM_MS_DECODER 1
%define CONFIG_HCA_DECODER 1
%define CONFIG_HCOM_DECODER 1
%define CONFIG_HDR_DECODER 1
%define CONFIG_IAC_DECODER 1
%define CONFIG_ILBC_DECODER 1
%define CONFIG_IMC_DECODER 1
%define CONFIG_INTERPLAY_ACM_DECODER 1
%define CONFIG_MACE3_DECODER 1
%define CONFIG_MACE6_DECODER 1
%define CONFIG_METASOUND_DECODER 1
%define CONFIG_MISC4_DECODER 1
%define CONFIG_MLP_DECODER 1
%define CONFIG_MP1_DECODER 1
%define CONFIG_MP1FLOAT_DECODER 1
%define CONFIG_MP2_DECODER 1
%define CONFIG_MP2FLOAT_DECODER 1
%define CONFIG_MP3FLOAT_DECODER 1
%define CONFIG_MP3_DECODER 1
%define CONFIG_MP3ADUFLOAT_DECODER 1
%define CONFIG_MP3ADU_DECODER 1
%define CONFIG_MP3ON4FLOAT_DECODER 1
%define CONFIG_MP3ON4_DECODER 1
%define CONFIG_MPC7_DECODER 1
%define CONFIG_MPC8_DECODER 1
%define CONFIG_MSNSIREN_DECODER 1
%define CONFIG_NELLYMOSER_DECODER 1
%define CONFIG_ON2AVC_DECODER 1
%define CONFIG_OPUS_DECODER 1
%define CONFIG_OSQ_DECODER 1
%define CONFIG_PAF_AUDIO_DECODER 1
%define CONFIG_QCELP_DECODER 1
%define CONFIG_QDM2_DECODER 1
%define CONFIG_QDMC_DECODER 1
%define CONFIG_QOA_DECODER 1
%define CONFIG_RA_144_DECODER 1
%define CONFIG_RA_288_DECODER 1
%define CONFIG_RALF_DECODER 1
%define CONFIG_SBC_DECODER 1
%define CONFIG_SHORTEN_DECODER 1
%define CONFIG_SIPR_DECODER 1
%define CONFIG_SIREN_DECODER 1
%define CONFIG_SMACKAUD_DECODER 1
%define CONFIG_SONIC_DECODER 1
%define CONFIG_TAK_DECODER 1
%define CONFIG_TRUEHD_DECODER 1
%define CONFIG_TRUESPEECH_DECODER 1
%define CONFIG_TTA_DECODER 1
%define CONFIG_TWINVQ_DECODER 1
%define CONFIG_VMDAUDIO_DECODER 1
%define CONFIG_VORBIS_DECODER 1
%define CONFIG_WAVARC_DECODER 1
%define CONFIG_WAVPACK_DECODER 1
%define CONFIG_WMALOSSLESS_DECODER 1
%define CONFIG_WMAPRO_DECODER 1
%define CONFIG_WMAV1_DECODER 1
%define CONFIG_WMAV2_DECODER 1
%define CONFIG_WMAVOICE_DECODER 1
%define CONFIG_WS_SND1_DECODER 1
%define CONFIG_XMA1_DECODER 1
%define CONFIG_XMA2_DECODER 1
%define CONFIG_PCM_ALAW_DECODER 1
%define CONFIG_PCM_BLURAY_DECODER 1
%define CONFIG_PCM_DVD_DECODER 1
%define CONFIG_PCM_F16LE_DECODER 1
%define CONFIG_PCM_F24LE_DECODER 1
%define CONFIG_PCM_F32BE_DECODER 1
%define CONFIG_PCM_F32LE_DECODER 1
%define CONFIG_PCM_F64BE_DECODER 1
%define CONFIG_PCM_F64LE_DECODER 1
%define CONFIG_PCM_LXF_DECODER 1
%define CONFIG_PCM_MULAW_DECODER 1
%define CONFIG_PCM_S8_DECODER 1
%define CONFIG_PCM_S8_PLANAR_DECODER 1
%define CONFIG_PCM_S16BE_DECODER 1
%define CONFIG_PCM_S16BE_PLANAR_DECODER 1
%define CONFIG_PCM_S16LE_DECODER 1
%define CONFIG_PCM_S16LE_PLANAR_DECODER 1
%define CONFIG_PCM_S24BE_DECODER 1
%define CONFIG_PCM_S24DAUD_DECODER 1
%define CONFIG_PCM_S24LE_DECODER 1
%define CONFIG_PCM_S24LE_PLANAR_DECODER 1
%define CONFIG_PCM_S32BE_DECODER 1
%define CONFIG_PCM_S32LE_DECODER 1
%define CONFIG_PCM_S32LE_PLANAR_DECODER 1
%define CONFIG_PCM_S64BE_DECODER 1
%define CONFIG_PCM_S64LE_DECODER 1
%define CONFIG_PCM_SGA_DECODER 1
%define CONFIG_PCM_U8_DECODER 1
%define CONFIG_PCM_U16BE_DECODER 1
%define CONFIG_PCM_U16LE_DECODER 1
%define CONFIG_PCM_U24BE_DECODER 1
%define CONFIG_PCM_U24LE_DECODER 1
%define CONFIG_PCM_U32BE_DECODER 1
%define CONFIG_PCM_U32LE_DECODER 1
%define CONFIG_PCM_VIDC_DECODER 1
%define CONFIG_CBD2_DPCM_DECODER 1
%define CONFIG_DERF_DPCM_DECODER 1
%define CONFIG_GREMLIN_DPCM_DECODER 1
%define CONFIG_INTERPLAY_DPCM_DECODER 1
%define CONFIG_ROQ_DPCM_DECODER 1
%define CONFIG_SDX2_DPCM_DECODER 1
%define CONFIG_SOL_DPCM_DECODER 1
%define CONFIG_XAN_DPCM_DECODER 1
%define CONFIG_WADY_DPCM_DECODER 1
%define CONFIG_ADPCM_4XM_DECODER 1
%define CONFIG_ADPCM_ADX_DECODER 1
%define CONFIG_ADPCM_AFC_DECODER 1
%define CONFIG_ADPCM_AGM_DECODER 1
%define CONFIG_ADPCM_AICA_DECODER 1
%define CONFIG_ADPCM_ARGO_DECODER 1
%define CONFIG_ADPCM_CIRCUS_DECODER 0
%define CONFIG_ADPCM_CT_DECODER 1
%define CONFIG_ADPCM_DTK_DECODER 1
%define CONFIG_ADPCM_EA_DECODER 1
%define CONFIG_ADPCM_EA_MAXIS_XA_DECODER 1
%define CONFIG_ADPCM_EA_R1_DECODER 1
%define CONFIG_ADPCM_EA_R2_DECODER 1
%define CONFIG_ADPCM_EA_R3_DECODER 1
%define CONFIG_ADPCM_EA_XAS_DECODER 1
%define CONFIG_ADPCM_G722_DECODER 1
%define CONFIG_ADPCM_G726_DECODER 1
%define CONFIG_ADPCM_G726LE_DECODER 1
%define CONFIG_ADPCM_IMA_ACORN_DECODER 1
%define CONFIG_ADPCM_IMA_AMV_DECODER 1
%define CONFIG_ADPCM_IMA_ALP_DECODER 1
%define CONFIG_ADPCM_IMA_APC_DECODER 1
%define CONFIG_ADPCM_IMA_APM_DECODER 1
%define CONFIG_ADPCM_IMA_CUNNING_DECODER 1
%define CONFIG_ADPCM_IMA_DAT4_DECODER 1
%define CONFIG_ADPCM_IMA_DK3_DECODER 1
%define CONFIG_ADPCM_IMA_DK4_DECODER 1
%define CONFIG_ADPCM_IMA_EA_EACS_DECODER 1
%define CONFIG_ADPCM_IMA_EA_SEAD_DECODER 1
%define CONFIG_ADPCM_IMA_ESCAPE_DECODER 0
%define CONFIG_ADPCM_IMA_HVQM2_DECODER 0
%define CONFIG_ADPCM_IMA_HVQM4_DECODER 0
%define CONFIG_ADPCM_IMA_ISS_DECODER 1
%define CONFIG_ADPCM_IMA_MAGIX_DECODER 0
%define CONFIG_ADPCM_IMA_MOFLEX_DECODER 1
%define CONFIG_ADPCM_IMA_MTF_DECODER 1
%define CONFIG_ADPCM_IMA_OKI_DECODER 1
%define CONFIG_ADPCM_IMA_PDA_DECODER 0
%define CONFIG_ADPCM_IMA_QT_DECODER 1
%define CONFIG_ADPCM_IMA_RAD_DECODER 1
%define CONFIG_ADPCM_IMA_SSI_DECODER 1
%define CONFIG_ADPCM_IMA_SMJPEG_DECODER 1
%define CONFIG_ADPCM_IMA_WAV_DECODER 1
%define CONFIG_ADPCM_IMA_WS_DECODER 1
%define CONFIG_ADPCM_IMA_XBOX_DECODER 1
%define CONFIG_ADPCM_MS_DECODER 1
%define CONFIG_ADPCM_MTAF_DECODER 1
%define CONFIG_ADPCM_N64_DECODER 0
%define CONFIG_ADPCM_PSX_DECODER 1
%define CONFIG_ADPCM_PSXC_DECODER 0
%define CONFIG_ADPCM_SANYO_DECODER 1
%define CONFIG_ADPCM_SBPRO_2_DECODER 1
%define CONFIG_ADPCM_SBPRO_3_DECODER 1
%define CONFIG_ADPCM_SBPRO_4_DECODER 1
%define CONFIG_ADPCM_SWF_DECODER 1
%define CONFIG_ADPCM_THP_DECODER 1
%define CONFIG_ADPCM_THP_LE_DECODER 1
%define CONFIG_ADPCM_VIMA_DECODER 1
%define CONFIG_ADPCM_XA_DECODER 1
%define CONFIG_ADPCM_XMD_DECODER 1
%define CONFIG_ADPCM_YAMAHA_DECODER 1
%define CONFIG_ADPCM_ZORK_DECODER 1
%define CONFIG_SSA_DECODER 1
%define CONFIG_ASS_DECODER 1
%define CONFIG_CCAPTION_DECODER 1
%define CONFIG_DVBSUB_DECODER 1
%define CONFIG_DVDSUB_DECODER 1
%define CONFIG_JACOSUB_DECODER 1
%define CONFIG_MICRODVD_DECODER 1
%define CONFIG_MOVTEXT_DECODER 1
%define CONFIG_MPL2_DECODER 1
%define CONFIG_PGSSUB_DECODER 1
%define CONFIG_PJS_DECODER 1
%define CONFIG_REALTEXT_DECODER 1
%define CONFIG_SAMI_DECODER 1
%define CONFIG_SRT_DECODER 1
%define CONFIG_STL_DECODER 1
%define CONFIG_SUBRIP_DECODER 1
%define CONFIG_SUBVIEWER_DECODER 1
%define CONFIG_SUBVIEWER1_DECODER 1
%define CONFIG_TEXT_DECODER 1
%define CONFIG_VPLAYER_DECODER 1
%define CONFIG_WEBVTT_DECODER 1
%define CONFIG_XSUB_DECODER 1
%define CONFIG_AAC_AT_DECODER 0
%define CONFIG_AC3_AT_DECODER 0
%define CONFIG_ADPCM_IMA_QT_AT_DECODER 0
%define CONFIG_ALAC_AT_DECODER 0
%define CONFIG_AMR_NB_AT_DECODER 0
%define CONFIG_EAC3_AT_DECODER 0
%define CONFIG_GSM_MS_AT_DECODER 0
%define CONFIG_ILBC_AT_DECODER 0
%define CONFIG_MP1_AT_DECODER 0
%define CONFIG_MP2_AT_DECODER 0
%define CONFIG_MP3_AT_DECODER 0
%define CONFIG_PCM_ALAW_AT_DECODER 0
%define CONFIG_PCM_MULAW_AT_DECODER 0
%define CONFIG_QDMC_AT_DECODER 0
%define CONFIG_QDM2_AT_DECODER 0
%define CONFIG_LIBARIBCAPTION_DECODER 0
%define CONFIG_LIBARIBB24_DECODER 0
%define CONFIG_LIBCELT_DECODER 0
%define CONFIG_LIBCODEC2_DECODER 0
%define CONFIG_LIBDAV1D_DECODER 0
%define CONFIG_LIBDAVS2_DECODER 0
%define CONFIG_LIBFDK_AAC_DECODER 0
%define CONFIG_LIBGSM_DECODER 0
%define CONFIG_LIBGSM_MS_DECODER 0
%define CONFIG_LIBILBC_DECODER 0
%define CONFIG_LIBJXL_ANIM_DECODER 0
%define CONFIG_LIBJXL_DECODER 0
%define CONFIG_LIBLC3_DECODER 0
%define CONFIG_LIBMPEGHDEC_DECODER 0
%define CONFIG_LIBOPENCORE_AMRNB_DECODER 0
%define CONFIG_LIBOPENCORE_AMRWB_DECODER 0
%define CONFIG_LIBOPUS_DECODER 0
%define CONFIG_LIBRSVG_DECODER 0
%define CONFIG_LIBSPEEX_DECODER 0
%define CONFIG_LIBSVTJPEGXS_DECODER 0
%define CONFIG_LIBUAVS3D_DECODER 0
%define CONFIG_LIBVORBIS_DECODER 0
%define CONFIG_LIBVPX_VP8_DECODER 0
%define CONFIG_LIBVPX_VP9_DECODER 0
%define CONFIG_LIBXEVD_DECODER 0
%define CONFIG_LIBZVBI_TELETEXT_DECODER 0
%define CONFIG_BINTEXT_DECODER 1
%define CONFIG_XBIN_DECODER 1
%define CONFIG_IDF_DECODER 1
%define CONFIG_AAC_MEDIACODEC_DECODER 0
%define CONFIG_AMRNB_MEDIACODEC_DECODER 0
%define CONFIG_AMRWB_MEDIACODEC_DECODER 0
%define CONFIG_LIBAOM_AV1_DECODER 0
%define CONFIG_AV1_DECODER 1
%define CONFIG_AV1_CUVID_DECODER 0
%define CONFIG_AV1_MEDIACODEC_DECODER 0
%define CONFIG_AV1_QSV_DECODER 0
%define CONFIG_AV1_AMF_DECODER 0
%define CONFIG_LIBOPENH264_DECODER 0
%define CONFIG_H264_AMF_DECODER 0
%define CONFIG_H264_CUVID_DECODER 0
%define CONFIG_H264_OH_DECODER 0
%define CONFIG_HEVC_AMF_DECODER 0
%define CONFIG_HEVC_CUVID_DECODER 0
%define CONFIG_HEVC_MEDIACODEC_DECODER 0
%define CONFIG_HEVC_OH_DECODER 0
%define CONFIG_MJPEG_CUVID_DECODER 0
%define CONFIG_MJPEG_QSV_DECODER 0
%define CONFIG_MP3_MEDIACODEC_DECODER 0
%define CONFIG_MPEG1_CUVID_DECODER 0
%define CONFIG_MPEG2_CUVID_DECODER 0
%define CONFIG_MPEG4_CUVID_DECODER 0
%define CONFIG_MPEG4_MEDIACODEC_DECODER 0
%define CONFIG_VC1_CUVID_DECODER 0
%define CONFIG_VP8_CUVID_DECODER 0
%define CONFIG_VP8_MEDIACODEC_DECODER 0
%define CONFIG_VP8_QSV_DECODER 0
%define CONFIG_VP9_AMF_DECODER 0
%define CONFIG_VP9_CUVID_DECODER 0
%define CONFIG_VP9_MEDIACODEC_DECODER 0
%define CONFIG_VP9_QSV_DECODER 0
%define CONFIG_VVC_QSV_DECODER 0
%define CONFIG_VNULL_DECODER 1
%define CONFIG_ANULL_DECODER 1
%define CONFIG_A64MULTI_ENCODER 1
%define CONFIG_A64MULTI5_ENCODER 1
%define CONFIG_ALIAS_PIX_ENCODER 1
%define CONFIG_AMV_ENCODER 1
%define CONFIG_APNG_ENCODER 0
%define CONFIG_ASV1_ENCODER 1
%define CONFIG_ASV2_ENCODER 1
%define CONFIG_AVRP_ENCODER 1
%define CONFIG_AVUI_ENCODER 1
%define CONFIG_BITPACKED_ENCODER 1
%define CONFIG_BMP_ENCODER 1
%define CONFIG_CFHD_ENCODER 1
%define CONFIG_CINEPAK_ENCODER 1
%define CONFIG_CLJR_ENCODER 1
%define CONFIG_COMFORTNOISE_ENCODER 1
%define CONFIG_DNXHD_ENCODER 1
%define CONFIG_DPX_ENCODER 1
%define CONFIG_DVVIDEO_ENCODER 1
%define CONFIG_DXV_ENCODER 1
%define CONFIG_EXR_ENCODER 0
%define CONFIG_FFV1_ENCODER 1
%define CONFIG_FFV1_VULKAN_ENCODER 0
%define CONFIG_FFVHUFF_ENCODER 1
%define CONFIG_FITS_ENCODER 1
%define CONFIG_FLASHSV_ENCODER 0
%define CONFIG_FLASHSV2_ENCODER 0
%define CONFIG_FLV_ENCODER 1
%define CONFIG_GIF_ENCODER 1
%define CONFIG_H261_ENCODER 1
%define CONFIG_H263_ENCODER 1
%define CONFIG_H263P_ENCODER 1
%define CONFIG_H264_MEDIACODEC_ENCODER 0
%define CONFIG_H264_RKMPP_ENCODER 0
%define CONFIG_HAP_ENCODER 0
%define CONFIG_HEVC_RKMPP_ENCODER 0
%define CONFIG_HUFFYUV_ENCODER 1
%define CONFIG_JPEG2000_ENCODER 1
%define CONFIG_JPEGLS_ENCODER 1
%define CONFIG_LJPEG_ENCODER 1
%define CONFIG_MAGICYUV_ENCODER 1
%define CONFIG_MJPEG_ENCODER 1
%define CONFIG_MPEG1VIDEO_ENCODER 1
%define CONFIG_MPEG2VIDEO_ENCODER 1
%define CONFIG_MPEG4_ENCODER 1
%define CONFIG_MSMPEG4V2_ENCODER 1
%define CONFIG_MSMPEG4V3_ENCODER 1
%define CONFIG_MSRLE_ENCODER 1
%define CONFIG_MSVIDEO1_ENCODER 1
%define CONFIG_PAM_ENCODER 1
%define CONFIG_PBM_ENCODER 1
%define CONFIG_PCX_ENCODER 1
%define CONFIG_PFM_ENCODER 1
%define CONFIG_PGM_ENCODER 1
%define CONFIG_PGMYUV_ENCODER 1
%define CONFIG_PHM_ENCODER 1
%define CONFIG_PNG_ENCODER 0
%define CONFIG_PPM_ENCODER 1
%define CONFIG_PRORES_ENCODER 1
%define CONFIG_PRORES_AW_ENCODER 1
%define CONFIG_PRORES_KS_ENCODER 1
%define CONFIG_PRORES_KS_VULKAN_ENCODER 0
%define CONFIG_QOI_ENCODER 1
%define CONFIG_QTRLE_ENCODER 1
%define CONFIG_R10K_ENCODER 1
%define CONFIG_R210_ENCODER 1
%define CONFIG_RAWVIDEO_ENCODER 1
%define CONFIG_ROQ_ENCODER 1
%define CONFIG_RPZA_ENCODER 1
%define CONFIG_RV10_ENCODER 1
%define CONFIG_RV20_ENCODER 1
%define CONFIG_S302M_ENCODER 1
%define CONFIG_SGI_ENCODER 1
%define CONFIG_SMC_ENCODER 1
%define CONFIG_SNOW_ENCODER 1
%define CONFIG_SPEEDHQ_ENCODER 1
%define CONFIG_SUNRAST_ENCODER 1
%define CONFIG_SVQ1_ENCODER 1
%define CONFIG_TARGA_ENCODER 1
%define CONFIG_TIFF_ENCODER 1
%define CONFIG_UTVIDEO_ENCODER 1
%define CONFIG_V210_ENCODER 1
%define CONFIG_V308_ENCODER 1
%define CONFIG_V408_ENCODER 1
%define CONFIG_V410_ENCODER 1
%define CONFIG_VBN_ENCODER 1
%define CONFIG_VC2_ENCODER 1
%define CONFIG_WBMP_ENCODER 1
%define CONFIG_WRAPPED_AVFRAME_ENCODER 1
%define CONFIG_WMV1_ENCODER 1
%define CONFIG_WMV2_ENCODER 1
%define CONFIG_XBM_ENCODER 1
%define CONFIG_XFACE_ENCODER 1
%define CONFIG_XWD_ENCODER 1
%define CONFIG_Y41P_ENCODER 1
%define CONFIG_YUV4_ENCODER 1
%define CONFIG_ZLIB_ENCODER 0
%define CONFIG_ZMBV_ENCODER 0
%define CONFIG_AAC_ENCODER 1
%define CONFIG_AC3_ENCODER 1
%define CONFIG_AC3_FIXED_ENCODER 1
%define CONFIG_ALAC_ENCODER 1
%define CONFIG_APTX_ENCODER 1
%define CONFIG_APTX_HD_ENCODER 1
%define CONFIG_DCA_ENCODER 1
%define CONFIG_DFPWM_ENCODER 1
%define CONFIG_EAC3_ENCODER 1
%define CONFIG_FLAC_ENCODER 1
%define CONFIG_G723_1_ENCODER 1
%define CONFIG_HDR_ENCODER 1
%define CONFIG_MLP_ENCODER 1
%define CONFIG_MP2_ENCODER 1
%define CONFIG_MP2FIXED_ENCODER 1
%define CONFIG_NELLYMOSER_ENCODER 1
%define CONFIG_OPUS_ENCODER 1
%define CONFIG_RA_144_ENCODER 1
%define CONFIG_SBC_ENCODER 1
%define CONFIG_SONIC_ENCODER 0
%define CONFIG_SONIC_LS_ENCODER 0
%define CONFIG_TRUEHD_ENCODER 1
%define CONFIG_TTA_ENCODER 1
%define CONFIG_VORBIS_ENCODER 1
%define CONFIG_WAVPACK_ENCODER 1
%define CONFIG_WMAV1_ENCODER 1
%define CONFIG_WMAV2_ENCODER 1
%define CONFIG_PCM_ALAW_ENCODER 1
%define CONFIG_PCM_BLURAY_ENCODER 1
%define CONFIG_PCM_DVD_ENCODER 1
%define CONFIG_PCM_F32BE_ENCODER 1
%define CONFIG_PCM_F32LE_ENCODER 1
%define CONFIG_PCM_F64BE_ENCODER 1
%define CONFIG_PCM_F64LE_ENCODER 1
%define CONFIG_PCM_MULAW_ENCODER 1
%define CONFIG_PCM_S8_ENCODER 1
%define CONFIG_PCM_S8_PLANAR_ENCODER 1
%define CONFIG_PCM_S16BE_ENCODER 1
%define CONFIG_PCM_S16BE_PLANAR_ENCODER 1
%define CONFIG_PCM_S16LE_ENCODER 1
%define CONFIG_PCM_S16LE_PLANAR_ENCODER 1
%define CONFIG_PCM_S24BE_ENCODER 1
%define CONFIG_PCM_S24DAUD_ENCODER 1
%define CONFIG_PCM_S24LE_ENCODER 1
%define CONFIG_PCM_S24LE_PLANAR_ENCODER 1
%define CONFIG_PCM_S32BE_ENCODER 1
%define CONFIG_PCM_S32LE_ENCODER 1
%define CONFIG_PCM_S32LE_PLANAR_ENCODER 1
%define CONFIG_PCM_S64BE_ENCODER 1
%define CONFIG_PCM_S64LE_ENCODER 1
%define CONFIG_PCM_U8_ENCODER 1
%define CONFIG_PCM_U16BE_ENCODER 1
%define CONFIG_PCM_U16LE_ENCODER 1
%define CONFIG_PCM_U24BE_ENCODER 1
%define CONFIG_PCM_U24LE_ENCODER 1
%define CONFIG_PCM_U32BE_ENCODER 1
%define CONFIG_PCM_U32LE_ENCODER 1
%define CONFIG_PCM_VIDC_ENCODER 1
%define CONFIG_ROQ_DPCM_ENCODER 1
%define CONFIG_ADPCM_ADX_ENCODER 1
%define CONFIG_ADPCM_ARGO_ENCODER 1
%define CONFIG_ADPCM_G722_ENCODER 1
%define CONFIG_ADPCM_G726_ENCODER 1
%define CONFIG_ADPCM_G726LE_ENCODER 1
%define CONFIG_ADPCM_IMA_AMV_ENCODER 1
%define CONFIG_ADPCM_IMA_ALP_ENCODER 1
%define CONFIG_ADPCM_IMA_APM_ENCODER 1
%define CONFIG_ADPCM_IMA_QT_ENCODER 1
%define CONFIG_ADPCM_IMA_SSI_ENCODER 1
%define CONFIG_ADPCM_IMA_WAV_ENCODER 1
%define CONFIG_ADPCM_IMA_WS_ENCODER 1
%define CONFIG_ADPCM_MS_ENCODER 1
%define CONFIG_ADPCM_SWF_ENCODER 1
%define CONFIG_ADPCM_YAMAHA_ENCODER 1
%define CONFIG_SSA_ENCODER 1
%define CONFIG_ASS_ENCODER 1
%define CONFIG_DVBSUB_ENCODER 1
%define CONFIG_DVDSUB_ENCODER 1
%define CONFIG_MOVTEXT_ENCODER 1
%define CONFIG_SRT_ENCODER 1
%define CONFIG_SUBRIP_ENCODER 1
%define CONFIG_TEXT_ENCODER 1
%define CONFIG_TTML_ENCODER 1
%define CONFIG_WEBVTT_ENCODER 1
%define CONFIG_XSUB_ENCODER 1
%define CONFIG_AAC_AT_ENCODER 0
%define CONFIG_ALAC_AT_ENCODER 0
%define CONFIG_ILBC_AT_ENCODER 0
%define CONFIG_PCM_ALAW_AT_ENCODER 0
%define CONFIG_PCM_MULAW_AT_ENCODER 0
%define CONFIG_LIBAOM_AV1_ENCODER 0
%define CONFIG_LIBCODEC2_ENCODER 0
%define CONFIG_LIBFDK_AAC_ENCODER 0
%define CONFIG_LIBGSM_ENCODER 0
%define CONFIG_LIBGSM_MS_ENCODER 0
%define CONFIG_LIBILBC_ENCODER 0
%define CONFIG_LIBJXL_ANIM_ENCODER 0
%define CONFIG_LIBJXL_ENCODER 0
%define CONFIG_LIBLC3_ENCODER 0
%define CONFIG_LIBMP3LAME_ENCODER 0
%define CONFIG_LIBOAPV_ENCODER 0
%define CONFIG_LIBOPENCORE_AMRNB_ENCODER 0
%define CONFIG_LIBOPENJPEG_ENCODER 0
%define CONFIG_LIBOPUS_ENCODER 0
%define CONFIG_LIBRAV1E_ENCODER 0
%define CONFIG_LIBSHINE_ENCODER 0
%define CONFIG_LIBSPEEX_ENCODER 0
%define CONFIG_LIBSVTAV1_ENCODER 0
%define CONFIG_LIBSVTJPEGXS_ENCODER 0
%define CONFIG_LIBTHEORA_ENCODER 0
%define CONFIG_LIBTWOLAME_ENCODER 0
%define CONFIG_LIBVO_AMRWBENC_ENCODER 0
%define CONFIG_LIBVORBIS_ENCODER 0
%define CONFIG_LIBVPX_VP8_ENCODER 0
%define CONFIG_LIBVPX_VP9_ENCODER 0
%define CONFIG_LIBVVENC_ENCODER 0
%define CONFIG_LIBWEBP_ANIM_ENCODER 0
%define CONFIG_LIBWEBP_ENCODER 0
%define CONFIG_LIBX262_ENCODER 0
%define CONFIG_LIBX264_ENCODER 0
%define CONFIG_LIBX264RGB_ENCODER 0
%define CONFIG_LIBX265_ENCODER 0
%define CONFIG_LIBXEVE_ENCODER 0
%define CONFIG_LIBXAVS_ENCODER 0
%define CONFIG_LIBXAVS2_ENCODER 0
%define CONFIG_LIBXVID_ENCODER 0
%define CONFIG_AAC_MF_ENCODER 0
%define CONFIG_AC3_MF_ENCODER 0
%define CONFIG_H263_V4L2M2M_ENCODER 0
%define CONFIG_AV1_D3D12VA_ENCODER 0
%define CONFIG_AV1_MEDIACODEC_ENCODER 0
%define CONFIG_AV1_NVENC_ENCODER 0
%define CONFIG_AV1_QSV_ENCODER 0
%define CONFIG_AV1_AMF_ENCODER 0
%define CONFIG_AV1_MF_ENCODER 0
%define CONFIG_AV1_VAAPI_ENCODER 0
%define CONFIG_AV1_VULKAN_ENCODER 0
%define CONFIG_LIBOPENH264_ENCODER 0
%define CONFIG_H264_AMF_ENCODER 0
%define CONFIG_H264_D3D12VA_ENCODER 0
%define CONFIG_H264_MF_ENCODER 0
%define CONFIG_H264_NVENC_ENCODER 0
%define CONFIG_H264_OH_ENCODER 0
%define CONFIG_H264_OMX_ENCODER 0
%define CONFIG_H264_QSV_ENCODER 0
%define CONFIG_H264_V4L2M2M_ENCODER 0
%define CONFIG_H264_VAAPI_ENCODER 0
%define CONFIG_H264_VIDEOTOOLBOX_ENCODER 0
%define CONFIG_H264_VULKAN_ENCODER 0
%define CONFIG_HEVC_AMF_ENCODER 0
%define CONFIG_HEVC_D3D12VA_ENCODER 0
%define CONFIG_HEVC_MEDIACODEC_ENCODER 0
%define CONFIG_HEVC_MF_ENCODER 0
%define CONFIG_HEVC_NVENC_ENCODER 0
%define CONFIG_HEVC_OH_ENCODER 0
%define CONFIG_HEVC_QSV_ENCODER 0
%define CONFIG_HEVC_V4L2M2M_ENCODER 0
%define CONFIG_HEVC_VAAPI_ENCODER 0
%define CONFIG_HEVC_VIDEOTOOLBOX_ENCODER 0
%define CONFIG_HEVC_VULKAN_ENCODER 0
%define CONFIG_LIBKVAZAAR_ENCODER 0
%define CONFIG_MJPEG_QSV_ENCODER 0
%define CONFIG_MJPEG_VAAPI_ENCODER 0
%define CONFIG_MP3_MF_ENCODER 0
%define CONFIG_MPEG2_QSV_ENCODER 0
%define CONFIG_MPEG2_VAAPI_ENCODER 0
%define CONFIG_MPEG4_MEDIACODEC_ENCODER 0
%define CONFIG_MPEG4_OMX_ENCODER 0
%define CONFIG_MPEG4_V4L2M2M_ENCODER 0
%define CONFIG_PRORES_VIDEOTOOLBOX_ENCODER 0
%define CONFIG_VP8_MEDIACODEC_ENCODER 0
%define CONFIG_VP8_V4L2M2M_ENCODER 0
%define CONFIG_VP8_VAAPI_ENCODER 0
%define CONFIG_VP9_MEDIACODEC_ENCODER 0
%define CONFIG_VP9_VAAPI_ENCODER 0
%define CONFIG_VP9_QSV_ENCODER 0
%define CONFIG_VNULL_ENCODER 1
%define CONFIG_ANULL_ENCODER 1
%define CONFIG_AV1_D3D11VA_HWACCEL 0
%define CONFIG_AV1_D3D11VA2_HWACCEL 0
%define CONFIG_AV1_D3D12VA_HWACCEL 0
%define CONFIG_AV1_DXVA2_HWACCEL 0
%define CONFIG_AV1_NVDEC_HWACCEL 0
%define CONFIG_AV1_VAAPI_HWACCEL 0
%define CONFIG_AV1_VDPAU_HWACCEL 0
%define CONFIG_AV1_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_AV1_VULKAN_HWACCEL 0
%define CONFIG_DPX_VULKAN_HWACCEL 0
%define CONFIG_FFV1_VULKAN_HWACCEL 0
%define CONFIG_H263_VAAPI_HWACCEL 0
%define CONFIG_H263_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_H264_D3D11VA_HWACCEL 0
%define CONFIG_H264_D3D11VA2_HWACCEL 0
%define CONFIG_H264_D3D12VA_HWACCEL 0
%define CONFIG_H264_DXVA2_HWACCEL 0
%define CONFIG_H264_NVDEC_HWACCEL 0
%define CONFIG_H264_VAAPI_HWACCEL 0
%define CONFIG_H264_VDPAU_HWACCEL 0
%define CONFIG_H264_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_H264_VULKAN_HWACCEL 0
%define CONFIG_HEVC_D3D11VA_HWACCEL 0
%define CONFIG_HEVC_D3D11VA2_HWACCEL 0
%define CONFIG_HEVC_D3D12VA_HWACCEL 0
%define CONFIG_HEVC_DXVA2_HWACCEL 0
%define CONFIG_HEVC_NVDEC_HWACCEL 0
%define CONFIG_HEVC_VAAPI_HWACCEL 0
%define CONFIG_HEVC_VDPAU_HWACCEL 0
%define CONFIG_HEVC_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_HEVC_VULKAN_HWACCEL 0
%define CONFIG_MJPEG_NVDEC_HWACCEL 0
%define CONFIG_MJPEG_VAAPI_HWACCEL 0
%define CONFIG_MPEG1_NVDEC_HWACCEL 0
%define CONFIG_MPEG1_VDPAU_HWACCEL 0
%define CONFIG_MPEG1_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_MPEG2_D3D11VA_HWACCEL 0
%define CONFIG_MPEG2_D3D11VA2_HWACCEL 0
%define CONFIG_MPEG2_D3D12VA_HWACCEL 0
%define CONFIG_MPEG2_DXVA2_HWACCEL 0
%define CONFIG_MPEG2_NVDEC_HWACCEL 0
%define CONFIG_MPEG2_VAAPI_HWACCEL 0
%define CONFIG_MPEG2_VDPAU_HWACCEL 0
%define CONFIG_MPEG2_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_MPEG4_NVDEC_HWACCEL 0
%define CONFIG_MPEG4_VAAPI_HWACCEL 0
%define CONFIG_MPEG4_VDPAU_HWACCEL 0
%define CONFIG_MPEG4_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_PRORES_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_PRORES_VULKAN_HWACCEL 0
%define CONFIG_PRORES_RAW_VULKAN_HWACCEL 0
%define CONFIG_VC1_D3D11VA_HWACCEL 0
%define CONFIG_VC1_D3D11VA2_HWACCEL 0
%define CONFIG_VC1_D3D12VA_HWACCEL 0
%define CONFIG_VC1_DXVA2_HWACCEL 0
%define CONFIG_VC1_NVDEC_HWACCEL 0
%define CONFIG_VC1_VAAPI_HWACCEL 0
%define CONFIG_VC1_VDPAU_HWACCEL 0
%define CONFIG_VP8_NVDEC_HWACCEL 0
%define CONFIG_VP8_VAAPI_HWACCEL 0
%define CONFIG_VP9_D3D11VA_HWACCEL 0
%define CONFIG_VP9_D3D11VA2_HWACCEL 0
%define CONFIG_VP9_D3D12VA_HWACCEL 0
%define CONFIG_VP9_DXVA2_HWACCEL 0
%define CONFIG_VP9_NVDEC_HWACCEL 0
%define CONFIG_VP9_VAAPI_HWACCEL 0
%define CONFIG_VP9_VDPAU_HWACCEL 0
%define CONFIG_VP9_VIDEOTOOLBOX_HWACCEL 0
%define CONFIG_VP9_VULKAN_HWACCEL 0
%define CONFIG_VVC_VAAPI_HWACCEL 0
%define CONFIG_WMV3_D3D11VA_HWACCEL 0
%define CONFIG_WMV3_D3D11VA2_HWACCEL 0
%define CONFIG_WMV3_D3D12VA_HWACCEL 0
%define CONFIG_WMV3_DXVA2_HWACCEL 0
%define CONFIG_WMV3_NVDEC_HWACCEL 0
%define CONFIG_WMV3_VAAPI_HWACCEL 0
%define CONFIG_WMV3_VDPAU_HWACCEL 0
%define CONFIG_AAC_PARSER 1
%define CONFIG_AAC_LATM_PARSER 1
%define CONFIG_AC3_PARSER 1
%define CONFIG_ADX_PARSER 1
%define CONFIG_AHX_PARSER 0
%define CONFIG_AMR_PARSER 1
%define CONFIG_APV_PARSER 1
%define CONFIG_AV1_PARSER 1
%define CONFIG_AVS2_PARSER 1
%define CONFIG_AVS3_PARSER 1
%define CONFIG_BMP_PARSER 1
%define CONFIG_CAVSVIDEO_PARSER 1
%define CONFIG_COOK_PARSER 1
%define CONFIG_CRI_PARSER 1
%define CONFIG_DCA_PARSER 1
%define CONFIG_DIRAC_PARSER 1
%define CONFIG_DNXHD_PARSER 1
%define CONFIG_DNXUC_PARSER 1
%define CONFIG_DOLBY_E_PARSER 1
%define CONFIG_DPX_PARSER 1
%define CONFIG_DVAUDIO_PARSER 1
%define CONFIG_DVBSUB_PARSER 1
%define CONFIG_DVDSUB_PARSER 1
%define CONFIG_DVD_NAV_PARSER 1
%define CONFIG_EVC_PARSER 1
%define CONFIG_FLAC_PARSER 1
%define CONFIG_FTR_PARSER 1
%define CONFIG_FFV1_PARSER 1
%define CONFIG_G723_1_PARSER 1
%define CONFIG_G729_PARSER 1
%define CONFIG_GIF_PARSER 1
%define CONFIG_GSM_PARSER 1
%define CONFIG_H261_PARSER 1
%define CONFIG_H263_PARSER 1
%define CONFIG_H264_PARSER 1
%define CONFIG_HEVC_PARSER 1
%define CONFIG_HDR_PARSER 1
%define CONFIG_IPU_PARSER 1
%define CONFIG_JPEG2000_PARSER 1
%define CONFIG_JPEGXL_PARSER 1
%define CONFIG_JPEGXS_PARSER 1
%define CONFIG_LCEVC_PARSER 1
%define CONFIG_MISC4_PARSER 1
%define CONFIG_MJPEG_PARSER 1
%define CONFIG_MLP_PARSER 1
%define CONFIG_MPEG4VIDEO_PARSER 1
%define CONFIG_MPEGAUDIO_PARSER 1
%define CONFIG_MPEGVIDEO_PARSER 1
%define CONFIG_OPUS_PARSER 1
%define CONFIG_PRORES_PARSER 1
%define CONFIG_PNG_PARSER 1
%define CONFIG_PNM_PARSER 1
%define CONFIG_PRORES_RAW_PARSER 1
%define CONFIG_QOI_PARSER 1
%define CONFIG_RV34_PARSER 1
%define CONFIG_SBC_PARSER 1
%define CONFIG_SIPR_PARSER 1
%define CONFIG_TAK_PARSER 1
%define CONFIG_VC1_PARSER 1
%define CONFIG_VORBIS_PARSER 1
%define CONFIG_VP3_PARSER 1
%define CONFIG_VP8_PARSER 1
%define CONFIG_VP9_PARSER 1
%define CONFIG_VVC_PARSER 1
%define CONFIG_WEBP_PARSER 1
%define CONFIG_XBM_PARSER 1
%define CONFIG_XMA_PARSER 1
%define CONFIG_XWD_PARSER 1
%define CONFIG_ALSA_INDEV 0
%define CONFIG_ANDROID_CAMERA_INDEV 0
%define CONFIG_AVFOUNDATION_INDEV 0
%define CONFIG_DECKLINK_INDEV 0
%define CONFIG_DSHOW_INDEV 1
%define CONFIG_FBDEV_INDEV 0
%define CONFIG_GDIGRAB_INDEV 1
%define CONFIG_IEC61883_INDEV 0
%define CONFIG_JACK_INDEV 0
%define CONFIG_KMSGRAB_INDEV 0
%define CONFIG_LAVFI_INDEV 1
%define CONFIG_OPENAL_INDEV 0
%define CONFIG_OSS_INDEV 0
%define CONFIG_PULSE_INDEV 0
%define CONFIG_SNDIO_INDEV 0
%define CONFIG_V4L2_INDEV 0
%define CONFIG_VFWCAP_INDEV 1
%define CONFIG_XCBGRAB_INDEV 0
%define CONFIG_LIBCDIO_INDEV 0
%define CONFIG_LIBDC1394_INDEV 0
%define CONFIG_ALSA_OUTDEV 0
%define CONFIG_AUDIOTOOLBOX_OUTDEV 0
%define CONFIG_CACA_OUTDEV 0
%define CONFIG_DECKLINK_OUTDEV 0
%define CONFIG_FBDEV_OUTDEV 0
%define CONFIG_OSS_OUTDEV 0
%define CONFIG_PULSE_OUTDEV 0
%define CONFIG_SNDIO_OUTDEV 0
%define CONFIG_V4L2_OUTDEV 0
%define CONFIG_XV_OUTDEV 0
%define CONFIG_AAP_FILTER 1
%define CONFIG_ABENCH_FILTER 1
%define CONFIG_ACOMPRESSOR_FILTER 1
%define CONFIG_ACONTRAST_FILTER 1
%define CONFIG_ACOPY_FILTER 1
%define CONFIG_ACUE_FILTER 1
%define CONFIG_ACROSSFADE_FILTER 1
%define CONFIG_ACROSSOVER_FILTER 1
%define CONFIG_ACRUSHER_FILTER 1
%define CONFIG_ADECLICK_FILTER 1
%define CONFIG_ADECLIP_FILTER 1
%define CONFIG_ADECORRELATE_FILTER 1
%define CONFIG_ADELAY_FILTER 1
%define CONFIG_ADENORM_FILTER 1
%define CONFIG_ADERIVATIVE_FILTER 1
%define CONFIG_ADRC_FILTER 1
%define CONFIG_ADYNAMICEQUALIZER_FILTER 1
%define CONFIG_ADYNAMICSMOOTH_FILTER 1
%define CONFIG_AECHO_FILTER 1
%define CONFIG_AEMPHASIS_FILTER 1
%define CONFIG_AEVAL_FILTER 1
%define CONFIG_AEXCITER_FILTER 1
%define CONFIG_AFADE_FILTER 1
%define CONFIG_AFFTDN_FILTER 1
%define CONFIG_AFFTFILT_FILTER 1
%define CONFIG_AFIR_FILTER 1
%define CONFIG_AFORMAT_FILTER 1
%define CONFIG_AFREQSHIFT_FILTER 1
%define CONFIG_AFWTDN_FILTER 1
%define CONFIG_AGATE_FILTER 1
%define CONFIG_AIIR_FILTER 1
%define CONFIG_AINTEGRAL_FILTER 1
%define CONFIG_AINTERLEAVE_FILTER 1
%define CONFIG_ALATENCY_FILTER 1
%define CONFIG_ALIMITER_FILTER 1
%define CONFIG_ALLPASS_FILTER 1
%define CONFIG_ALOOP_FILTER 1
%define CONFIG_AMERGE_FILTER 1
%define CONFIG_AMETADATA_FILTER 1
%define CONFIG_AMIX_FILTER 1
%define CONFIG_AMULTIPLY_FILTER 1
%define CONFIG_ANEQUALIZER_FILTER 1
%define CONFIG_ANLMDN_FILTER 1
%define CONFIG_ANLMF_FILTER 1
%define CONFIG_ANLMS_FILTER 1
%define CONFIG_ANULL_FILTER 1
%define CONFIG_APAD_FILTER 1
%define CONFIG_APERMS_FILTER 1
%define CONFIG_APHASER_FILTER 1
%define CONFIG_APHASESHIFT_FILTER 1
%define CONFIG_APSNR_FILTER 1
%define CONFIG_APSYCLIP_FILTER 1
%define CONFIG_APULSATOR_FILTER 1
%define CONFIG_AREALTIME_FILTER 1
%define CONFIG_ARESAMPLE_FILTER 1
%define CONFIG_AREVERSE_FILTER 1
%define CONFIG_ARLS_FILTER 1
%define CONFIG_ARNNDN_FILTER 1
%define CONFIG_ASDR_FILTER 1
%define CONFIG_ASEGMENT_FILTER 1
%define CONFIG_ASELECT_FILTER 1
%define CONFIG_ASENDCMD_FILTER 1
%define CONFIG_ASETNSAMPLES_FILTER 1
%define CONFIG_ASETPTS_FILTER 1
%define CONFIG_ASETRATE_FILTER 1
%define CONFIG_ASETTB_FILTER 1
%define CONFIG_ASHOWINFO_FILTER 1
%define CONFIG_ASIDEDATA_FILTER 1
%define CONFIG_ASISDR_FILTER 1
%define CONFIG_ASOFTCLIP_FILTER 1
%define CONFIG_ASPECTRALSTATS_FILTER 1
%define CONFIG_ASPLIT_FILTER 1
%define CONFIG_ASR_FILTER 0
%define CONFIG_ASTATS_FILTER 1
%define CONFIG_ASTREAMSELECT_FILTER 1
%define CONFIG_ASUBBOOST_FILTER 1
%define CONFIG_ASUBCUT_FILTER 1
%define CONFIG_ASUPERCUT_FILTER 1
%define CONFIG_ASUPERPASS_FILTER 1
%define CONFIG_ASUPERSTOP_FILTER 1
%define CONFIG_ATEMPO_FILTER 1
%define CONFIG_ATILT_FILTER 1
%define CONFIG_ATRIM_FILTER 1
%define CONFIG_AXCORRELATE_FILTER 1
%define CONFIG_AZMQ_FILTER 0
%define CONFIG_BANDPASS_FILTER 1
%define CONFIG_BANDREJECT_FILTER 1
%define CONFIG_BASS_FILTER 1
%define CONFIG_BIQUAD_FILTER 1
%define CONFIG_BS2B_FILTER 0
%define CONFIG_CHANNELMAP_FILTER 1
%define CONFIG_CHANNELSPLIT_FILTER 1
%define CONFIG_CHORUS_FILTER 1
%define CONFIG_COMPAND_FILTER 1
%define CONFIG_COMPENSATIONDELAY_FILTER 1
%define CONFIG_CROSSFEED_FILTER 1
%define CONFIG_CRYSTALIZER_FILTER 1
%define CONFIG_DCSHIFT_FILTER 1
%define CONFIG_DEESSER_FILTER 1
%define CONFIG_DIALOGUENHANCE_FILTER 1
%define CONFIG_DRMETER_FILTER 1
%define CONFIG_DYNAUDNORM_FILTER 1
%define CONFIG_EARWAX_FILTER 1
%define CONFIG_EBUR128_FILTER 1
%define CONFIG_EQUALIZER_FILTER 1
%define CONFIG_EXTRASTEREO_FILTER 1
%define CONFIG_FIREQUALIZER_FILTER 1
%define CONFIG_FLANGER_FILTER 1
%define CONFIG_HAAS_FILTER 1
%define CONFIG_HDCD_FILTER 1
%define CONFIG_HEADPHONE_FILTER 1
%define CONFIG_HIGHPASS_FILTER 1
%define CONFIG_HIGHSHELF_FILTER 1
%define CONFIG_JOIN_FILTER 1
%define CONFIG_LADSPA_FILTER 0
%define CONFIG_LOUDNORM_FILTER 1
%define CONFIG_LOWPASS_FILTER 1
%define CONFIG_LOWSHELF_FILTER 1
%define CONFIG_LV2_FILTER 0
%define CONFIG_MCOMPAND_FILTER 1
%define CONFIG_PAN_FILTER 1
%define CONFIG_REPLAYGAIN_FILTER 1
%define CONFIG_RUBBERBAND_FILTER 0
%define CONFIG_SIDECHAINCOMPRESS_FILTER 1
%define CONFIG_SIDECHAINGATE_FILTER 1
%define CONFIG_SILENCEDETECT_FILTER 1
%define CONFIG_SILENCEREMOVE_FILTER 1
%define CONFIG_SOFALIZER_FILTER 0
%define CONFIG_SPEECHNORM_FILTER 1
%define CONFIG_STEREOTOOLS_FILTER 1
%define CONFIG_STEREOWIDEN_FILTER 1
%define CONFIG_SUPEREQUALIZER_FILTER 1
%define CONFIG_SURROUND_FILTER 1
%define CONFIG_TILTSHELF_FILTER 1
%define CONFIG_TREBLE_FILTER 1
%define CONFIG_TREMOLO_FILTER 1
%define CONFIG_VIBRATO_FILTER 1
%define CONFIG_VIRTUALBASS_FILTER 1
%define CONFIG_VOLUME_FILTER 1
%define CONFIG_VOLUMEDETECT_FILTER 1
%define CONFIG_WHISPER_FILTER 0
%define CONFIG_AEVALSRC_FILTER 1
%define CONFIG_AFDELAYSRC_FILTER 1
%define CONFIG_AFIREQSRC_FILTER 1
%define CONFIG_AFIRSRC_FILTER 1
%define CONFIG_ANOISESRC_FILTER 1
%define CONFIG_ANULLSRC_FILTER 1
%define CONFIG_FLITE_FILTER 0
%define CONFIG_HILBERT_FILTER 1
%define CONFIG_SINC_FILTER 1
%define CONFIG_SINE_FILTER 1
%define CONFIG_ANULLSINK_FILTER 1
%define CONFIG_ADDROI_FILTER 1
%define CONFIG_ALPHAEXTRACT_FILTER 1
%define CONFIG_ALPHAMERGE_FILTER 1
%define CONFIG_AMPLIFY_FILTER 1
%define CONFIG_ASS_FILTER 0
%define CONFIG_ATADENOISE_FILTER 1
%define CONFIG_AVGBLUR_FILTER 1
%define CONFIG_AVGBLUR_OPENCL_FILTER 0
%define CONFIG_AVGBLUR_VULKAN_FILTER 0
%define CONFIG_BACKGROUNDKEY_FILTER 1
%define CONFIG_BBOX_FILTER 1
%define CONFIG_BENCH_FILTER 1
%define CONFIG_BILATERAL_FILTER 1
%define CONFIG_BILATERAL_CUDA_FILTER 0
%define CONFIG_BITPLANENOISE_FILTER 1
%define CONFIG_BLACKDETECT_FILTER 1
%define CONFIG_BLACKDETECT_VULKAN_FILTER 0
%define CONFIG_BLACKFRAME_FILTER 0
%define CONFIG_BLEND_FILTER 1
%define CONFIG_BLEND_VULKAN_FILTER 0
%define CONFIG_BLOCKDETECT_FILTER 1
%define CONFIG_BLURDETECT_FILTER 1
%define CONFIG_BM3D_FILTER 1
%define CONFIG_BOXBLUR_FILTER 0
%define CONFIG_BOXBLUR_OPENCL_FILTER 0
%define CONFIG_BWDIF_FILTER 1
%define CONFIG_BWDIF_CUDA_FILTER 0
%define CONFIG_BWDIF_VULKAN_FILTER 0
%define CONFIG_CAS_FILTER 1
%define CONFIG_CCREPACK_FILTER 1
%define CONFIG_CHROMABER_VULKAN_FILTER 0
%define CONFIG_CHROMAHOLD_FILTER 1
%define CONFIG_CHROMAKEY_FILTER 1
%define CONFIG_CHROMAKEY_CUDA_FILTER 0
%define CONFIG_CHROMANR_FILTER 1
%define CONFIG_CHROMASHIFT_FILTER 1
%define CONFIG_CIESCOPE_FILTER 1
%define CONFIG_CODECVIEW_FILTER 1
%define CONFIG_COLORBALANCE_FILTER 1
%define CONFIG_COLORCHANNELMIXER_FILTER 1
%define CONFIG_COLORCONTRAST_FILTER 1
%define CONFIG_COLORCORRECT_FILTER 1
%define CONFIG_COLORDETECT_FILTER 1
%define CONFIG_COLORIZE_FILTER 1
%define CONFIG_COLORKEY_FILTER 1
%define CONFIG_COLORKEY_OPENCL_FILTER 0
%define CONFIG_COLORHOLD_FILTER 1
%define CONFIG_COLORLEVELS_FILTER 1
%define CONFIG_COLORMAP_FILTER 1
%define CONFIG_COLORMATRIX_FILTER 0
%define CONFIG_COLORSPACE_FILTER 1
%define CONFIG_COLORSPACE_CUDA_FILTER 0
%define CONFIG_COLORTEMPERATURE_FILTER 1
%define CONFIG_CONVOLUTION_FILTER 1
%define CONFIG_CONVOLUTION_OPENCL_FILTER 0
%define CONFIG_CONVOLVE_FILTER 1
%define CONFIG_COPY_FILTER 1
%define CONFIG_COREIMAGE_FILTER 0
%define CONFIG_CORR_FILTER 1
%define CONFIG_COVER_RECT_FILTER 0
%define CONFIG_CROP_FILTER 1
%define CONFIG_CROPDETECT_FILTER 0
%define CONFIG_CUE_FILTER 1
%define CONFIG_CURVES_FILTER 1
%define CONFIG_DATASCOPE_FILTER 1
%define CONFIG_DBLUR_FILTER 1
%define CONFIG_DCTDNOIZ_FILTER 1
%define CONFIG_DEBAND_FILTER 1
%define CONFIG_DEBLOCK_FILTER 1
%define CONFIG_DECIMATE_FILTER 1
%define CONFIG_DECONVOLVE_FILTER 1
%define CONFIG_DEDOT_FILTER 1
%define CONFIG_DEFLATE_FILTER 1
%define CONFIG_DEFLICKER_FILTER 1
%define CONFIG_DEINTERLACE_QSV_FILTER 0
%define CONFIG_DEINTERLACE_D3D12_FILTER 0
%define CONFIG_DEINTERLACE_VAAPI_FILTER 0
%define CONFIG_DEJUDDER_FILTER 1
%define CONFIG_DELOGO_FILTER 0
%define CONFIG_DENOISE_VAAPI_FILTER 0
%define CONFIG_DERAIN_FILTER 0
%define CONFIG_DESHAKE_FILTER 1
%define CONFIG_DESHAKE_OPENCL_FILTER 0
%define CONFIG_DESPILL_FILTER 1
%define CONFIG_DETELECINE_FILTER 1
%define CONFIG_DILATION_FILTER 1
%define CONFIG_DILATION_OPENCL_FILTER 0
%define CONFIG_DISPLACE_FILTER 1
%define CONFIG_DNN_CLASSIFY_FILTER 0
%define CONFIG_DNN_DETECT_FILTER 0
%define CONFIG_DNN_PROCESSING_FILTER 0
%define CONFIG_DOUBLEWEAVE_FILTER 1
%define CONFIG_DRAWBOX_FILTER 1
%define CONFIG_DRAWGRAPH_FILTER 1
%define CONFIG_DRAWGRID_FILTER 1
%define CONFIG_DRAWTEXT_FILTER 0
%define CONFIG_DRAWVG_FILTER 0
%define CONFIG_EDGEDETECT_FILTER 1
%define CONFIG_ELBG_FILTER 1
%define CONFIG_ENTROPY_FILTER 1
%define CONFIG_EPX_FILTER 1
%define CONFIG_EQ_FILTER 0
%define CONFIG_EROSION_FILTER 1
%define CONFIG_EROSION_OPENCL_FILTER 0
%define CONFIG_ESTDIF_FILTER 1
%define CONFIG_EXPOSURE_FILTER 1
%define CONFIG_EXTRACTPLANES_FILTER 1
%define CONFIG_FADE_FILTER 1
%define CONFIG_FEEDBACK_FILTER 1
%define CONFIG_FFTDNOIZ_FILTER 1
%define CONFIG_FFTFILT_FILTER 1
%define CONFIG_FIELD_FILTER 1
%define CONFIG_FIELDHINT_FILTER 1
%define CONFIG_FIELDMATCH_FILTER 1
%define CONFIG_FIELDORDER_FILTER 1
%define CONFIG_FILLBORDERS_FILTER 1
%define CONFIG_FIND_RECT_FILTER 0
%define CONFIG_FLIP_VULKAN_FILTER 0
%define CONFIG_FLOODFILL_FILTER 1
%define CONFIG_FORMAT_FILTER 1
%define CONFIG_FPS_FILTER 1
%define CONFIG_FRAMEPACK_FILTER 1
%define CONFIG_FRAMERATE_FILTER 1
%define CONFIG_FRAMESTEP_FILTER 1
%define CONFIG_FREEZEDETECT_FILTER 1
%define CONFIG_FREEZEFRAMES_FILTER 1
%define CONFIG_FREI0R_FILTER 0
%define CONFIG_FSPP_FILTER 0
%define CONFIG_FSYNC_FILTER 1
%define CONFIG_GBLUR_FILTER 1
%define CONFIG_GBLUR_VULKAN_FILTER 0
%define CONFIG_GEQ_FILTER 1
%define CONFIG_GRADFUN_FILTER 1
%define CONFIG_GRAPHMONITOR_FILTER 1
%define CONFIG_GRAYWORLD_FILTER 1
%define CONFIG_GREYEDGE_FILTER 1
%define CONFIG_GUIDED_FILTER 1
%define CONFIG_HALDCLUT_FILTER 1
%define CONFIG_HFLIP_FILTER 1
%define CONFIG_HFLIP_VULKAN_FILTER 0
%define CONFIG_HISTEQ_FILTER 0
%define CONFIG_HISTOGRAM_FILTER 1
%define CONFIG_HQDN3D_FILTER 0
%define CONFIG_HQX_FILTER 1
%define CONFIG_HSTACK_FILTER 1
%define CONFIG_HSVHOLD_FILTER 1
%define CONFIG_HSVKEY_FILTER 1
%define CONFIG_HUE_FILTER 1
%define CONFIG_HUESATURATION_FILTER 1
%define CONFIG_HWDOWNLOAD_FILTER 1
%define CONFIG_HWMAP_FILTER 1
%define CONFIG_HWUPLOAD_FILTER 1
%define CONFIG_HWUPLOAD_CUDA_FILTER 0
%define CONFIG_HYSTERESIS_FILTER 1
%define CONFIG_ICCDETECT_FILTER 0
%define CONFIG_ICCGEN_FILTER 0
%define CONFIG_IDENTITY_FILTER 1
%define CONFIG_IDET_FILTER 1
%define CONFIG_IL_FILTER 1
%define CONFIG_INFLATE_FILTER 1
%define CONFIG_INTERLACE_FILTER 0
%define CONFIG_INTERLACE_VULKAN_FILTER 0
%define CONFIG_INTERLEAVE_FILTER 1
%define CONFIG_KERNDEINT_FILTER 0
%define CONFIG_KIRSCH_FILTER 1
%define CONFIG_LAGFUN_FILTER 1
%define CONFIG_LATENCY_FILTER 1
%define CONFIG_LCEVC_FILTER 0
%define CONFIG_LENSCORRECTION_FILTER 1
%define CONFIG_LENSFUN_FILTER 0
%define CONFIG_LIBPLACEBO_FILTER 0
%define CONFIG_LIBVMAF_FILTER 0
%define CONFIG_LIBVMAF_CUDA_FILTER 0
%define CONFIG_LIMITDIFF_FILTER 1
%define CONFIG_LIMITER_FILTER 1
%define CONFIG_LOOP_FILTER 1
%define CONFIG_LUMAKEY_FILTER 1
%define CONFIG_LUT_FILTER 1
%define CONFIG_LUT1D_FILTER 1
%define CONFIG_LUT2_FILTER 1
%define CONFIG_LUT3D_FILTER 1
%define CONFIG_LUTRGB_FILTER 1
%define CONFIG_LUTYUV_FILTER 1
%define CONFIG_MASKEDCLAMP_FILTER 1
%define CONFIG_MASKEDMAX_FILTER 1
%define CONFIG_MASKEDMERGE_FILTER 1
%define CONFIG_MASKEDMIN_FILTER 1
%define CONFIG_MASKEDTHRESHOLD_FILTER 1
%define CONFIG_MASKFUN_FILTER 1
%define CONFIG_MCDEINT_FILTER 0
%define CONFIG_MEDIAN_FILTER 1
%define CONFIG_MERGEPLANES_FILTER 1
%define CONFIG_MESTIMATE_FILTER 1
%define CONFIG_MESTIMATE_D3D12_FILTER 0
%define CONFIG_METADATA_FILTER 1
%define CONFIG_MIDEQUALIZER_FILTER 1
%define CONFIG_MINTERPOLATE_FILTER 1
%define CONFIG_MIX_FILTER 1
%define CONFIG_MONOCHROME_FILTER 1
%define CONFIG_MORPHO_FILTER 1
%define CONFIG_MPDECIMATE_FILTER 0
%define CONFIG_MSAD_FILTER 1
%define CONFIG_MULTIPLY_FILTER 1
%define CONFIG_NEGATE_FILTER 1
%define CONFIG_NLMEANS_FILTER 1
%define CONFIG_NLMEANS_OPENCL_FILTER 0
%define CONFIG_NLMEANS_VULKAN_FILTER 0
%define CONFIG_NNEDI_FILTER 0
%define CONFIG_NOFORMAT_FILTER 1
%define CONFIG_NOISE_FILTER 1
%define CONFIG_NORMALIZE_FILTER 1
%define CONFIG_NULL_FILTER 1
%define CONFIG_OCR_FILTER 0
%define CONFIG_OCV_FILTER 0
%define CONFIG_OSCILLOSCOPE_FILTER 1
%define CONFIG_OCIO_FILTER 0
%define CONFIG_OVERLAY_FILTER 1
%define CONFIG_OVERLAY_OPENCL_FILTER 0
%define CONFIG_OVERLAY_QSV_FILTER 0
%define CONFIG_OVERLAY_VAAPI_FILTER 0
%define CONFIG_OVERLAY_VULKAN_FILTER 0
%define CONFIG_OVERLAY_CUDA_FILTER 0
%define CONFIG_OWDENOISE_FILTER 0
%define CONFIG_PAD_FILTER 1
%define CONFIG_PAD_CUDA_FILTER 0
%define CONFIG_PAD_OPENCL_FILTER 0
%define CONFIG_PALETTEGEN_FILTER 1
%define CONFIG_PALETTEUSE_FILTER 1
%define CONFIG_PERMS_FILTER 1
%define CONFIG_PERSPECTIVE_FILTER 0
%define CONFIG_PHASE_FILTER 0
%define CONFIG_PHOTOSENSITIVITY_FILTER 1
%define CONFIG_PIXDESCTEST_FILTER 1
%define CONFIG_PIXELIZE_FILTER 1
%define CONFIG_PIXSCOPE_FILTER 1
%define CONFIG_PP7_FILTER 0
%define CONFIG_PREMULTIPLY_FILTER 1
%define CONFIG_PREMULTIPLY_DYNAMIC_FILTER 1
%define CONFIG_PREWITT_FILTER 1
%define CONFIG_PREWITT_OPENCL_FILTER 0
%define CONFIG_PROCAMP_VAAPI_FILTER 0
%define CONFIG_PROGRAM_OPENCL_FILTER 0
%define CONFIG_PSEUDOCOLOR_FILTER 1
%define CONFIG_PSNR_FILTER 1
%define CONFIG_PULLUP_FILTER 0
%define CONFIG_QP_FILTER 1
%define CONFIG_QRENCODE_FILTER 0
%define CONFIG_QUIRC_FILTER 0
%define CONFIG_RANDOM_FILTER 1
%define CONFIG_READEIA608_FILTER 1
%define CONFIG_READVITC_FILTER 1
%define CONFIG_REALTIME_FILTER 1
%define CONFIG_REMAP_FILTER 1
%define CONFIG_REMAP_OPENCL_FILTER 0
%define CONFIG_REMOVEGRAIN_FILTER 1
%define CONFIG_REMOVELOGO_FILTER 1
%define CONFIG_REPEATFIELDS_FILTER 0
%define CONFIG_REVERSE_FILTER 1
%define CONFIG_RGBASHIFT_FILTER 1
%define CONFIG_ROBERTS_FILTER 1
%define CONFIG_ROBERTS_OPENCL_FILTER 0
%define CONFIG_ROTATE_FILTER 1
%define CONFIG_SAB_FILTER 0
%define CONFIG_SCALE_FILTER 1
%define CONFIG_VPP_AMF_FILTER 0
%define CONFIG_SR_AMF_FILTER 0
%define CONFIG_SCALE_CUDA_FILTER 0
%define CONFIG_SCALE_D3D11_FILTER 0
%define CONFIG_SCALE_D3D12_FILTER 0
%define CONFIG_SCALE_NPP_FILTER 0
%define CONFIG_SCALE_QSV_FILTER 0
%define CONFIG_SCALE_VAAPI_FILTER 0
%define CONFIG_SCALE_VT_FILTER 0
%define CONFIG_SCALE_VULKAN_FILTER 0
%define CONFIG_SCALE2REF_FILTER 1
%define CONFIG_SCALE2REF_NPP_FILTER 0
%define CONFIG_SCDET_FILTER 1
%define CONFIG_SCDET_VULKAN_FILTER 0
%define CONFIG_SCHARR_FILTER 1
%define CONFIG_SCROLL_FILTER 1
%define CONFIG_SEGMENT_FILTER 1
%define CONFIG_SELECT_FILTER 1
%define CONFIG_SELECTIVECOLOR_FILTER 1
%define CONFIG_SENDCMD_FILTER 1
%define CONFIG_SEPARATEFIELDS_FILTER 1
%define CONFIG_SETDAR_FILTER 1
%define CONFIG_SETFIELD_FILTER 1
%define CONFIG_SETPARAMS_FILTER 1
%define CONFIG_SETPTS_FILTER 1
%define CONFIG_SETRANGE_FILTER 1
%define CONFIG_SETSAR_FILTER 1
%define CONFIG_SETTB_FILTER 1
%define CONFIG_SHARPEN_NPP_FILTER 0
%define CONFIG_SHARPNESS_VAAPI_FILTER 0
%define CONFIG_SHEAR_FILTER 1
%define CONFIG_SHOWINFO_FILTER 1
%define CONFIG_SHOWPALETTE_FILTER 1
%define CONFIG_SHUFFLEFRAMES_FILTER 1
%define CONFIG_SHUFFLEPIXELS_FILTER 1
%define CONFIG_SHUFFLEPLANES_FILTER 1
%define CONFIG_SIDEDATA_FILTER 1
%define CONFIG_SIGNALSTATS_FILTER 1
%define CONFIG_SIGNATURE_FILTER 0
%define CONFIG_SITI_FILTER 1
%define CONFIG_SMARTBLUR_FILTER 0
%define CONFIG_SOBEL_FILTER 1
%define CONFIG_SOBEL_OPENCL_FILTER 0
%define CONFIG_SPLIT_FILTER 1
%define CONFIG_SPP_FILTER 0
%define CONFIG_SR_FILTER 0
%define CONFIG_SSIM_FILTER 1
%define CONFIG_SSIM360_FILTER 1
%define CONFIG_STEREO3D_FILTER 0
%define CONFIG_STREAMSELECT_FILTER 1
%define CONFIG_SUBTITLES_FILTER 0
%define CONFIG_SUPER2XSAI_FILTER 0
%define CONFIG_SWAPRECT_FILTER 1
%define CONFIG_SWAPUV_FILTER 1
%define CONFIG_TBLEND_FILTER 1
%define CONFIG_TELECINE_FILTER 1
%define CONFIG_THISTOGRAM_FILTER 1
%define CONFIG_THRESHOLD_FILTER 1
%define CONFIG_THUMBNAIL_FILTER 1
%define CONFIG_THUMBNAIL_CUDA_FILTER 0
%define CONFIG_TILE_FILTER 1
%define CONFIG_TILTANDSHIFT_FILTER 1
%define CONFIG_TINTERLACE_FILTER 0
%define CONFIG_TLUT2_FILTER 1
%define CONFIG_TMEDIAN_FILTER 1
%define CONFIG_TMIDEQUALIZER_FILTER 1
%define CONFIG_TMIX_FILTER 1
%define CONFIG_TONEMAP_FILTER 1
%define CONFIG_TONEMAP_OPENCL_FILTER 0
%define CONFIG_TONEMAP_VAAPI_FILTER 0
%define CONFIG_TPAD_FILTER 1
%define CONFIG_TRANSPOSE_FILTER 1
%define CONFIG_TRANSPOSE_NPP_FILTER 0
%define CONFIG_TRANSPOSE_OPENCL_FILTER 0
%define CONFIG_TRANSPOSE_VAAPI_FILTER 0
%define CONFIG_TRANSPOSE_VT_FILTER 0
%define CONFIG_TRANSPOSE_VULKAN_FILTER 0
%define CONFIG_TRIM_FILTER 1
%define CONFIG_UNPREMULTIPLY_FILTER 1
%define CONFIG_UNSHARP_FILTER 1
%define CONFIG_UNSHARP_OPENCL_FILTER 0
%define CONFIG_UNTILE_FILTER 1
%define CONFIG_USPP_FILTER 0
%define CONFIG_V360_FILTER 1
%define CONFIG_VAGUEDENOISER_FILTER 0
%define CONFIG_VARBLUR_FILTER 1
%define CONFIG_VECTORSCOPE_FILTER 1
%define CONFIG_VFLIP_FILTER 1
%define CONFIG_VFLIP_VULKAN_FILTER 0
%define CONFIG_VFRDET_FILTER 1
%define CONFIG_VIBRANCE_FILTER 1
%define CONFIG_VIDSTABDETECT_FILTER 0
%define CONFIG_VIDSTABTRANSFORM_FILTER 0
%define CONFIG_VIF_FILTER 1
%define CONFIG_VIGNETTE_FILTER 1
%define CONFIG_VMAFMOTION_FILTER 1
%define CONFIG_VPP_QSV_FILTER 0
%define CONFIG_VSTACK_FILTER 1
%define CONFIG_W3FDIF_FILTER 1
%define CONFIG_WAVEFORM_FILTER 1
%define CONFIG_WEAVE_FILTER 1
%define CONFIG_XBR_FILTER 1
%define CONFIG_XCORRELATE_FILTER 1
%define CONFIG_XFADE_FILTER 1
%define CONFIG_XFADE_OPENCL_FILTER 0
%define CONFIG_XFADE_VULKAN_FILTER 0
%define CONFIG_XMEDIAN_FILTER 1
%define CONFIG_XPSNR_FILTER 1
%define CONFIG_XSTACK_FILTER 1
%define CONFIG_YADIF_FILTER 1
%define CONFIG_YADIF_CUDA_FILTER 0
%define CONFIG_YADIF_VIDEOTOOLBOX_FILTER 0
%define CONFIG_YAEPBLUR_FILTER 1
%define CONFIG_ZMQ_FILTER 0
%define CONFIG_ZOOMPAN_FILTER 1
%define CONFIG_ZSCALE_FILTER 0
%define CONFIG_HSTACK_VAAPI_FILTER 0
%define CONFIG_VSTACK_VAAPI_FILTER 0
%define CONFIG_XSTACK_VAAPI_FILTER 0
%define CONFIG_HSTACK_QSV_FILTER 0
%define CONFIG_VSTACK_QSV_FILTER 0
%define CONFIG_XSTACK_QSV_FILTER 0
%define CONFIG_PAD_VAAPI_FILTER 0
%define CONFIG_DRAWBOX_VAAPI_FILTER 0
%define CONFIG_ALLRGB_FILTER 1
%define CONFIG_ALLYUV_FILTER 1
%define CONFIG_AMF_CAPTURE_FILTER 0
%define CONFIG_CELLAUTO_FILTER 1
%define CONFIG_COLOR_FILTER 1
%define CONFIG_COLOR_VULKAN_FILTER 0
%define CONFIG_COLORCHART_FILTER 1
%define CONFIG_COLORSPECTRUM_FILTER 1
%define CONFIG_COREIMAGESRC_FILTER 0
%define CONFIG_DDAGRAB_FILTER 0
%define CONFIG_FREI0R_SRC_FILTER 0
%define CONFIG_GFXCAPTURE_FILTER 0
%define CONFIG_GRADIENTS_FILTER 1
%define CONFIG_HALDCLUTSRC_FILTER 1
%define CONFIG_LIFE_FILTER 1
%define CONFIG_MANDELBROT_FILTER 1
%define CONFIG_MPTESTSRC_FILTER 0
%define CONFIG_NULLSRC_FILTER 1
%define CONFIG_OPENCLSRC_FILTER 0
%define CONFIG_QRENCODESRC_FILTER 0
%define CONFIG_PAL75BARS_FILTER 1
%define CONFIG_PAL100BARS_FILTER 1
%define CONFIG_PERLIN_FILTER 1
%define CONFIG_RGBTESTSRC_FILTER 1
%define CONFIG_SIERPINSKI_FILTER 1
%define CONFIG_SMPTEBARS_FILTER 1
%define CONFIG_SMPTEHDBARS_FILTER 1
%define CONFIG_TESTSRC_FILTER 1
%define CONFIG_TESTSRC2_FILTER 1
%define CONFIG_YUVTESTSRC_FILTER 1
%define CONFIG_ZONEPLATE_FILTER 1
%define CONFIG_NULLSINK_FILTER 1
%define CONFIG_A3DSCOPE_FILTER 1
%define CONFIG_ABITSCOPE_FILTER 1
%define CONFIG_ADRAWGRAPH_FILTER 1
%define CONFIG_AGRAPHMONITOR_FILTER 1
%define CONFIG_AHISTOGRAM_FILTER 1
%define CONFIG_APHASEMETER_FILTER 1
%define CONFIG_AVECTORSCOPE_FILTER 1
%define CONFIG_CONCAT_FILTER 1
%define CONFIG_SHOWCQT_FILTER 1
%define CONFIG_SHOWCWT_FILTER 1
%define CONFIG_SHOWFREQS_FILTER 1
%define CONFIG_SHOWSPATIAL_FILTER 1
%define CONFIG_SHOWSPECTRUM_FILTER 1
%define CONFIG_SHOWSPECTRUMPIC_FILTER 1
%define CONFIG_SHOWVOLUME_FILTER 1
%define CONFIG_SHOWWAVES_FILTER 1
%define CONFIG_SHOWWAVESPIC_FILTER 1
%define CONFIG_SPECTRUMSYNTH_FILTER 1
%define CONFIG_AVSYNCTEST_FILTER 1
%define CONFIG_AMOVIE_FILTER 1
%define CONFIG_MOVIE_FILTER 1
%define CONFIG_AA_DEMUXER 1
%define CONFIG_AAC_DEMUXER 1
%define CONFIG_AAX_DEMUXER 1
%define CONFIG_AC3_DEMUXER 1
%define CONFIG_AC4_DEMUXER 1
%define CONFIG_ACE_DEMUXER 1
%define CONFIG_ACM_DEMUXER 1
%define CONFIG_ACT_DEMUXER 1
%define CONFIG_ADF_DEMUXER 1
%define CONFIG_ADP_DEMUXER 1
%define CONFIG_ADS_DEMUXER 1
%define CONFIG_ADX_DEMUXER 1
%define CONFIG_AEA_DEMUXER 1
%define CONFIG_AFC_DEMUXER 1
%define CONFIG_AIFF_DEMUXER 1
%define CONFIG_AIX_DEMUXER 1
%define CONFIG_ALP_DEMUXER 1
%define CONFIG_AMR_DEMUXER 1
%define CONFIG_AMRNB_DEMUXER 1
%define CONFIG_AMRWB_DEMUXER 1
%define CONFIG_ANM_DEMUXER 1
%define CONFIG_APAC_DEMUXER 1
%define CONFIG_APC_DEMUXER 1
%define CONFIG_APE_DEMUXER 1
%define CONFIG_APM_DEMUXER 1
%define CONFIG_APNG_DEMUXER 1
%define CONFIG_APTX_DEMUXER 1
%define CONFIG_APTX_HD_DEMUXER 1
%define CONFIG_APV_DEMUXER 1
%define CONFIG_AQTITLE_DEMUXER 1
%define CONFIG_ARGO_ASF_DEMUXER 1
%define CONFIG_ARGO_BRP_DEMUXER 1
%define CONFIG_ARGO_CVG_DEMUXER 1
%define CONFIG_ASF_DEMUXER 1
%define CONFIG_ASF_O_DEMUXER 1
%define CONFIG_ASS_DEMUXER 1
%define CONFIG_AST_DEMUXER 1
%define CONFIG_AU_DEMUXER 1
%define CONFIG_AV1_DEMUXER 1
%define CONFIG_AVI_DEMUXER 1
%define CONFIG_AVR_DEMUXER 1
%define CONFIG_AVS_DEMUXER 1
%define CONFIG_AVS2_DEMUXER 1
%define CONFIG_AVS3_DEMUXER 1
%define CONFIG_BETHSOFTVID_DEMUXER 1
%define CONFIG_BFI_DEMUXER 1
%define CONFIG_BINTEXT_DEMUXER 1
%define CONFIG_BINK_DEMUXER 1
%define CONFIG_BINKA_DEMUXER 1
%define CONFIG_BIT_DEMUXER 1
%define CONFIG_BITPACKED_DEMUXER 1
%define CONFIG_BMV_DEMUXER 1
%define CONFIG_BFSTM_DEMUXER 1
%define CONFIG_BRSTM_DEMUXER 1
%define CONFIG_BOA_DEMUXER 1
%define CONFIG_BONK_DEMUXER 1
%define CONFIG_C93_DEMUXER 1
%define CONFIG_CAF_DEMUXER 1
%define CONFIG_CAVSVIDEO_DEMUXER 1
%define CONFIG_CDG_DEMUXER 1
%define CONFIG_CDXL_DEMUXER 1
%define CONFIG_CINE_DEMUXER 1
%define CONFIG_CODEC2_DEMUXER 1
%define CONFIG_CODEC2RAW_DEMUXER 1
%define CONFIG_CONCAT_DEMUXER 1
%define CONFIG_DASH_DEMUXER 0
%define CONFIG_DATA_DEMUXER 1
%define CONFIG_DAUD_DEMUXER 1
%define CONFIG_DCSTR_DEMUXER 1
%define CONFIG_DERF_DEMUXER 1
%define CONFIG_DFA_DEMUXER 1
%define CONFIG_DFPWM_DEMUXER 1
%define CONFIG_DHAV_DEMUXER 1
%define CONFIG_DIRAC_DEMUXER 1
%define CONFIG_DNXHD_DEMUXER 1
%define CONFIG_DSF_DEMUXER 1
%define CONFIG_DSICIN_DEMUXER 1
%define CONFIG_DSS_DEMUXER 1
%define CONFIG_DTS_DEMUXER 1
%define CONFIG_DTSHD_DEMUXER 1
%define CONFIG_DV_DEMUXER 1
%define CONFIG_DVBSUB_DEMUXER 1
%define CONFIG_DVBTXT_DEMUXER 1
%define CONFIG_DXA_DEMUXER 1
%define CONFIG_EA_DEMUXER 1
%define CONFIG_EA_CDATA_DEMUXER 1
%define CONFIG_EAC3_DEMUXER 1
%define CONFIG_EPAF_DEMUXER 1
%define CONFIG_EVC_DEMUXER 1
%define CONFIG_FFMETADATA_DEMUXER 1
%define CONFIG_FILMSTRIP_DEMUXER 1
%define CONFIG_FITS_DEMUXER 1
%define CONFIG_FLAC_DEMUXER 1
%define CONFIG_FLIC_DEMUXER 1
%define CONFIG_FLV_DEMUXER 1
%define CONFIG_LIVE_FLV_DEMUXER 1
%define CONFIG_FOURXM_DEMUXER 1
%define CONFIG_FRM_DEMUXER 1
%define CONFIG_FSB_DEMUXER 1
%define CONFIG_FWSE_DEMUXER 1
%define CONFIG_G722_DEMUXER 1
%define CONFIG_G723_1_DEMUXER 1
%define CONFIG_G726_DEMUXER 1
%define CONFIG_G726LE_DEMUXER 1
%define CONFIG_G728_DEMUXER 1
%define CONFIG_G729_DEMUXER 1
%define CONFIG_GDV_DEMUXER 1
%define CONFIG_GENH_DEMUXER 1
%define CONFIG_GIF_DEMUXER 1
%define CONFIG_GSM_DEMUXER 1
%define CONFIG_GXF_DEMUXER 1
%define CONFIG_H261_DEMUXER 1
%define CONFIG_H263_DEMUXER 1
%define CONFIG_H264_DEMUXER 1
%define CONFIG_HCA_DEMUXER 1
%define CONFIG_HCOM_DEMUXER 1
%define CONFIG_HEVC_DEMUXER 1
%define CONFIG_HLS_DEMUXER 1
%define CONFIG_HNM_DEMUXER 1
%define CONFIG_HXVS_DEMUXER 1
%define CONFIG_IAMF_DEMUXER 1
%define CONFIG_ICO_DEMUXER 1
%define CONFIG_IDCIN_DEMUXER 1
%define CONFIG_IDF_DEMUXER 1
%define CONFIG_IFF_DEMUXER 1
%define CONFIG_IFV_DEMUXER 1
%define CONFIG_ILBC_DEMUXER 1
%define CONFIG_IMAGE2_DEMUXER 1
%define CONFIG_IMAGE2PIPE_DEMUXER 1
%define CONFIG_IMAGE2_ALIAS_PIX_DEMUXER 1
%define CONFIG_IMAGE2_BRENDER_PIX_DEMUXER 1
%define CONFIG_IMF_DEMUXER 0
%define CONFIG_INGENIENT_DEMUXER 1
%define CONFIG_IPMOVIE_DEMUXER 1
%define CONFIG_IPU_DEMUXER 1
%define CONFIG_IRCAM_DEMUXER 1
%define CONFIG_ISS_DEMUXER 1
%define CONFIG_IV8_DEMUXER 1
%define CONFIG_IVF_DEMUXER 1
%define CONFIG_IVR_DEMUXER 1
%define CONFIG_JACOSUB_DEMUXER 1
%define CONFIG_JV_DEMUXER 1
%define CONFIG_JPEGXL_ANIM_DEMUXER 1
%define CONFIG_KUX_DEMUXER 1
%define CONFIG_KVAG_DEMUXER 1
%define CONFIG_LAF_DEMUXER 1
%define CONFIG_LC3_DEMUXER 1
%define CONFIG_LMLM4_DEMUXER 1
%define CONFIG_LOAS_DEMUXER 1
%define CONFIG_LUODAT_DEMUXER 1
%define CONFIG_LRC_DEMUXER 1
%define CONFIG_LVF_DEMUXER 1
%define CONFIG_LXF_DEMUXER 1
%define CONFIG_M4V_DEMUXER 1
%define CONFIG_MCA_DEMUXER 1
%define CONFIG_MCC_DEMUXER 1
%define CONFIG_MATROSKA_DEMUXER 1
%define CONFIG_MGSTS_DEMUXER 1
%define CONFIG_MICRODVD_DEMUXER 1
%define CONFIG_MJPEG_DEMUXER 1
%define CONFIG_MJPEG_2000_DEMUXER 1
%define CONFIG_MLP_DEMUXER 1
%define CONFIG_MLV_DEMUXER 1
%define CONFIG_MM_DEMUXER 1
%define CONFIG_MMF_DEMUXER 1
%define CONFIG_MODS_DEMUXER 1
%define CONFIG_MOFLEX_DEMUXER 1
%define CONFIG_MOV_DEMUXER 1
%define CONFIG_MP3_DEMUXER 1
%define CONFIG_MPC_DEMUXER 1
%define CONFIG_MPC8_DEMUXER 1
%define CONFIG_MPEGPS_DEMUXER 1
%define CONFIG_MPEGTS_DEMUXER 1
%define CONFIG_MPEGTSRAW_DEMUXER 1
%define CONFIG_MPEGVIDEO_DEMUXER 1
%define CONFIG_MPJPEG_DEMUXER 1
%define CONFIG_MPL2_DEMUXER 1
%define CONFIG_MPSUB_DEMUXER 1
%define CONFIG_MSF_DEMUXER 1
%define CONFIG_MSNWC_TCP_DEMUXER 1
%define CONFIG_MSP_DEMUXER 1
%define CONFIG_MTAF_DEMUXER 1
%define CONFIG_MTV_DEMUXER 1
%define CONFIG_MUSX_DEMUXER 1
%define CONFIG_MV_DEMUXER 1
%define CONFIG_MVI_DEMUXER 1
%define CONFIG_MXF_DEMUXER 1
%define CONFIG_MXG_DEMUXER 1
%define CONFIG_NC_DEMUXER 1
%define CONFIG_NISTSPHERE_DEMUXER 1
%define CONFIG_NSP_DEMUXER 1
%define CONFIG_NSV_DEMUXER 1
%define CONFIG_NUT_DEMUXER 1
%define CONFIG_NUV_DEMUXER 1
%define CONFIG_OBU_DEMUXER 1
%define CONFIG_OGG_DEMUXER 1
%define CONFIG_OMA_DEMUXER 1
%define CONFIG_OSQ_DEMUXER 1
%define CONFIG_PAF_DEMUXER 1
%define CONFIG_PCM_ALAW_DEMUXER 1
%define CONFIG_PCM_MULAW_DEMUXER 1
%define CONFIG_PCM_VIDC_DEMUXER 1
%define CONFIG_PCM_F64BE_DEMUXER 1
%define CONFIG_PCM_F64LE_DEMUXER 1
%define CONFIG_PCM_F32BE_DEMUXER 1
%define CONFIG_PCM_F32LE_DEMUXER 1
%define CONFIG_PCM_S32BE_DEMUXER 1
%define CONFIG_PCM_S32LE_DEMUXER 1
%define CONFIG_PCM_S24BE_DEMUXER 1
%define CONFIG_PCM_S24LE_DEMUXER 1
%define CONFIG_PCM_S16BE_DEMUXER 1
%define CONFIG_PCM_S16LE_DEMUXER 1
%define CONFIG_PCM_S8_DEMUXER 1
%define CONFIG_PCM_U32BE_DEMUXER 1
%define CONFIG_PCM_U32LE_DEMUXER 1
%define CONFIG_PCM_U24BE_DEMUXER 1
%define CONFIG_PCM_U24LE_DEMUXER 1
%define CONFIG_PCM_U16BE_DEMUXER 1
%define CONFIG_PCM_U16LE_DEMUXER 1
%define CONFIG_PCM_U8_DEMUXER 1
%define CONFIG_PDV_DEMUXER 1
%define CONFIG_PJS_DEMUXER 1
%define CONFIG_PMP_DEMUXER 1
%define CONFIG_PP_BNK_DEMUXER 1
%define CONFIG_PVA_DEMUXER 1
%define CONFIG_PVF_DEMUXER 1
%define CONFIG_QCP_DEMUXER 1
%define CONFIG_QOA_DEMUXER 1
%define CONFIG_R3D_DEMUXER 1
%define CONFIG_RAWVIDEO_DEMUXER 1
%define CONFIG_RCWT_DEMUXER 1
%define CONFIG_REALTEXT_DEMUXER 1
%define CONFIG_REDSPARK_DEMUXER 1
%define CONFIG_RKA_DEMUXER 1
%define CONFIG_RL2_DEMUXER 1
%define CONFIG_RM_DEMUXER 1
%define CONFIG_ROQ_DEMUXER 1
%define CONFIG_RPL_DEMUXER 1
%define CONFIG_RSD_DEMUXER 1
%define CONFIG_RSO_DEMUXER 1
%define CONFIG_RTP_DEMUXER 1
%define CONFIG_RTSP_DEMUXER 1
%define CONFIG_S337M_DEMUXER 1
%define CONFIG_SAMI_DEMUXER 1
%define CONFIG_SAP_DEMUXER 1
%define CONFIG_SBC_DEMUXER 1
%define CONFIG_SBG_DEMUXER 1
%define CONFIG_SCC_DEMUXER 1
%define CONFIG_SCD_DEMUXER 1
%define CONFIG_SDNS_DEMUXER 1
%define CONFIG_SDP_DEMUXER 1
%define CONFIG_SDR2_DEMUXER 1
%define CONFIG_SDS_DEMUXER 1
%define CONFIG_SDX_DEMUXER 1
%define CONFIG_SEGAFILM_DEMUXER 1
%define CONFIG_SER_DEMUXER 1
%define CONFIG_SGA_DEMUXER 1
%define CONFIG_SHORTEN_DEMUXER 1
%define CONFIG_SIFF_DEMUXER 1
%define CONFIG_SIMBIOSIS_IMX_DEMUXER 1
%define CONFIG_SLN_DEMUXER 1
%define CONFIG_SMACKER_DEMUXER 1
%define CONFIG_SMJPEG_DEMUXER 1
%define CONFIG_SMUSH_DEMUXER 1
%define CONFIG_SOL_DEMUXER 1
%define CONFIG_SOX_DEMUXER 1
%define CONFIG_SPDIF_DEMUXER 1
%define CONFIG_SRT_DEMUXER 1
%define CONFIG_STR_DEMUXER 1
%define CONFIG_STL_DEMUXER 1
%define CONFIG_SUBVIEWER1_DEMUXER 1
%define CONFIG_SUBVIEWER_DEMUXER 1
%define CONFIG_SUP_DEMUXER 1
%define CONFIG_SVAG_DEMUXER 1
%define CONFIG_SVS_DEMUXER 1
%define CONFIG_SWF_DEMUXER 1
%define CONFIG_TAK_DEMUXER 1
%define CONFIG_TEDCAPTIONS_DEMUXER 1
%define CONFIG_THP_DEMUXER 1
%define CONFIG_THREEDOSTR_DEMUXER 1
%define CONFIG_TIERTEXSEQ_DEMUXER 1
%define CONFIG_TMV_DEMUXER 1
%define CONFIG_TRUEHD_DEMUXER 1
%define CONFIG_TTA_DEMUXER 1
%define CONFIG_TXD_DEMUXER 1
%define CONFIG_TTY_DEMUXER 1
%define CONFIG_TY_DEMUXER 1
%define CONFIG_USM_DEMUXER 1
%define CONFIG_V210_DEMUXER 1
%define CONFIG_V210X_DEMUXER 1
%define CONFIG_VAG_DEMUXER 1
%define CONFIG_VC1_DEMUXER 1
%define CONFIG_VC1T_DEMUXER 1
%define CONFIG_VIVIDAS_DEMUXER 1
%define CONFIG_VIVO_DEMUXER 1
%define CONFIG_VMD_DEMUXER 1
%define CONFIG_VOBSUB_DEMUXER 1
%define CONFIG_VOC_DEMUXER 1
%define CONFIG_VPK_DEMUXER 1
%define CONFIG_VPLAYER_DEMUXER 1
%define CONFIG_VQF_DEMUXER 1
%define CONFIG_VVC_DEMUXER 1
%define CONFIG_W64_DEMUXER 1
%define CONFIG_WADY_DEMUXER 1
%define CONFIG_WAVARC_DEMUXER 1
%define CONFIG_WAV_DEMUXER 1
%define CONFIG_WC3_DEMUXER 1
%define CONFIG_WEBM_DASH_MANIFEST_DEMUXER 1
%define CONFIG_WEBVTT_DEMUXER 1
%define CONFIG_WSAUD_DEMUXER 1
%define CONFIG_WSD_DEMUXER 1
%define CONFIG_WSVQA_DEMUXER 1
%define CONFIG_WTV_DEMUXER 1
%define CONFIG_WVE_DEMUXER 1
%define CONFIG_WV_DEMUXER 1
%define CONFIG_XA_DEMUXER 1
%define CONFIG_XBIN_DEMUXER 1
%define CONFIG_XMD_DEMUXER 1
%define CONFIG_XMV_DEMUXER 1
%define CONFIG_XVAG_DEMUXER 1
%define CONFIG_XWMA_DEMUXER 1
%define CONFIG_YOP_DEMUXER 1
%define CONFIG_YUV4MPEGPIPE_DEMUXER 1
%define CONFIG_IMAGE_BMP_PIPE_DEMUXER 1
%define CONFIG_IMAGE_CRI_PIPE_DEMUXER 1
%define CONFIG_IMAGE_DDS_PIPE_DEMUXER 1
%define CONFIG_IMAGE_DPX_PIPE_DEMUXER 1
%define CONFIG_IMAGE_EXR_PIPE_DEMUXER 1
%define CONFIG_IMAGE_GEM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_GIF_PIPE_DEMUXER 1
%define CONFIG_IMAGE_HDR_PIPE_DEMUXER 1
%define CONFIG_IMAGE_J2K_PIPE_DEMUXER 1
%define CONFIG_IMAGE_JPEG_PIPE_DEMUXER 1
%define CONFIG_IMAGE_JPEGLS_PIPE_DEMUXER 1
%define CONFIG_IMAGE_JPEGXL_PIPE_DEMUXER 1
%define CONFIG_IMAGE_JPEGXS_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PAM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PBM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PCX_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PFM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PGMYUV_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PGM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PGX_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PHM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PHOTOCD_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PICTOR_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PNG_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PPM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_PSD_PIPE_DEMUXER 1
%define CONFIG_IMAGE_QDRAW_PIPE_DEMUXER 1
%define CONFIG_IMAGE_QOI_PIPE_DEMUXER 1
%define CONFIG_IMAGE_SGI_PIPE_DEMUXER 1
%define CONFIG_IMAGE_SVG_PIPE_DEMUXER 1
%define CONFIG_IMAGE_SUNRAST_PIPE_DEMUXER 1
%define CONFIG_IMAGE_TIFF_PIPE_DEMUXER 1
%define CONFIG_IMAGE_VBN_PIPE_DEMUXER 1
%define CONFIG_IMAGE_WEBP_PIPE_DEMUXER 1
%define CONFIG_IMAGE_XBM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_XPM_PIPE_DEMUXER 1
%define CONFIG_IMAGE_XWD_PIPE_DEMUXER 1
%define CONFIG_AVISYNTH_DEMUXER 0
%define CONFIG_DVDVIDEO_DEMUXER 0
%define CONFIG_LIBGME_DEMUXER 0
%define CONFIG_LIBMODPLUG_DEMUXER 0
%define CONFIG_LIBOPENMPT_DEMUXER 0
%define CONFIG_VAPOURSYNTH_DEMUXER 0
%define CONFIG_A64_MUXER 1
%define CONFIG_AC3_MUXER 1
%define CONFIG_AC4_MUXER 1
%define CONFIG_ADTS_MUXER 1
%define CONFIG_ADX_MUXER 1
%define CONFIG_AEA_MUXER 1
%define CONFIG_AIFF_MUXER 1
%define CONFIG_ALP_MUXER 1
%define CONFIG_AMR_MUXER 1
%define CONFIG_AMV_MUXER 1
%define CONFIG_APM_MUXER 1
%define CONFIG_APNG_MUXER 1
%define CONFIG_APTX_MUXER 1
%define CONFIG_APTX_HD_MUXER 1
%define CONFIG_APV_MUXER 1
%define CONFIG_ARGO_ASF_MUXER 1
%define CONFIG_ARGO_CVG_MUXER 1
%define CONFIG_ASF_MUXER 1
%define CONFIG_ASS_MUXER 1
%define CONFIG_AST_MUXER 1
%define CONFIG_ASF_STREAM_MUXER 1
%define CONFIG_AU_MUXER 1
%define CONFIG_AVI_MUXER 1
%define CONFIG_AVIF_MUXER 1
%define CONFIG_AVM2_MUXER 1
%define CONFIG_AVS2_MUXER 1
%define CONFIG_AVS3_MUXER 1
%define CONFIG_BIT_MUXER 1
%define CONFIG_CAF_MUXER 1
%define CONFIG_CAVSVIDEO_MUXER 1
%define CONFIG_CODEC2_MUXER 1
%define CONFIG_CODEC2RAW_MUXER 1
%define CONFIG_CRC_MUXER 1
%define CONFIG_DASH_MUXER 1
%define CONFIG_DATA_MUXER 1
%define CONFIG_DAUD_MUXER 1
%define CONFIG_DFPWM_MUXER 1
%define CONFIG_DIRAC_MUXER 1
%define CONFIG_DNXHD_MUXER 1
%define CONFIG_DTS_MUXER 1
%define CONFIG_DV_MUXER 1
%define CONFIG_EAC3_MUXER 1
%define CONFIG_EVC_MUXER 1
%define CONFIG_F4V_MUXER 1
%define CONFIG_FFMETADATA_MUXER 1
%define CONFIG_FIFO_MUXER 1
%define CONFIG_FILMSTRIP_MUXER 1
%define CONFIG_FITS_MUXER 1
%define CONFIG_FLAC_MUXER 1
%define CONFIG_FLV_MUXER 1
%define CONFIG_FRAMECRC_MUXER 1
%define CONFIG_FRAMEHASH_MUXER 1
%define CONFIG_FRAMEMD5_MUXER 1
%define CONFIG_G722_MUXER 1
%define CONFIG_G723_1_MUXER 1
%define CONFIG_G726_MUXER 1
%define CONFIG_G726LE_MUXER 1
%define CONFIG_GIF_MUXER 1
%define CONFIG_GSM_MUXER 1
%define CONFIG_GXF_MUXER 1
%define CONFIG_H261_MUXER 1
%define CONFIG_H263_MUXER 1
%define CONFIG_H264_MUXER 1
%define CONFIG_HASH_MUXER 1
%define CONFIG_HDS_MUXER 1
%define CONFIG_HEVC_MUXER 1
%define CONFIG_HLS_MUXER 1
%define CONFIG_IAMF_MUXER 1
%define CONFIG_ICO_MUXER 1
%define CONFIG_ILBC_MUXER 1
%define CONFIG_IMAGE2_MUXER 1
%define CONFIG_IMAGE2PIPE_MUXER 1
%define CONFIG_IPOD_MUXER 1
%define CONFIG_IRCAM_MUXER 1
%define CONFIG_ISMV_MUXER 1
%define CONFIG_IVF_MUXER 1
%define CONFIG_JACOSUB_MUXER 1
%define CONFIG_KVAG_MUXER 1
%define CONFIG_LATM_MUXER 1
%define CONFIG_LC3_MUXER 1
%define CONFIG_LRC_MUXER 1
%define CONFIG_M4V_MUXER 1
%define CONFIG_MCC_MUXER 1
%define CONFIG_MD5_MUXER 1
%define CONFIG_MATROSKA_MUXER 1
%define CONFIG_MATROSKA_AUDIO_MUXER 1
%define CONFIG_MICRODVD_MUXER 1
%define CONFIG_MJPEG_MUXER 1
%define CONFIG_MLP_MUXER 1
%define CONFIG_MMF_MUXER 1
%define CONFIG_MOV_MUXER 1
%define CONFIG_MP2_MUXER 1
%define CONFIG_MP3_MUXER 1
%define CONFIG_MP4_MUXER 1
%define CONFIG_MPEG1SYSTEM_MUXER 1
%define CONFIG_MPEG1VCD_MUXER 1
%define CONFIG_MPEG1VIDEO_MUXER 1
%define CONFIG_MPEG2DVD_MUXER 1
%define CONFIG_MPEG2SVCD_MUXER 1
%define CONFIG_MPEG2VIDEO_MUXER 1
%define CONFIG_MPEG2VOB_MUXER 1
%define CONFIG_MPEGTS_MUXER 1
%define CONFIG_MPJPEG_MUXER 1
%define CONFIG_MXF_MUXER 1
%define CONFIG_MXF_D10_MUXER 1
%define CONFIG_MXF_OPATOM_MUXER 1
%define CONFIG_NULL_MUXER 1
%define CONFIG_NUT_MUXER 1
%define CONFIG_OBU_MUXER 1
%define CONFIG_OGA_MUXER 1
%define CONFIG_OGG_MUXER 1
%define CONFIG_OGV_MUXER 1
%define CONFIG_OMA_MUXER 1
%define CONFIG_OPUS_MUXER 1
%define CONFIG_PCM_ALAW_MUXER 1
%define CONFIG_PCM_MULAW_MUXER 1
%define CONFIG_PCM_VIDC_MUXER 1
%define CONFIG_PCM_F64BE_MUXER 1
%define CONFIG_PCM_F64LE_MUXER 1
%define CONFIG_PCM_F32BE_MUXER 1
%define CONFIG_PCM_F32LE_MUXER 1
%define CONFIG_PCM_S32BE_MUXER 1
%define CONFIG_PCM_S32LE_MUXER 1
%define CONFIG_PCM_S24BE_MUXER 1
%define CONFIG_PCM_S24LE_MUXER 1
%define CONFIG_PCM_S16BE_MUXER 1
%define CONFIG_PCM_S16LE_MUXER 1
%define CONFIG_PCM_S8_MUXER 1
%define CONFIG_PCM_U32BE_MUXER 1
%define CONFIG_PCM_U32LE_MUXER 1
%define CONFIG_PCM_U24BE_MUXER 1
%define CONFIG_PCM_U24LE_MUXER 1
%define CONFIG_PCM_U16BE_MUXER 1
%define CONFIG_PCM_U16LE_MUXER 1
%define CONFIG_PCM_U8_MUXER 1
%define CONFIG_PSP_MUXER 1
%define CONFIG_RAWVIDEO_MUXER 1
%define CONFIG_RCWT_MUXER 1
%define CONFIG_RM_MUXER 1
%define CONFIG_ROQ_MUXER 1
%define CONFIG_RSO_MUXER 1
%define CONFIG_RTP_MUXER 1
%define CONFIG_RTP_MPEGTS_MUXER 1
%define CONFIG_RTSP_MUXER 1
%define CONFIG_SAP_MUXER 1
%define CONFIG_SBC_MUXER 1
%define CONFIG_SCC_MUXER 1
%define CONFIG_SEGAFILM_MUXER 1
%define CONFIG_SEGMENT_MUXER 1
%define CONFIG_STREAM_SEGMENT_MUXER 1
%define CONFIG_SMJPEG_MUXER 1
%define CONFIG_SMOOTHSTREAMING_MUXER 1
%define CONFIG_SOX_MUXER 1
%define CONFIG_SPX_MUXER 1
%define CONFIG_SPDIF_MUXER 1
%define CONFIG_SRT_MUXER 1
%define CONFIG_STREAMHASH_MUXER 1
%define CONFIG_SUP_MUXER 1
%define CONFIG_SWF_MUXER 1
%define CONFIG_TEE_MUXER 1
%define CONFIG_TG2_MUXER 1
%define CONFIG_TGP_MUXER 1
%define CONFIG_MKVTIMESTAMP_V2_MUXER 1
%define CONFIG_TRUEHD_MUXER 1
%define CONFIG_TTA_MUXER 1
%define CONFIG_TTML_MUXER 1
%define CONFIG_UNCODEDFRAMECRC_MUXER 1
%define CONFIG_VC1_MUXER 1
%define CONFIG_VC1T_MUXER 1
%define CONFIG_VOC_MUXER 1
%define CONFIG_VVC_MUXER 1
%define CONFIG_W64_MUXER 1
%define CONFIG_WAV_MUXER 1
%define CONFIG_WEBM_MUXER 1
%define CONFIG_WEBM_DASH_MANIFEST_MUXER 1
%define CONFIG_WEBM_CHUNK_MUXER 1
%define CONFIG_WEBP_MUXER 1
%define CONFIG_WEBVTT_MUXER 1
%define CONFIG_WHIP_MUXER 0
%define CONFIG_WSAUD_MUXER 1
%define CONFIG_WTV_MUXER 1
%define CONFIG_WV_MUXER 1
%define CONFIG_YUV4MPEGPIPE_MUXER 1
%define CONFIG_CHROMAPRINT_MUXER 0
%define CONFIG_ANDROID_CONTENT_PROTOCOL 0
%define CONFIG_ASYNC_PROTOCOL 1
%define CONFIG_BLURAY_PROTOCOL 0
%define CONFIG_CACHE_PROTOCOL 1
%define CONFIG_CONCAT_PROTOCOL 1
%define CONFIG_CONCATF_PROTOCOL 1
%define CONFIG_CRYPTO_PROTOCOL 1
%define CONFIG_DATA_PROTOCOL 1
%define CONFIG_FD_PROTOCOL 1
%define CONFIG_FFRTMPCRYPT_PROTOCOL 0
%define CONFIG_FFRTMPHTTP_PROTOCOL 1
%define CONFIG_FILE_PROTOCOL 1
%define CONFIG_FTP_PROTOCOL 1
%define CONFIG_GOPHER_PROTOCOL 1
%define CONFIG_GOPHERS_PROTOCOL 0
%define CONFIG_HTTP_PROTOCOL 1
%define CONFIG_HTTPPROXY_PROTOCOL 1
%define CONFIG_HTTPS_PROTOCOL 0
%define CONFIG_ICECAST_PROTOCOL 1
%define CONFIG_MMSH_PROTOCOL 1
%define CONFIG_MMST_PROTOCOL 1
%define CONFIG_MD5_PROTOCOL 1
%define CONFIG_PIPE_PROTOCOL 1
%define CONFIG_PROMPEG_PROTOCOL 1
%define CONFIG_RTMP_PROTOCOL 1
%define CONFIG_RTMPE_PROTOCOL 0
%define CONFIG_RTMPS_PROTOCOL 0
%define CONFIG_RTMPT_PROTOCOL 1
%define CONFIG_RTMPTE_PROTOCOL 0
%define CONFIG_RTMPTS_PROTOCOL 0
%define CONFIG_RTP_PROTOCOL 1
%define CONFIG_SCTP_PROTOCOL 0
%define CONFIG_SRTP_PROTOCOL 1
%define CONFIG_SUBFILE_PROTOCOL 1
%define CONFIG_TEE_PROTOCOL 1
%define CONFIG_TCP_PROTOCOL 1
%define CONFIG_TLS_PROTOCOL 0
%define CONFIG_DTLS_PROTOCOL 0
%define CONFIG_UDP_PROTOCOL 1
%define CONFIG_UDPLITE_PROTOCOL 1
%define CONFIG_UNIX_PROTOCOL 0
%define CONFIG_LIBAMQP_PROTOCOL 0
%define CONFIG_LIBRIST_PROTOCOL 0
%define CONFIG_LIBRTMP_PROTOCOL 0
%define CONFIG_LIBRTMPE_PROTOCOL 0
%define CONFIG_LIBRTMPS_PROTOCOL 0
%define CONFIG_LIBRTMPT_PROTOCOL 0
%define CONFIG_LIBRTMPTE_PROTOCOL 0
%define CONFIG_LIBSRT_PROTOCOL 0
%define CONFIG_LIBSSH_PROTOCOL 0
%define CONFIG_LIBSMBCLIENT_PROTOCOL 0
%define CONFIG_LIBZMQ_PROTOCOL 0
%define CONFIG_IPFS_GATEWAY_PROTOCOL 0
%define CONFIG_IPNS_GATEWAY_PROTOCOL 0
]==],
        ["mcpp_generated/libavutil/avconfig.h"] = [==[
/* Generated by ffmpeg configure */
#ifndef AVUTIL_AVCONFIG_H
#define AVUTIL_AVCONFIG_H
#define AV_HAVE_BIGENDIAN 0
#define AV_HAVE_FAST_UNALIGNED 1
#endif /* AVUTIL_AVCONFIG_H */
]==],
        ["mcpp_generated/libavutil/ffversion.h"] = [==[
/* Automatically generated by version.sh, do not manually edit! */
#ifndef AVUTIL_FFVERSION_H
#define AVUTIL_FFVERSION_H
#define FFMPEG_VERSION "8.1.2"
#endif /* AVUTIL_FFVERSION_H */
]==],
        ["mcpp_generated/libavcodec/codec_list.c"] = [==[
static const FFCodec * const codec_list[] = {
    &ff_a64multi_encoder,
    &ff_a64multi5_encoder,
    &ff_alias_pix_encoder,
    &ff_amv_encoder,
    &ff_asv1_encoder,
    &ff_asv2_encoder,
    &ff_avrp_encoder,
    &ff_avui_encoder,
    &ff_bitpacked_encoder,
    &ff_bmp_encoder,
    &ff_cfhd_encoder,
    &ff_cinepak_encoder,
    &ff_cljr_encoder,
    &ff_comfortnoise_encoder,
    &ff_dnxhd_encoder,
    &ff_dpx_encoder,
    &ff_dvvideo_encoder,
    &ff_dxv_encoder,
    &ff_ffv1_encoder,
    &ff_ffvhuff_encoder,
    &ff_fits_encoder,
    &ff_flv_encoder,
    &ff_gif_encoder,
    &ff_h261_encoder,
    &ff_h263_encoder,
    &ff_h263p_encoder,
    &ff_huffyuv_encoder,
    &ff_jpeg2000_encoder,
    &ff_jpegls_encoder,
    &ff_ljpeg_encoder,
    &ff_magicyuv_encoder,
    &ff_mjpeg_encoder,
    &ff_mpeg1video_encoder,
    &ff_mpeg2video_encoder,
    &ff_mpeg4_encoder,
    &ff_msmpeg4v2_encoder,
    &ff_msmpeg4v3_encoder,
    &ff_msrle_encoder,
    &ff_msvideo1_encoder,
    &ff_pam_encoder,
    &ff_pbm_encoder,
    &ff_pcx_encoder,
    &ff_pfm_encoder,
    &ff_pgm_encoder,
    &ff_pgmyuv_encoder,
    &ff_phm_encoder,
    &ff_ppm_encoder,
    &ff_prores_encoder,
    &ff_prores_aw_encoder,
    &ff_prores_ks_encoder,
    &ff_qoi_encoder,
    &ff_qtrle_encoder,
    &ff_r10k_encoder,
    &ff_r210_encoder,
    &ff_rawvideo_encoder,
    &ff_roq_encoder,
    &ff_rpza_encoder,
    &ff_rv10_encoder,
    &ff_rv20_encoder,
    &ff_s302m_encoder,
    &ff_sgi_encoder,
    &ff_smc_encoder,
    &ff_snow_encoder,
    &ff_speedhq_encoder,
    &ff_sunrast_encoder,
    &ff_svq1_encoder,
    &ff_targa_encoder,
    &ff_tiff_encoder,
    &ff_utvideo_encoder,
    &ff_v210_encoder,
    &ff_v308_encoder,
    &ff_v408_encoder,
    &ff_v410_encoder,
    &ff_vbn_encoder,
    &ff_vc2_encoder,
    &ff_wbmp_encoder,
    &ff_wrapped_avframe_encoder,
    &ff_wmv1_encoder,
    &ff_wmv2_encoder,
    &ff_xbm_encoder,
    &ff_xface_encoder,
    &ff_xwd_encoder,
    &ff_y41p_encoder,
    &ff_yuv4_encoder,
    &ff_aac_encoder,
    &ff_ac3_encoder,
    &ff_ac3_fixed_encoder,
    &ff_alac_encoder,
    &ff_aptx_encoder,
    &ff_aptx_hd_encoder,
    &ff_dca_encoder,
    &ff_dfpwm_encoder,
    &ff_eac3_encoder,
    &ff_flac_encoder,
    &ff_g723_1_encoder,
    &ff_hdr_encoder,
    &ff_mlp_encoder,
    &ff_mp2_encoder,
    &ff_mp2fixed_encoder,
    &ff_nellymoser_encoder,
    &ff_opus_encoder,
    &ff_ra_144_encoder,
    &ff_sbc_encoder,
    &ff_truehd_encoder,
    &ff_tta_encoder,
    &ff_vorbis_encoder,
    &ff_wavpack_encoder,
    &ff_wmav1_encoder,
    &ff_wmav2_encoder,
    &ff_pcm_alaw_encoder,
    &ff_pcm_bluray_encoder,
    &ff_pcm_dvd_encoder,
    &ff_pcm_f32be_encoder,
    &ff_pcm_f32le_encoder,
    &ff_pcm_f64be_encoder,
    &ff_pcm_f64le_encoder,
    &ff_pcm_mulaw_encoder,
    &ff_pcm_s8_encoder,
    &ff_pcm_s8_planar_encoder,
    &ff_pcm_s16be_encoder,
    &ff_pcm_s16be_planar_encoder,
    &ff_pcm_s16le_encoder,
    &ff_pcm_s16le_planar_encoder,
    &ff_pcm_s24be_encoder,
    &ff_pcm_s24daud_encoder,
    &ff_pcm_s24le_encoder,
    &ff_pcm_s24le_planar_encoder,
    &ff_pcm_s32be_encoder,
    &ff_pcm_s32le_encoder,
    &ff_pcm_s32le_planar_encoder,
    &ff_pcm_s64be_encoder,
    &ff_pcm_s64le_encoder,
    &ff_pcm_u8_encoder,
    &ff_pcm_u16be_encoder,
    &ff_pcm_u16le_encoder,
    &ff_pcm_u24be_encoder,
    &ff_pcm_u24le_encoder,
    &ff_pcm_u32be_encoder,
    &ff_pcm_u32le_encoder,
    &ff_pcm_vidc_encoder,
    &ff_roq_dpcm_encoder,
    &ff_adpcm_adx_encoder,
    &ff_adpcm_argo_encoder,
    &ff_adpcm_g722_encoder,
    &ff_adpcm_g726_encoder,
    &ff_adpcm_g726le_encoder,
    &ff_adpcm_ima_amv_encoder,
    &ff_adpcm_ima_alp_encoder,
    &ff_adpcm_ima_apm_encoder,
    &ff_adpcm_ima_qt_encoder,
    &ff_adpcm_ima_ssi_encoder,
    &ff_adpcm_ima_wav_encoder,
    &ff_adpcm_ima_ws_encoder,
    &ff_adpcm_ms_encoder,
    &ff_adpcm_swf_encoder,
    &ff_adpcm_yamaha_encoder,
    &ff_ssa_encoder,
    &ff_ass_encoder,
    &ff_dvbsub_encoder,
    &ff_dvdsub_encoder,
    &ff_movtext_encoder,
    &ff_srt_encoder,
    &ff_subrip_encoder,
    &ff_text_encoder,
    &ff_ttml_encoder,
    &ff_webvtt_encoder,
    &ff_xsub_encoder,
    &ff_vnull_encoder,
    &ff_anull_encoder,
    &ff_aasc_decoder,
    &ff_aic_decoder,
    &ff_alias_pix_decoder,
    &ff_agm_decoder,
    &ff_amv_decoder,
    &ff_anm_decoder,
    &ff_ansi_decoder,
    &ff_apv_decoder,
    &ff_arbc_decoder,
    &ff_argo_decoder,
    &ff_asv1_decoder,
    &ff_asv2_decoder,
    &ff_aura_decoder,
    &ff_aura2_decoder,
    &ff_avrp_decoder,
    &ff_avrn_decoder,
    &ff_avs_decoder,
    &ff_avui_decoder,
    &ff_bethsoftvid_decoder,
    &ff_bfi_decoder,
    &ff_bink_decoder,
    &ff_bitpacked_decoder,
    &ff_bmp_decoder,
    &ff_bmv_video_decoder,
    &ff_brender_pix_decoder,
    &ff_c93_decoder,
    &ff_cavs_decoder,
    &ff_cdgraphics_decoder,
    &ff_cdtoons_decoder,
    &ff_cdxl_decoder,
    &ff_cfhd_decoder,
    &ff_cinepak_decoder,
    &ff_clearvideo_decoder,
    &ff_cljr_decoder,
    &ff_cllc_decoder,
    &ff_comfortnoise_decoder,
    &ff_cpia_decoder,
    &ff_cri_decoder,
    &ff_cscd_decoder,
    &ff_cyuv_decoder,
    &ff_dds_decoder,
    &ff_dfa_decoder,
    &ff_dirac_decoder,
    &ff_dnxhd_decoder,
    &ff_dpx_decoder,
    &ff_dsicinvideo_decoder,
    &ff_dvaudio_decoder,
    &ff_dvvideo_decoder,
    &ff_dxtory_decoder,
    &ff_dxv_decoder,
    &ff_eacmv_decoder,
    &ff_eamad_decoder,
    &ff_eatgq_decoder,
    &ff_eatgv_decoder,
    &ff_eatqi_decoder,
    &ff_eightbps_decoder,
    &ff_eightsvx_exp_decoder,
    &ff_eightsvx_fib_decoder,
    &ff_escape124_decoder,
    &ff_escape130_decoder,
    &ff_ffv1_decoder,
    &ff_ffvhuff_decoder,
    &ff_fic_decoder,
    &ff_fits_decoder,
    &ff_flic_decoder,
    &ff_flv_decoder,
    &ff_fmvc_decoder,
    &ff_fourxm_decoder,
    &ff_fraps_decoder,
    &ff_frwu_decoder,
    &ff_gdv_decoder,
    &ff_gem_decoder,
    &ff_gif_decoder,
    &ff_h261_decoder,
    &ff_h263_decoder,
    &ff_h263i_decoder,
    &ff_h263p_decoder,
    &ff_h264_decoder,
    &ff_hap_decoder,
    &ff_hevc_decoder,
    &ff_hnm4_video_decoder,
    &ff_hq_hqa_decoder,
    &ff_hqx_decoder,
    &ff_huffyuv_decoder,
    &ff_hymt_decoder,
    &ff_idcin_decoder,
    &ff_iff_ilbm_decoder,
    &ff_imm4_decoder,
    &ff_imm5_decoder,
    &ff_indeo2_decoder,
    &ff_indeo3_decoder,
    &ff_indeo4_decoder,
    &ff_indeo5_decoder,
    &ff_interplay_video_decoder,
    &ff_ipu_decoder,
    &ff_jpeg2000_decoder,
    &ff_jpegls_decoder,
    &ff_jv_decoder,
    &ff_kgv1_decoder,
    &ff_kmvc_decoder,
    &ff_lagarith_decoder,
    &ff_lead_decoder,
    &ff_loco_decoder,
    &ff_m101_decoder,
    &ff_magicyuv_decoder,
    &ff_mdec_decoder,
    &ff_media100_decoder,
    &ff_mimic_decoder,
    &ff_mjpeg_decoder,
    &ff_mjpegb_decoder,
    &ff_mmvideo_decoder,
    &ff_mobiclip_decoder,
    &ff_motionpixels_decoder,
    &ff_mpeg1video_decoder,
    &ff_mpeg2video_decoder,
    &ff_mpeg4_decoder,
    &ff_mpegvideo_decoder,
    &ff_msa1_decoder,
    &ff_msmpeg4v1_decoder,
    &ff_msmpeg4v2_decoder,
    &ff_msmpeg4v3_decoder,
    &ff_msp2_decoder,
    &ff_msrle_decoder,
    &ff_mss1_decoder,
    &ff_mss2_decoder,
    &ff_msvideo1_decoder,
    &ff_mszh_decoder,
    &ff_mts2_decoder,
    &ff_mv30_decoder,
    &ff_mvc1_decoder,
    &ff_mvc2_decoder,
    &ff_mvdv_decoder,
    &ff_mxpeg_decoder,
    &ff_notchlc_decoder,
    &ff_nuv_decoder,
    &ff_paf_video_decoder,
    &ff_pam_decoder,
    &ff_pbm_decoder,
    &ff_pcx_decoder,
    &ff_pfm_decoder,
    &ff_pgm_decoder,
    &ff_pgmyuv_decoder,
    &ff_pgx_decoder,
    &ff_phm_decoder,
    &ff_photocd_decoder,
    &ff_pictor_decoder,
    &ff_pixlet_decoder,
    &ff_ppm_decoder,
    &ff_prores_decoder,
    &ff_prores_raw_decoder,
    &ff_prosumer_decoder,
    &ff_psd_decoder,
    &ff_ptx_decoder,
    &ff_qdraw_decoder,
    &ff_qoi_decoder,
    &ff_qpeg_decoder,
    &ff_qtrle_decoder,
    &ff_r10k_decoder,
    &ff_r210_decoder,
    &ff_rawvideo_decoder,
    &ff_rka_decoder,
    &ff_rl2_decoder,
    &ff_roq_decoder,
    &ff_rpza_decoder,
    &ff_rtv1_decoder,
    &ff_rv10_decoder,
    &ff_rv20_decoder,
    &ff_rv30_decoder,
    &ff_rv40_decoder,
    &ff_rv60_decoder,
    &ff_s302m_decoder,
    &ff_sanm_decoder,
    &ff_scpr_decoder,
    &ff_sga_decoder,
    &ff_sgi_decoder,
    &ff_sgirle_decoder,
    &ff_sheervideo_decoder,
    &ff_simbiosis_imx_decoder,
    &ff_smacker_decoder,
    &ff_smc_decoder,
    &ff_smvjpeg_decoder,
    &ff_snow_decoder,
    &ff_sp5x_decoder,
    &ff_speedhq_decoder,
    &ff_speex_decoder,
    &ff_sunrast_decoder,
    &ff_svq1_decoder,
    &ff_svq3_decoder,
    &ff_targa_decoder,
    &ff_targa_y216_decoder,
    &ff_theora_decoder,
    &ff_thp_decoder,
    &ff_tiertexseqvideo_decoder,
    &ff_tiff_decoder,
    &ff_tmv_decoder,
    &ff_truemotion1_decoder,
    &ff_truemotion2_decoder,
    &ff_truemotion2rt_decoder,
    &ff_tscc2_decoder,
    &ff_txd_decoder,
    &ff_ulti_decoder,
    &ff_utvideo_decoder,
    &ff_v210_decoder,
    &ff_v210x_decoder,
    &ff_v308_decoder,
    &ff_v408_decoder,
    &ff_v410_decoder,
    &ff_vb_decoder,
    &ff_vbn_decoder,
    &ff_vble_decoder,
    &ff_vc1_decoder,
    &ff_vc1image_decoder,
    &ff_vcr1_decoder,
    &ff_vmdvideo_decoder,
    &ff_vmix_decoder,
    &ff_vmnc_decoder,
    &ff_vp3_decoder,
    &ff_vp4_decoder,
    &ff_vp5_decoder,
    &ff_vp6_decoder,
    &ff_vp6a_decoder,
    &ff_vp6f_decoder,
    &ff_vp7_decoder,
    &ff_vp8_decoder,
    &ff_vp9_decoder,
    &ff_vqa_decoder,
    &ff_vqc_decoder,
    &ff_vvc_decoder,
    &ff_wbmp_decoder,
    &ff_webp_decoder,
    &ff_wrapped_avframe_decoder,
    &ff_wmv1_decoder,
    &ff_wmv2_decoder,
    &ff_wmv3_decoder,
    &ff_wmv3image_decoder,
    &ff_wnv1_decoder,
    &ff_xan_wc3_decoder,
    &ff_xan_wc4_decoder,
    &ff_xbm_decoder,
    &ff_xface_decoder,
    &ff_xl_decoder,
    &ff_xpm_decoder,
    &ff_xwd_decoder,
    &ff_y41p_decoder,
    &ff_ylc_decoder,
    &ff_yop_decoder,
    &ff_yuv4_decoder,
    &ff_zero12v_decoder,
    &ff_aac_decoder,
    &ff_aac_fixed_decoder,
    &ff_aac_latm_decoder,
    &ff_ac3_decoder,
    &ff_ac3_fixed_decoder,
    &ff_acelp_kelvin_decoder,
    &ff_alac_decoder,
    &ff_als_decoder,
    &ff_amrnb_decoder,
    &ff_amrwb_decoder,
    &ff_apac_decoder,
    &ff_ape_decoder,
    &ff_aptx_decoder,
    &ff_aptx_hd_decoder,
    &ff_atrac1_decoder,
    &ff_atrac3_decoder,
    &ff_atrac3al_decoder,
    &ff_atrac3p_decoder,
    &ff_atrac3pal_decoder,
    &ff_atrac9_decoder,
    &ff_binkaudio_dct_decoder,
    &ff_binkaudio_rdft_decoder,
    &ff_bmv_audio_decoder,
    &ff_bonk_decoder,
    &ff_cook_decoder,
    &ff_dca_decoder,
    &ff_dfpwm_decoder,
    &ff_dolby_e_decoder,
    &ff_dsd_lsbf_decoder,
    &ff_dsd_msbf_decoder,
    &ff_dsd_lsbf_planar_decoder,
    &ff_dsd_msbf_planar_decoder,
    &ff_dsicinaudio_decoder,
    &ff_dss_sp_decoder,
    &ff_dst_decoder,
    &ff_eac3_decoder,
    &ff_evrc_decoder,
    &ff_fastaudio_decoder,
    &ff_ffwavesynth_decoder,
    &ff_flac_decoder,
    &ff_ftr_decoder,
    &ff_g723_1_decoder,
    &ff_g728_decoder,
    &ff_g729_decoder,
    &ff_gsm_decoder,
    &ff_gsm_ms_decoder,
    &ff_hca_decoder,
    &ff_hcom_decoder,
    &ff_hdr_decoder,
    &ff_iac_decoder,
    &ff_ilbc_decoder,
    &ff_imc_decoder,
    &ff_interplay_acm_decoder,
    &ff_mace3_decoder,
    &ff_mace6_decoder,
    &ff_metasound_decoder,
    &ff_misc4_decoder,
    &ff_mlp_decoder,
    &ff_mp1_decoder,
    &ff_mp1float_decoder,
    &ff_mp2_decoder,
    &ff_mp2float_decoder,
    &ff_mp3float_decoder,
    &ff_mp3_decoder,
    &ff_mp3adufloat_decoder,
    &ff_mp3adu_decoder,
    &ff_mp3on4float_decoder,
    &ff_mp3on4_decoder,
    &ff_mpc7_decoder,
    &ff_mpc8_decoder,
    &ff_msnsiren_decoder,
    &ff_nellymoser_decoder,
    &ff_on2avc_decoder,
    &ff_opus_decoder,
    &ff_osq_decoder,
    &ff_paf_audio_decoder,
    &ff_qcelp_decoder,
    &ff_qdm2_decoder,
    &ff_qdmc_decoder,
    &ff_qoa_decoder,
    &ff_ra_144_decoder,
    &ff_ra_288_decoder,
    &ff_ralf_decoder,
    &ff_sbc_decoder,
    &ff_shorten_decoder,
    &ff_sipr_decoder,
    &ff_siren_decoder,
    &ff_smackaud_decoder,
    &ff_sonic_decoder,
    &ff_tak_decoder,
    &ff_truehd_decoder,
    &ff_truespeech_decoder,
    &ff_tta_decoder,
    &ff_twinvq_decoder,
    &ff_vmdaudio_decoder,
    &ff_vorbis_decoder,
    &ff_wavarc_decoder,
    &ff_wavpack_decoder,
    &ff_wmalossless_decoder,
    &ff_wmapro_decoder,
    &ff_wmav1_decoder,
    &ff_wmav2_decoder,
    &ff_wmavoice_decoder,
    &ff_ws_snd1_decoder,
    &ff_xma1_decoder,
    &ff_xma2_decoder,
    &ff_pcm_alaw_decoder,
    &ff_pcm_bluray_decoder,
    &ff_pcm_dvd_decoder,
    &ff_pcm_f16le_decoder,
    &ff_pcm_f24le_decoder,
    &ff_pcm_f32be_decoder,
    &ff_pcm_f32le_decoder,
    &ff_pcm_f64be_decoder,
    &ff_pcm_f64le_decoder,
    &ff_pcm_lxf_decoder,
    &ff_pcm_mulaw_decoder,
    &ff_pcm_s8_decoder,
    &ff_pcm_s8_planar_decoder,
    &ff_pcm_s16be_decoder,
    &ff_pcm_s16be_planar_decoder,
    &ff_pcm_s16le_decoder,
    &ff_pcm_s16le_planar_decoder,
    &ff_pcm_s24be_decoder,
    &ff_pcm_s24daud_decoder,
    &ff_pcm_s24le_decoder,
    &ff_pcm_s24le_planar_decoder,
    &ff_pcm_s32be_decoder,
    &ff_pcm_s32le_decoder,
    &ff_pcm_s32le_planar_decoder,
    &ff_pcm_s64be_decoder,
    &ff_pcm_s64le_decoder,
    &ff_pcm_sga_decoder,
    &ff_pcm_u8_decoder,
    &ff_pcm_u16be_decoder,
    &ff_pcm_u16le_decoder,
    &ff_pcm_u24be_decoder,
    &ff_pcm_u24le_decoder,
    &ff_pcm_u32be_decoder,
    &ff_pcm_u32le_decoder,
    &ff_pcm_vidc_decoder,
    &ff_cbd2_dpcm_decoder,
    &ff_derf_dpcm_decoder,
    &ff_gremlin_dpcm_decoder,
    &ff_interplay_dpcm_decoder,
    &ff_roq_dpcm_decoder,
    &ff_sdx2_dpcm_decoder,
    &ff_sol_dpcm_decoder,
    &ff_xan_dpcm_decoder,
    &ff_wady_dpcm_decoder,
    &ff_adpcm_4xm_decoder,
    &ff_adpcm_adx_decoder,
    &ff_adpcm_afc_decoder,
    &ff_adpcm_agm_decoder,
    &ff_adpcm_aica_decoder,
    &ff_adpcm_argo_decoder,
    &ff_adpcm_ct_decoder,
    &ff_adpcm_dtk_decoder,
    &ff_adpcm_ea_decoder,
    &ff_adpcm_ea_maxis_xa_decoder,
    &ff_adpcm_ea_r1_decoder,
    &ff_adpcm_ea_r2_decoder,
    &ff_adpcm_ea_r3_decoder,
    &ff_adpcm_ea_xas_decoder,
    &ff_adpcm_g722_decoder,
    &ff_adpcm_g726_decoder,
    &ff_adpcm_g726le_decoder,
    &ff_adpcm_ima_acorn_decoder,
    &ff_adpcm_ima_amv_decoder,
    &ff_adpcm_ima_alp_decoder,
    &ff_adpcm_ima_apc_decoder,
    &ff_adpcm_ima_apm_decoder,
    &ff_adpcm_ima_cunning_decoder,
    &ff_adpcm_ima_dat4_decoder,
    &ff_adpcm_ima_dk3_decoder,
    &ff_adpcm_ima_dk4_decoder,
    &ff_adpcm_ima_ea_eacs_decoder,
    &ff_adpcm_ima_ea_sead_decoder,
    &ff_adpcm_ima_iss_decoder,
    &ff_adpcm_ima_moflex_decoder,
    &ff_adpcm_ima_mtf_decoder,
    &ff_adpcm_ima_oki_decoder,
    &ff_adpcm_ima_qt_decoder,
    &ff_adpcm_ima_rad_decoder,
    &ff_adpcm_ima_ssi_decoder,
    &ff_adpcm_ima_smjpeg_decoder,
    &ff_adpcm_ima_wav_decoder,
    &ff_adpcm_ima_ws_decoder,
    &ff_adpcm_ima_xbox_decoder,
    &ff_adpcm_ms_decoder,
    &ff_adpcm_mtaf_decoder,
    &ff_adpcm_psx_decoder,
    &ff_adpcm_sanyo_decoder,
    &ff_adpcm_sbpro_2_decoder,
    &ff_adpcm_sbpro_3_decoder,
    &ff_adpcm_sbpro_4_decoder,
    &ff_adpcm_swf_decoder,
    &ff_adpcm_thp_decoder,
    &ff_adpcm_thp_le_decoder,
    &ff_adpcm_vima_decoder,
    &ff_adpcm_xa_decoder,
    &ff_adpcm_xmd_decoder,
    &ff_adpcm_yamaha_decoder,
    &ff_adpcm_zork_decoder,
    &ff_ssa_decoder,
    &ff_ass_decoder,
    &ff_ccaption_decoder,
    &ff_dvbsub_decoder,
    &ff_dvdsub_decoder,
    &ff_jacosub_decoder,
    &ff_microdvd_decoder,
    &ff_movtext_decoder,
    &ff_mpl2_decoder,
    &ff_pgssub_decoder,
    &ff_pjs_decoder,
    &ff_realtext_decoder,
    &ff_sami_decoder,
    &ff_srt_decoder,
    &ff_stl_decoder,
    &ff_subrip_decoder,
    &ff_subviewer_decoder,
    &ff_subviewer1_decoder,
    &ff_text_decoder,
    &ff_vplayer_decoder,
    &ff_webvtt_decoder,
    &ff_xsub_decoder,
    &ff_bintext_decoder,
    &ff_xbin_decoder,
    &ff_idf_decoder,
    &ff_av1_decoder,
    &ff_vnull_decoder,
    &ff_anull_decoder,
    NULL };
]==],
        ["mcpp_generated/libavcodec/parser_list.c"] = [==[
static const FFCodecParser * const parser_list[] = {
    &ff_aac_parser,
    &ff_aac_latm_parser,
    &ff_ac3_parser,
    &ff_adx_parser,
    &ff_amr_parser,
    &ff_apv_parser,
    &ff_av1_parser,
    &ff_avs2_parser,
    &ff_avs3_parser,
    &ff_bmp_parser,
    &ff_cavsvideo_parser,
    &ff_cook_parser,
    &ff_cri_parser,
    &ff_dca_parser,
    &ff_dirac_parser,
    &ff_dnxhd_parser,
    &ff_dnxuc_parser,
    &ff_dolby_e_parser,
    &ff_dpx_parser,
    &ff_dvaudio_parser,
    &ff_dvbsub_parser,
    &ff_dvdsub_parser,
    &ff_dvd_nav_parser,
    &ff_evc_parser,
    &ff_flac_parser,
    &ff_ftr_parser,
    &ff_ffv1_parser,
    &ff_g723_1_parser,
    &ff_g729_parser,
    &ff_gif_parser,
    &ff_gsm_parser,
    &ff_h261_parser,
    &ff_h263_parser,
    &ff_h264_parser,
    &ff_hevc_parser,
    &ff_hdr_parser,
    &ff_ipu_parser,
    &ff_jpeg2000_parser,
    &ff_jpegxl_parser,
    &ff_jpegxs_parser,
    &ff_lcevc_parser,
    &ff_misc4_parser,
    &ff_mjpeg_parser,
    &ff_mlp_parser,
    &ff_mpeg4video_parser,
    &ff_mpegaudio_parser,
    &ff_mpegvideo_parser,
    &ff_opus_parser,
    &ff_prores_parser,
    &ff_png_parser,
    &ff_pnm_parser,
    &ff_prores_raw_parser,
    &ff_qoi_parser,
    &ff_rv34_parser,
    &ff_sbc_parser,
    &ff_sipr_parser,
    &ff_tak_parser,
    &ff_vc1_parser,
    &ff_vorbis_parser,
    &ff_vp3_parser,
    &ff_vp8_parser,
    &ff_vp9_parser,
    &ff_vvc_parser,
    &ff_webp_parser,
    &ff_xbm_parser,
    &ff_xma_parser,
    &ff_xwd_parser,
    NULL };
]==],
        ["mcpp_generated/libavcodec/bsf_list.c"] = [==[
static const FFBitStreamFilter * const bitstream_filters[] = {
    &ff_aac_adtstoasc_bsf,
    &ff_apv_metadata_bsf,
    &ff_av1_frame_merge_bsf,
    &ff_av1_frame_split_bsf,
    &ff_av1_metadata_bsf,
    &ff_chomp_bsf,
    &ff_dump_extradata_bsf,
    &ff_dca_core_bsf,
    &ff_dovi_rpu_bsf,
    &ff_dts2pts_bsf,
    &ff_dv_error_marker_bsf,
    &ff_eac3_core_bsf,
    &ff_eia608_to_smpte436m_bsf,
    &ff_evc_frame_merge_bsf,
    &ff_extract_extradata_bsf,
    &ff_filter_units_bsf,
    &ff_h264_metadata_bsf,
    &ff_h264_mp4toannexb_bsf,
    &ff_h264_redundant_pps_bsf,
    &ff_hapqa_extract_bsf,
    &ff_hevc_metadata_bsf,
    &ff_hevc_mp4toannexb_bsf,
    &ff_imx_dump_header_bsf,
    &ff_lcevc_metadata_bsf,
    &ff_media100_to_mjpegb_bsf,
    &ff_mjpeg2jpeg_bsf,
    &ff_mjpega_dump_header_bsf,
    &ff_mpeg2_metadata_bsf,
    &ff_mpeg4_unpack_bframes_bsf,
    &ff_mov2textsub_bsf,
    &ff_noise_bsf,
    &ff_null_bsf,
    &ff_opus_metadata_bsf,
    &ff_pcm_rechunk_bsf,
    &ff_pgs_frame_merge_bsf,
    &ff_prores_metadata_bsf,
    &ff_remove_extradata_bsf,
    &ff_setts_bsf,
    &ff_showinfo_bsf,
    &ff_smpte436m_to_eia608_bsf,
    &ff_text2movsub_bsf,
    &ff_trace_headers_bsf,
    &ff_truehd_core_bsf,
    &ff_vp9_metadata_bsf,
    &ff_vp9_raw_reorder_bsf,
    &ff_vp9_superframe_bsf,
    &ff_vp9_superframe_split_bsf,
    &ff_vvc_metadata_bsf,
    &ff_vvc_mp4toannexb_bsf,
    NULL };
]==],
        ["mcpp_generated/libavformat/demuxer_list.c"] = [==[
static const FFInputFormat * const demuxer_list[] = {
    &ff_aa_demuxer,
    &ff_aac_demuxer,
    &ff_aax_demuxer,
    &ff_ac3_demuxer,
    &ff_ac4_demuxer,
    &ff_ace_demuxer,
    &ff_acm_demuxer,
    &ff_act_demuxer,
    &ff_adf_demuxer,
    &ff_adp_demuxer,
    &ff_ads_demuxer,
    &ff_adx_demuxer,
    &ff_aea_demuxer,
    &ff_afc_demuxer,
    &ff_aiff_demuxer,
    &ff_aix_demuxer,
    &ff_alp_demuxer,
    &ff_amr_demuxer,
    &ff_amrnb_demuxer,
    &ff_amrwb_demuxer,
    &ff_anm_demuxer,
    &ff_apac_demuxer,
    &ff_apc_demuxer,
    &ff_ape_demuxer,
    &ff_apm_demuxer,
    &ff_apng_demuxer,
    &ff_aptx_demuxer,
    &ff_aptx_hd_demuxer,
    &ff_apv_demuxer,
    &ff_aqtitle_demuxer,
    &ff_argo_asf_demuxer,
    &ff_argo_brp_demuxer,
    &ff_argo_cvg_demuxer,
    &ff_asf_demuxer,
    &ff_asf_o_demuxer,
    &ff_ass_demuxer,
    &ff_ast_demuxer,
    &ff_au_demuxer,
    &ff_av1_demuxer,
    &ff_avi_demuxer,
    &ff_avr_demuxer,
    &ff_avs_demuxer,
    &ff_avs2_demuxer,
    &ff_avs3_demuxer,
    &ff_bethsoftvid_demuxer,
    &ff_bfi_demuxer,
    &ff_bintext_demuxer,
    &ff_bink_demuxer,
    &ff_binka_demuxer,
    &ff_bit_demuxer,
    &ff_bitpacked_demuxer,
    &ff_bmv_demuxer,
    &ff_bfstm_demuxer,
    &ff_brstm_demuxer,
    &ff_boa_demuxer,
    &ff_bonk_demuxer,
    &ff_c93_demuxer,
    &ff_caf_demuxer,
    &ff_cavsvideo_demuxer,
    &ff_cdg_demuxer,
    &ff_cdxl_demuxer,
    &ff_cine_demuxer,
    &ff_codec2_demuxer,
    &ff_codec2raw_demuxer,
    &ff_concat_demuxer,
    &ff_data_demuxer,
    &ff_daud_demuxer,
    &ff_dcstr_demuxer,
    &ff_derf_demuxer,
    &ff_dfa_demuxer,
    &ff_dfpwm_demuxer,
    &ff_dhav_demuxer,
    &ff_dirac_demuxer,
    &ff_dnxhd_demuxer,
    &ff_dsf_demuxer,
    &ff_dsicin_demuxer,
    &ff_dss_demuxer,
    &ff_dts_demuxer,
    &ff_dtshd_demuxer,
    &ff_dv_demuxer,
    &ff_dvbsub_demuxer,
    &ff_dvbtxt_demuxer,
    &ff_dxa_demuxer,
    &ff_ea_demuxer,
    &ff_ea_cdata_demuxer,
    &ff_eac3_demuxer,
    &ff_epaf_demuxer,
    &ff_evc_demuxer,
    &ff_ffmetadata_demuxer,
    &ff_filmstrip_demuxer,
    &ff_fits_demuxer,
    &ff_flac_demuxer,
    &ff_flic_demuxer,
    &ff_flv_demuxer,
    &ff_live_flv_demuxer,
    &ff_fourxm_demuxer,
    &ff_frm_demuxer,
    &ff_fsb_demuxer,
    &ff_fwse_demuxer,
    &ff_g722_demuxer,
    &ff_g723_1_demuxer,
    &ff_g726_demuxer,
    &ff_g726le_demuxer,
    &ff_g728_demuxer,
    &ff_g729_demuxer,
    &ff_gdv_demuxer,
    &ff_genh_demuxer,
    &ff_gif_demuxer,
    &ff_gsm_demuxer,
    &ff_gxf_demuxer,
    &ff_h261_demuxer,
    &ff_h263_demuxer,
    &ff_h264_demuxer,
    &ff_hca_demuxer,
    &ff_hcom_demuxer,
    &ff_hevc_demuxer,
    &ff_hls_demuxer,
    &ff_hnm_demuxer,
    &ff_hxvs_demuxer,
    &ff_iamf_demuxer,
    &ff_ico_demuxer,
    &ff_idcin_demuxer,
    &ff_idf_demuxer,
    &ff_iff_demuxer,
    &ff_ifv_demuxer,
    &ff_ilbc_demuxer,
    &ff_image2_demuxer,
    &ff_image2pipe_demuxer,
    &ff_image2_alias_pix_demuxer,
    &ff_image2_brender_pix_demuxer,
    &ff_ingenient_demuxer,
    &ff_ipmovie_demuxer,
    &ff_ipu_demuxer,
    &ff_ircam_demuxer,
    &ff_iss_demuxer,
    &ff_iv8_demuxer,
    &ff_ivf_demuxer,
    &ff_ivr_demuxer,
    &ff_jacosub_demuxer,
    &ff_jv_demuxer,
    &ff_jpegxl_anim_demuxer,
    &ff_kux_demuxer,
    &ff_kvag_demuxer,
    &ff_laf_demuxer,
    &ff_lc3_demuxer,
    &ff_lmlm4_demuxer,
    &ff_loas_demuxer,
    &ff_luodat_demuxer,
    &ff_lrc_demuxer,
    &ff_lvf_demuxer,
    &ff_lxf_demuxer,
    &ff_m4v_demuxer,
    &ff_mca_demuxer,
    &ff_mcc_demuxer,
    &ff_matroska_demuxer,
    &ff_mgsts_demuxer,
    &ff_microdvd_demuxer,
    &ff_mjpeg_demuxer,
    &ff_mjpeg_2000_demuxer,
    &ff_mlp_demuxer,
    &ff_mlv_demuxer,
    &ff_mm_demuxer,
    &ff_mmf_demuxer,
    &ff_mods_demuxer,
    &ff_moflex_demuxer,
    &ff_mov_demuxer,
    &ff_mp3_demuxer,
    &ff_mpc_demuxer,
    &ff_mpc8_demuxer,
    &ff_mpegps_demuxer,
    &ff_mpegts_demuxer,
    &ff_mpegtsraw_demuxer,
    &ff_mpegvideo_demuxer,
    &ff_mpjpeg_demuxer,
    &ff_mpl2_demuxer,
    &ff_mpsub_demuxer,
    &ff_msf_demuxer,
    &ff_msnwc_tcp_demuxer,
    &ff_msp_demuxer,
    &ff_mtaf_demuxer,
    &ff_mtv_demuxer,
    &ff_musx_demuxer,
    &ff_mv_demuxer,
    &ff_mvi_demuxer,
    &ff_mxf_demuxer,
    &ff_mxg_demuxer,
    &ff_nc_demuxer,
    &ff_nistsphere_demuxer,
    &ff_nsp_demuxer,
    &ff_nsv_demuxer,
    &ff_nut_demuxer,
    &ff_nuv_demuxer,
    &ff_obu_demuxer,
    &ff_ogg_demuxer,
    &ff_oma_demuxer,
    &ff_osq_demuxer,
    &ff_paf_demuxer,
    &ff_pcm_alaw_demuxer,
    &ff_pcm_mulaw_demuxer,
    &ff_pcm_vidc_demuxer,
    &ff_pcm_f64be_demuxer,
    &ff_pcm_f64le_demuxer,
    &ff_pcm_f32be_demuxer,
    &ff_pcm_f32le_demuxer,
    &ff_pcm_s32be_demuxer,
    &ff_pcm_s32le_demuxer,
    &ff_pcm_s24be_demuxer,
    &ff_pcm_s24le_demuxer,
    &ff_pcm_s16be_demuxer,
    &ff_pcm_s16le_demuxer,
    &ff_pcm_s8_demuxer,
    &ff_pcm_u32be_demuxer,
    &ff_pcm_u32le_demuxer,
    &ff_pcm_u24be_demuxer,
    &ff_pcm_u24le_demuxer,
    &ff_pcm_u16be_demuxer,
    &ff_pcm_u16le_demuxer,
    &ff_pcm_u8_demuxer,
    &ff_pdv_demuxer,
    &ff_pjs_demuxer,
    &ff_pmp_demuxer,
    &ff_pp_bnk_demuxer,
    &ff_pva_demuxer,
    &ff_pvf_demuxer,
    &ff_qcp_demuxer,
    &ff_qoa_demuxer,
    &ff_r3d_demuxer,
    &ff_rawvideo_demuxer,
    &ff_rcwt_demuxer,
    &ff_realtext_demuxer,
    &ff_redspark_demuxer,
    &ff_rka_demuxer,
    &ff_rl2_demuxer,
    &ff_rm_demuxer,
    &ff_roq_demuxer,
    &ff_rpl_demuxer,
    &ff_rsd_demuxer,
    &ff_rso_demuxer,
    &ff_rtp_demuxer,
    &ff_rtsp_demuxer,
    &ff_s337m_demuxer,
    &ff_sami_demuxer,
    &ff_sap_demuxer,
    &ff_sbc_demuxer,
    &ff_sbg_demuxer,
    &ff_scc_demuxer,
    &ff_scd_demuxer,
    &ff_sdns_demuxer,
    &ff_sdp_demuxer,
    &ff_sdr2_demuxer,
    &ff_sds_demuxer,
    &ff_sdx_demuxer,
    &ff_segafilm_demuxer,
    &ff_ser_demuxer,
    &ff_sga_demuxer,
    &ff_shorten_demuxer,
    &ff_siff_demuxer,
    &ff_simbiosis_imx_demuxer,
    &ff_sln_demuxer,
    &ff_smacker_demuxer,
    &ff_smjpeg_demuxer,
    &ff_smush_demuxer,
    &ff_sol_demuxer,
    &ff_sox_demuxer,
    &ff_spdif_demuxer,
    &ff_srt_demuxer,
    &ff_str_demuxer,
    &ff_stl_demuxer,
    &ff_subviewer1_demuxer,
    &ff_subviewer_demuxer,
    &ff_sup_demuxer,
    &ff_svag_demuxer,
    &ff_svs_demuxer,
    &ff_swf_demuxer,
    &ff_tak_demuxer,
    &ff_tedcaptions_demuxer,
    &ff_thp_demuxer,
    &ff_threedostr_demuxer,
    &ff_tiertexseq_demuxer,
    &ff_tmv_demuxer,
    &ff_truehd_demuxer,
    &ff_tta_demuxer,
    &ff_txd_demuxer,
    &ff_tty_demuxer,
    &ff_ty_demuxer,
    &ff_usm_demuxer,
    &ff_v210_demuxer,
    &ff_v210x_demuxer,
    &ff_vag_demuxer,
    &ff_vc1_demuxer,
    &ff_vc1t_demuxer,
    &ff_vividas_demuxer,
    &ff_vivo_demuxer,
    &ff_vmd_demuxer,
    &ff_vobsub_demuxer,
    &ff_voc_demuxer,
    &ff_vpk_demuxer,
    &ff_vplayer_demuxer,
    &ff_vqf_demuxer,
    &ff_vvc_demuxer,
    &ff_w64_demuxer,
    &ff_wady_demuxer,
    &ff_wavarc_demuxer,
    &ff_wav_demuxer,
    &ff_wc3_demuxer,
    &ff_webm_dash_manifest_demuxer,
    &ff_webvtt_demuxer,
    &ff_wsaud_demuxer,
    &ff_wsd_demuxer,
    &ff_wsvqa_demuxer,
    &ff_wtv_demuxer,
    &ff_wve_demuxer,
    &ff_wv_demuxer,
    &ff_xa_demuxer,
    &ff_xbin_demuxer,
    &ff_xmd_demuxer,
    &ff_xmv_demuxer,
    &ff_xvag_demuxer,
    &ff_xwma_demuxer,
    &ff_yop_demuxer,
    &ff_yuv4mpegpipe_demuxer,
    &ff_image_bmp_pipe_demuxer,
    &ff_image_cri_pipe_demuxer,
    &ff_image_dds_pipe_demuxer,
    &ff_image_dpx_pipe_demuxer,
    &ff_image_exr_pipe_demuxer,
    &ff_image_gem_pipe_demuxer,
    &ff_image_gif_pipe_demuxer,
    &ff_image_hdr_pipe_demuxer,
    &ff_image_j2k_pipe_demuxer,
    &ff_image_jpeg_pipe_demuxer,
    &ff_image_jpegls_pipe_demuxer,
    &ff_image_jpegxl_pipe_demuxer,
    &ff_image_jpegxs_pipe_demuxer,
    &ff_image_pam_pipe_demuxer,
    &ff_image_pbm_pipe_demuxer,
    &ff_image_pcx_pipe_demuxer,
    &ff_image_pfm_pipe_demuxer,
    &ff_image_pgmyuv_pipe_demuxer,
    &ff_image_pgm_pipe_demuxer,
    &ff_image_pgx_pipe_demuxer,
    &ff_image_phm_pipe_demuxer,
    &ff_image_photocd_pipe_demuxer,
    &ff_image_pictor_pipe_demuxer,
    &ff_image_png_pipe_demuxer,
    &ff_image_ppm_pipe_demuxer,
    &ff_image_psd_pipe_demuxer,
    &ff_image_qdraw_pipe_demuxer,
    &ff_image_qoi_pipe_demuxer,
    &ff_image_sgi_pipe_demuxer,
    &ff_image_svg_pipe_demuxer,
    &ff_image_sunrast_pipe_demuxer,
    &ff_image_tiff_pipe_demuxer,
    &ff_image_vbn_pipe_demuxer,
    &ff_image_webp_pipe_demuxer,
    &ff_image_xbm_pipe_demuxer,
    &ff_image_xpm_pipe_demuxer,
    &ff_image_xwd_pipe_demuxer,
    NULL };
]==],
        ["mcpp_generated/libavformat/muxer_list.c"] = [==[
static const FFOutputFormat * const muxer_list[] = {
    &ff_a64_muxer,
    &ff_ac3_muxer,
    &ff_ac4_muxer,
    &ff_adts_muxer,
    &ff_adx_muxer,
    &ff_aea_muxer,
    &ff_aiff_muxer,
    &ff_alp_muxer,
    &ff_amr_muxer,
    &ff_amv_muxer,
    &ff_apm_muxer,
    &ff_apng_muxer,
    &ff_aptx_muxer,
    &ff_aptx_hd_muxer,
    &ff_apv_muxer,
    &ff_argo_asf_muxer,
    &ff_argo_cvg_muxer,
    &ff_asf_muxer,
    &ff_ass_muxer,
    &ff_ast_muxer,
    &ff_asf_stream_muxer,
    &ff_au_muxer,
    &ff_avi_muxer,
    &ff_avif_muxer,
    &ff_avm2_muxer,
    &ff_avs2_muxer,
    &ff_avs3_muxer,
    &ff_bit_muxer,
    &ff_caf_muxer,
    &ff_cavsvideo_muxer,
    &ff_codec2_muxer,
    &ff_codec2raw_muxer,
    &ff_crc_muxer,
    &ff_dash_muxer,
    &ff_data_muxer,
    &ff_daud_muxer,
    &ff_dfpwm_muxer,
    &ff_dirac_muxer,
    &ff_dnxhd_muxer,
    &ff_dts_muxer,
    &ff_dv_muxer,
    &ff_eac3_muxer,
    &ff_evc_muxer,
    &ff_f4v_muxer,
    &ff_ffmetadata_muxer,
    &ff_fifo_muxer,
    &ff_filmstrip_muxer,
    &ff_fits_muxer,
    &ff_flac_muxer,
    &ff_flv_muxer,
    &ff_framecrc_muxer,
    &ff_framehash_muxer,
    &ff_framemd5_muxer,
    &ff_g722_muxer,
    &ff_g723_1_muxer,
    &ff_g726_muxer,
    &ff_g726le_muxer,
    &ff_gif_muxer,
    &ff_gsm_muxer,
    &ff_gxf_muxer,
    &ff_h261_muxer,
    &ff_h263_muxer,
    &ff_h264_muxer,
    &ff_hash_muxer,
    &ff_hds_muxer,
    &ff_hevc_muxer,
    &ff_hls_muxer,
    &ff_iamf_muxer,
    &ff_ico_muxer,
    &ff_ilbc_muxer,
    &ff_image2_muxer,
    &ff_image2pipe_muxer,
    &ff_ipod_muxer,
    &ff_ircam_muxer,
    &ff_ismv_muxer,
    &ff_ivf_muxer,
    &ff_jacosub_muxer,
    &ff_kvag_muxer,
    &ff_latm_muxer,
    &ff_lc3_muxer,
    &ff_lrc_muxer,
    &ff_m4v_muxer,
    &ff_mcc_muxer,
    &ff_md5_muxer,
    &ff_matroska_muxer,
    &ff_matroska_audio_muxer,
    &ff_microdvd_muxer,
    &ff_mjpeg_muxer,
    &ff_mlp_muxer,
    &ff_mmf_muxer,
    &ff_mov_muxer,
    &ff_mp2_muxer,
    &ff_mp3_muxer,
    &ff_mp4_muxer,
    &ff_mpeg1system_muxer,
    &ff_mpeg1vcd_muxer,
    &ff_mpeg1video_muxer,
    &ff_mpeg2dvd_muxer,
    &ff_mpeg2svcd_muxer,
    &ff_mpeg2video_muxer,
    &ff_mpeg2vob_muxer,
    &ff_mpegts_muxer,
    &ff_mpjpeg_muxer,
    &ff_mxf_muxer,
    &ff_mxf_d10_muxer,
    &ff_mxf_opatom_muxer,
    &ff_null_muxer,
    &ff_nut_muxer,
    &ff_obu_muxer,
    &ff_oga_muxer,
    &ff_ogg_muxer,
    &ff_ogv_muxer,
    &ff_oma_muxer,
    &ff_opus_muxer,
    &ff_pcm_alaw_muxer,
    &ff_pcm_mulaw_muxer,
    &ff_pcm_vidc_muxer,
    &ff_pcm_f64be_muxer,
    &ff_pcm_f64le_muxer,
    &ff_pcm_f32be_muxer,
    &ff_pcm_f32le_muxer,
    &ff_pcm_s32be_muxer,
    &ff_pcm_s32le_muxer,
    &ff_pcm_s24be_muxer,
    &ff_pcm_s24le_muxer,
    &ff_pcm_s16be_muxer,
    &ff_pcm_s16le_muxer,
    &ff_pcm_s8_muxer,
    &ff_pcm_u32be_muxer,
    &ff_pcm_u32le_muxer,
    &ff_pcm_u24be_muxer,
    &ff_pcm_u24le_muxer,
    &ff_pcm_u16be_muxer,
    &ff_pcm_u16le_muxer,
    &ff_pcm_u8_muxer,
    &ff_psp_muxer,
    &ff_rawvideo_muxer,
    &ff_rcwt_muxer,
    &ff_rm_muxer,
    &ff_roq_muxer,
    &ff_rso_muxer,
    &ff_rtp_muxer,
    &ff_rtp_mpegts_muxer,
    &ff_rtsp_muxer,
    &ff_sap_muxer,
    &ff_sbc_muxer,
    &ff_scc_muxer,
    &ff_segafilm_muxer,
    &ff_segment_muxer,
    &ff_stream_segment_muxer,
    &ff_smjpeg_muxer,
    &ff_smoothstreaming_muxer,
    &ff_sox_muxer,
    &ff_spx_muxer,
    &ff_spdif_muxer,
    &ff_srt_muxer,
    &ff_streamhash_muxer,
    &ff_sup_muxer,
    &ff_swf_muxer,
    &ff_tee_muxer,
    &ff_tg2_muxer,
    &ff_tgp_muxer,
    &ff_mkvtimestamp_v2_muxer,
    &ff_truehd_muxer,
    &ff_tta_muxer,
    &ff_ttml_muxer,
    &ff_uncodedframecrc_muxer,
    &ff_vc1_muxer,
    &ff_vc1t_muxer,
    &ff_voc_muxer,
    &ff_vvc_muxer,
    &ff_w64_muxer,
    &ff_wav_muxer,
    &ff_webm_muxer,
    &ff_webm_dash_manifest_muxer,
    &ff_webm_chunk_muxer,
    &ff_webp_muxer,
    &ff_webvtt_muxer,
    &ff_wsaud_muxer,
    &ff_wtv_muxer,
    &ff_wv_muxer,
    &ff_yuv4mpegpipe_muxer,
    NULL };
]==],
        ["mcpp_generated/libavformat/protocol_list.c"] = [==[
static const URLProtocol * const url_protocols[] = {
    &ff_async_protocol,
    &ff_cache_protocol,
    &ff_concat_protocol,
    &ff_concatf_protocol,
    &ff_crypto_protocol,
    &ff_data_protocol,
    &ff_fd_protocol,
    &ff_ffrtmphttp_protocol,
    &ff_file_protocol,
    &ff_ftp_protocol,
    &ff_gopher_protocol,
    &ff_http_protocol,
    &ff_httpproxy_protocol,
    &ff_icecast_protocol,
    &ff_mmsh_protocol,
    &ff_mmst_protocol,
    &ff_md5_protocol,
    &ff_pipe_protocol,
    &ff_prompeg_protocol,
    &ff_rtmp_protocol,
    &ff_rtmpt_protocol,
    &ff_rtp_protocol,
    &ff_srtp_protocol,
    &ff_subfile_protocol,
    &ff_tee_protocol,
    &ff_tcp_protocol,
    &ff_udp_protocol,
    &ff_udplite_protocol,
    NULL };
]==],
        ["mcpp_generated/libavfilter/filter_list.c"] = [==[
static const FFFilter * const filter_list[] = {
    &ff_af_aap,
    &ff_af_abench,
    &ff_af_acompressor,
    &ff_af_acontrast,
    &ff_af_acopy,
    &ff_af_acue,
    &ff_af_acrossfade,
    &ff_af_acrossover,
    &ff_af_acrusher,
    &ff_af_adeclick,
    &ff_af_adeclip,
    &ff_af_adecorrelate,
    &ff_af_adelay,
    &ff_af_adenorm,
    &ff_af_aderivative,
    &ff_af_adrc,
    &ff_af_adynamicequalizer,
    &ff_af_adynamicsmooth,
    &ff_af_aecho,
    &ff_af_aemphasis,
    &ff_af_aeval,
    &ff_af_aexciter,
    &ff_af_afade,
    &ff_af_afftdn,
    &ff_af_afftfilt,
    &ff_af_afir,
    &ff_af_aformat,
    &ff_af_afreqshift,
    &ff_af_afwtdn,
    &ff_af_agate,
    &ff_af_aiir,
    &ff_af_aintegral,
    &ff_af_ainterleave,
    &ff_af_alatency,
    &ff_af_alimiter,
    &ff_af_allpass,
    &ff_af_aloop,
    &ff_af_amerge,
    &ff_af_ametadata,
    &ff_af_amix,
    &ff_af_amultiply,
    &ff_af_anequalizer,
    &ff_af_anlmdn,
    &ff_af_anlmf,
    &ff_af_anlms,
    &ff_af_anull,
    &ff_af_apad,
    &ff_af_aperms,
    &ff_af_aphaser,
    &ff_af_aphaseshift,
    &ff_af_apsnr,
    &ff_af_apsyclip,
    &ff_af_apulsator,
    &ff_af_arealtime,
    &ff_af_aresample,
    &ff_af_areverse,
    &ff_af_arls,
    &ff_af_arnndn,
    &ff_af_asdr,
    &ff_af_asegment,
    &ff_af_aselect,
    &ff_af_asendcmd,
    &ff_af_asetnsamples,
    &ff_af_asetpts,
    &ff_af_asetrate,
    &ff_af_asettb,
    &ff_af_ashowinfo,
    &ff_af_asidedata,
    &ff_af_asisdr,
    &ff_af_asoftclip,
    &ff_af_aspectralstats,
    &ff_af_asplit,
    &ff_af_astats,
    &ff_af_astreamselect,
    &ff_af_asubboost,
    &ff_af_asubcut,
    &ff_af_asupercut,
    &ff_af_asuperpass,
    &ff_af_asuperstop,
    &ff_af_atempo,
    &ff_af_atilt,
    &ff_af_atrim,
    &ff_af_axcorrelate,
    &ff_af_bandpass,
    &ff_af_bandreject,
    &ff_af_bass,
    &ff_af_biquad,
    &ff_af_channelmap,
    &ff_af_channelsplit,
    &ff_af_chorus,
    &ff_af_compand,
    &ff_af_compensationdelay,
    &ff_af_crossfeed,
    &ff_af_crystalizer,
    &ff_af_dcshift,
    &ff_af_deesser,
    &ff_af_dialoguenhance,
    &ff_af_drmeter,
    &ff_af_dynaudnorm,
    &ff_af_earwax,
    &ff_af_ebur128,
    &ff_af_equalizer,
    &ff_af_extrastereo,
    &ff_af_firequalizer,
    &ff_af_flanger,
    &ff_af_haas,
    &ff_af_hdcd,
    &ff_af_headphone,
    &ff_af_highpass,
    &ff_af_highshelf,
    &ff_af_join,
    &ff_af_loudnorm,
    &ff_af_lowpass,
    &ff_af_lowshelf,
    &ff_af_mcompand,
    &ff_af_pan,
    &ff_af_replaygain,
    &ff_af_sidechaincompress,
    &ff_af_sidechaingate,
    &ff_af_silencedetect,
    &ff_af_silenceremove,
    &ff_af_speechnorm,
    &ff_af_stereotools,
    &ff_af_stereowiden,
    &ff_af_superequalizer,
    &ff_af_surround,
    &ff_af_tiltshelf,
    &ff_af_treble,
    &ff_af_tremolo,
    &ff_af_vibrato,
    &ff_af_virtualbass,
    &ff_af_volume,
    &ff_af_volumedetect,
    &ff_asrc_aevalsrc,
    &ff_asrc_afdelaysrc,
    &ff_asrc_afireqsrc,
    &ff_asrc_afirsrc,
    &ff_asrc_anoisesrc,
    &ff_asrc_anullsrc,
    &ff_asrc_hilbert,
    &ff_asrc_sinc,
    &ff_asrc_sine,
    &ff_asink_anullsink,
    &ff_vf_addroi,
    &ff_vf_alphaextract,
    &ff_vf_alphamerge,
    &ff_vf_amplify,
    &ff_vf_atadenoise,
    &ff_vf_avgblur,
    &ff_vf_backgroundkey,
    &ff_vf_bbox,
    &ff_vf_bench,
    &ff_vf_bilateral,
    &ff_vf_bitplanenoise,
    &ff_vf_blackdetect,
    &ff_vf_blend,
    &ff_vf_blockdetect,
    &ff_vf_blurdetect,
    &ff_vf_bm3d,
    &ff_vf_bwdif,
    &ff_vf_cas,
    &ff_vf_ccrepack,
    &ff_vf_chromahold,
    &ff_vf_chromakey,
    &ff_vf_chromanr,
    &ff_vf_chromashift,
    &ff_vf_ciescope,
    &ff_vf_codecview,
    &ff_vf_colorbalance,
    &ff_vf_colorchannelmixer,
    &ff_vf_colorcontrast,
    &ff_vf_colorcorrect,
    &ff_vf_colordetect,
    &ff_vf_colorize,
    &ff_vf_colorkey,
    &ff_vf_colorhold,
    &ff_vf_colorlevels,
    &ff_vf_colormap,
    &ff_vf_colorspace,
    &ff_vf_colortemperature,
    &ff_vf_convolution,
    &ff_vf_convolve,
    &ff_vf_copy,
    &ff_vf_corr,
    &ff_vf_crop,
    &ff_vf_cue,
    &ff_vf_curves,
    &ff_vf_datascope,
    &ff_vf_dblur,
    &ff_vf_dctdnoiz,
    &ff_vf_deband,
    &ff_vf_deblock,
    &ff_vf_decimate,
    &ff_vf_deconvolve,
    &ff_vf_dedot,
    &ff_vf_deflate,
    &ff_vf_deflicker,
    &ff_vf_dejudder,
    &ff_vf_deshake,
    &ff_vf_despill,
    &ff_vf_detelecine,
    &ff_vf_dilation,
    &ff_vf_displace,
    &ff_vf_doubleweave,
    &ff_vf_drawbox,
    &ff_vf_drawgraph,
    &ff_vf_drawgrid,
    &ff_vf_edgedetect,
    &ff_vf_elbg,
    &ff_vf_entropy,
    &ff_vf_epx,
    &ff_vf_erosion,
    &ff_vf_estdif,
    &ff_vf_exposure,
    &ff_vf_extractplanes,
    &ff_vf_fade,
    &ff_vf_feedback,
    &ff_vf_fftdnoiz,
    &ff_vf_fftfilt,
    &ff_vf_field,
    &ff_vf_fieldhint,
    &ff_vf_fieldmatch,
    &ff_vf_fieldorder,
    &ff_vf_fillborders,
    &ff_vf_floodfill,
    &ff_vf_format,
    &ff_vf_fps,
    &ff_vf_framepack,
    &ff_vf_framerate,
    &ff_vf_framestep,
    &ff_vf_freezedetect,
    &ff_vf_freezeframes,
    &ff_vf_fsync,
    &ff_vf_gblur,
    &ff_vf_geq,
    &ff_vf_gradfun,
    &ff_vf_graphmonitor,
    &ff_vf_grayworld,
    &ff_vf_greyedge,
    &ff_vf_guided,
    &ff_vf_haldclut,
    &ff_vf_hflip,
    &ff_vf_histogram,
    &ff_vf_hqx,
    &ff_vf_hstack,
    &ff_vf_hsvhold,
    &ff_vf_hsvkey,
    &ff_vf_hue,
    &ff_vf_huesaturation,
    &ff_vf_hwdownload,
    &ff_vf_hwmap,
    &ff_vf_hwupload,
    &ff_vf_hysteresis,
    &ff_vf_identity,
    &ff_vf_idet,
    &ff_vf_il,
    &ff_vf_inflate,
    &ff_vf_interleave,
    &ff_vf_kirsch,
    &ff_vf_lagfun,
    &ff_vf_latency,
    &ff_vf_lenscorrection,
    &ff_vf_limitdiff,
    &ff_vf_limiter,
    &ff_vf_loop,
    &ff_vf_lumakey,
    &ff_vf_lut,
    &ff_vf_lut1d,
    &ff_vf_lut2,
    &ff_vf_lut3d,
    &ff_vf_lutrgb,
    &ff_vf_lutyuv,
    &ff_vf_maskedclamp,
    &ff_vf_maskedmax,
    &ff_vf_maskedmerge,
    &ff_vf_maskedmin,
    &ff_vf_maskedthreshold,
    &ff_vf_maskfun,
    &ff_vf_median,
    &ff_vf_mergeplanes,
    &ff_vf_mestimate,
    &ff_vf_metadata,
    &ff_vf_midequalizer,
    &ff_vf_minterpolate,
    &ff_vf_mix,
    &ff_vf_monochrome,
    &ff_vf_morpho,
    &ff_vf_msad,
    &ff_vf_multiply,
    &ff_vf_negate,
    &ff_vf_nlmeans,
    &ff_vf_noformat,
    &ff_vf_noise,
    &ff_vf_normalize,
    &ff_vf_null,
    &ff_vf_oscilloscope,
    &ff_vf_overlay,
    &ff_vf_pad,
    &ff_vf_palettegen,
    &ff_vf_paletteuse,
    &ff_vf_perms,
    &ff_vf_photosensitivity,
    &ff_vf_pixdesctest,
    &ff_vf_pixelize,
    &ff_vf_pixscope,
    &ff_vf_premultiply,
    &ff_vf_premultiply_dynamic,
    &ff_vf_prewitt,
    &ff_vf_pseudocolor,
    &ff_vf_psnr,
    &ff_vf_qp,
    &ff_vf_random,
    &ff_vf_readeia608,
    &ff_vf_readvitc,
    &ff_vf_realtime,
    &ff_vf_remap,
    &ff_vf_removegrain,
    &ff_vf_removelogo,
    &ff_vf_reverse,
    &ff_vf_rgbashift,
    &ff_vf_roberts,
    &ff_vf_rotate,
    &ff_vf_scale,
    &ff_vf_scale2ref,
    &ff_vf_scdet,
    &ff_vf_scharr,
    &ff_vf_scroll,
    &ff_vf_segment,
    &ff_vf_select,
    &ff_vf_selectivecolor,
    &ff_vf_sendcmd,
    &ff_vf_separatefields,
    &ff_vf_setdar,
    &ff_vf_setfield,
    &ff_vf_setparams,
    &ff_vf_setpts,
    &ff_vf_setrange,
    &ff_vf_setsar,
    &ff_vf_settb,
    &ff_vf_shear,
    &ff_vf_showinfo,
    &ff_vf_showpalette,
    &ff_vf_shuffleframes,
    &ff_vf_shufflepixels,
    &ff_vf_shuffleplanes,
    &ff_vf_sidedata,
    &ff_vf_signalstats,
    &ff_vf_siti,
    &ff_vf_sobel,
    &ff_vf_split,
    &ff_vf_ssim,
    &ff_vf_ssim360,
    &ff_vf_streamselect,
    &ff_vf_swaprect,
    &ff_vf_swapuv,
    &ff_vf_tblend,
    &ff_vf_telecine,
    &ff_vf_thistogram,
    &ff_vf_threshold,
    &ff_vf_thumbnail,
    &ff_vf_tile,
    &ff_vf_tiltandshift,
    &ff_vf_tlut2,
    &ff_vf_tmedian,
    &ff_vf_tmidequalizer,
    &ff_vf_tmix,
    &ff_vf_tonemap,
    &ff_vf_tpad,
    &ff_vf_transpose,
    &ff_vf_trim,
    &ff_vf_unpremultiply,
    &ff_vf_unsharp,
    &ff_vf_untile,
    &ff_vf_v360,
    &ff_vf_varblur,
    &ff_vf_vectorscope,
    &ff_vf_vflip,
    &ff_vf_vfrdet,
    &ff_vf_vibrance,
    &ff_vf_vif,
    &ff_vf_vignette,
    &ff_vf_vmafmotion,
    &ff_vf_vstack,
    &ff_vf_w3fdif,
    &ff_vf_waveform,
    &ff_vf_weave,
    &ff_vf_xbr,
    &ff_vf_xcorrelate,
    &ff_vf_xfade,
    &ff_vf_xmedian,
    &ff_vf_xpsnr,
    &ff_vf_xstack,
    &ff_vf_yadif,
    &ff_vf_yaepblur,
    &ff_vf_zoompan,
    &ff_vsrc_allrgb,
    &ff_vsrc_allyuv,
    &ff_vsrc_cellauto,
    &ff_vsrc_color,
    &ff_vsrc_colorchart,
    &ff_vsrc_colorspectrum,
    &ff_vsrc_gradients,
    &ff_vsrc_haldclutsrc,
    &ff_vsrc_life,
    &ff_vsrc_mandelbrot,
    &ff_vsrc_nullsrc,
    &ff_vsrc_pal75bars,
    &ff_vsrc_pal100bars,
    &ff_vsrc_perlin,
    &ff_vsrc_rgbtestsrc,
    &ff_vsrc_sierpinski,
    &ff_vsrc_smptebars,
    &ff_vsrc_smptehdbars,
    &ff_vsrc_testsrc,
    &ff_vsrc_testsrc2,
    &ff_vsrc_yuvtestsrc,
    &ff_vsrc_zoneplate,
    &ff_vsink_nullsink,
    &ff_avf_a3dscope,
    &ff_avf_abitscope,
    &ff_avf_adrawgraph,
    &ff_avf_agraphmonitor,
    &ff_avf_ahistogram,
    &ff_avf_aphasemeter,
    &ff_avf_avectorscope,
    &ff_avf_concat,
    &ff_avf_showcqt,
    &ff_avf_showcwt,
    &ff_avf_showfreqs,
    &ff_avf_showspatial,
    &ff_avf_showspectrum,
    &ff_avf_showspectrumpic,
    &ff_avf_showvolume,
    &ff_avf_showwaves,
    &ff_avf_showwavespic,
    &ff_vaf_spectrumsynth,
    &ff_avsrc_avsynctest,
    &ff_avsrc_amovie,
    &ff_avsrc_movie,
    &ff_asrc_abuffer,
    &ff_vsrc_buffer,
    &ff_asink_abuffer,
    &ff_vsink_buffer,
    NULL };
]==],
        ["mcpp_generated/libavdevice/indev_list.c"] = [==[
static const FFInputFormat * const indev_list[] = {
    &ff_dshow_demuxer,
    &ff_gdigrab_demuxer,
    &ff_lavfi_demuxer,
    &ff_vfwcap_demuxer,
    NULL };
]==],
        ["mcpp_generated/libavdevice/outdev_list.c"] = [==[
static const FFOutputFormat * const outdev_list[] = {
    NULL };
]==],
        },
    },
}
