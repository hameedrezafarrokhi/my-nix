{
  lib,
  appimageTools,
  fetchurl,
  version ? "v1.0.0-alpha.1",
  hash ? "sha256-7p28Cr2yhMFLVMbPIUKyxrhVFz6Ag7HZgRkJaw0nAQ0=",
  arch ? "x86_64",

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
  ],
}:

let
  pname = "xplorer";

  src = fetchurl {
    url = "https://github.com/kimlimjustin/xplorer/releases/download/${version}/Xplorer_0.99.1_amd64.AppImage";
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
    homepage = "https://github.com/kimlimjustin/xplorer";
    platforms = [ "x86_64-linux" ];
  };
}
