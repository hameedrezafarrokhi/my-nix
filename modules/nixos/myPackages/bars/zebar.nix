{
  lib,
  appimageTools,
  fetchurl,
  version ? "v3.3.1",
  hash ? "sha256-kODazZktZ14RN0CEZf/H6Oi0zy1LvxtJi4kQgItvsJk=",
  arch ? "x64",

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,
  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,
  fontconfig,
  freetype,
  pkg-config,
  libxshmfence,
  libappindicator,
  libpkgconf,
  libnotify,
  libxscrnsaver,
  libxtst,
  libindicator,
  libGL,
  libGLX,
  libGLU,
  ffmpeg-full,
  egl-x11,
  egl-wayland,
  appmenu-gtk-module,

  extraPkgs ? pkgs: [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon
    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor
    fontconfig
    freetype
    pkg-config
    libxshmfence
    libappindicator
    libpkgconf
    libnotify
    libxscrnsaver
    libxtst
    libindicator
    libGL
    libGLX
    libGLU
    ffmpeg-full
    egl-x11
    egl-wayland
    appmenu-gtk-module
  ],
}:

let
  pname = "zebar";

  src = fetchurl {
    url = "https://github.com/glzr-io/${pname}/releases/download/${version}/${pname}-${version}-opt5-${arch}.AppImage";
    inherit hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  inherit pname version src extraPkgs;

 #extraInstallCommands = ''
 #  mkdir -p $out/share/applications
 #  cat > $out/share/applications/${pname}.desktop <<EOF
 #  [Desktop Entry]
 #  Version=${version}
 #  MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/chromium;
 #  StartupNotify=true
 #  Terminal=false
 #  Type=Application
 #  Categories=Network;WebBrowser;
 #  Name=${pname}
 #  Comment=Zen Browser
 #  Exec=$out/bin/${pname}
 #  EOF
 #'';

 #passthru.updateScript = ./update.sh;

  meta = {
    homepage = "https://github.com/glzr-io/zebar";
    platforms = [ "x86_64-linux" ];
  };
}
