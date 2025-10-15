{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.software.codecs.enable) {

  environment.systemPackages = with pkgs; [

    ffmpeg-full
   #((ffmpeg-full.override {
   #    withUnfree = true;
   #    withHeadlessDeps = true;
   #    withFullDeps = true;
   #    withNvcodec = true;
   #    withGPL = true;
   #  }).overrideAttrs (_:{doCheck = false; }))
   #ffmpeg
    ffmpegthumbnailer
    flac
    fdk_aac
    libopenaptx
   #libfreeaptx
    lame

    taglib_extras
    wslay
  ##previewqt   # WARNING BROKEN LONG TIME

    x265
    x264
    libde265
    openh264
    libvpx

    libdvdnav
    libdvdcss
    libdvdread
    libbluray

    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi

  ];

};}
