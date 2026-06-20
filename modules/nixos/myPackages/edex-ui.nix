{
  lib,
  appimageTools,
  fetchurl,
  version ? "2.2.8",
  hash ? "sha256-yPKM1yHKAyygwZYLdWyj5k3EQaZDwy6vu3nGc7QC1oE=",

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
  ],
}:

let
  pname = "edex-ui";

  src = fetchurl {
    url = "https://github.com/GitSquared/edex-ui/releases/download/v${version}/eDEX-UI-Linux-x86_64.AppImage";
    inherit hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  inherit pname version src extraPkgs;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/edex-ui.desktop $out/share/applications/edex-ui.desktop

    install -m 444 -D ${appimageContents}/edex-ui.png $out/share/icons/hicolor/512x512/apps/edex-ui.png

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/128x128/apps/edex-ui.png $out/share/icons/hicolor/128x128/apps/edex-ui.png
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/16x16/apps/edex-ui.png $out/share/icons/hicolor/16x16/apps/edex-ui.png
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/24x24/apps/edex-ui.png $out/share/icons/hicolor/24x24/apps/edex-ui.png
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/256x256/apps/edex-ui.png $out/share/icons/hicolor/256x256/apps/edex-ui.png
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/32x32/apps/edex-ui.png $out/share/icons/hicolor/32x32/apps/edex-ui.png
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/48x48/apps/edex-ui.png $out/share/icons/hicolor/48x48/apps/edex-ui.png
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/64x64/apps/edex-ui.png $out/share/icons/hicolor/64x64/apps/edex-ui.png
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/96x96/apps/edex-ui.png $out/share/icons/hicolor/96x96/apps/edex-ui.png

    substituteInPlace $out/share/applications/edex-ui.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=edex-ui'
    #echo "StartupWMClass=app.hifile.www.HiFile" >> $out/share/applications/HiFile.desktop
  '';

 #passthru.updateScript = ./update.sh;

  meta = {
    homepage = "https://github.com/GitSquared/edex-ui";
    platforms = [ "x86_64-linux" ];
  };
}
