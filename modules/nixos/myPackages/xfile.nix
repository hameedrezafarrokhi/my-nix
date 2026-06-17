{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  libx11,
  libxt,
  libxext,
  libxinerama,
  libxrandr,
  libxrender,
  libxcursor,
  libxcomposite,
  libxft,
  libxkbcommon,
  libxpm,
  libxres,
  libxmu,
  libxmi,
  libxmp,
  xorgproto,
  libjpeg_turbo,
  libpng,
  libtiff,
  motif,
  gcc,
  makeWrapper,
}:

let

  slanted-icons = fetchzip {
    url = "https://fastestcode.org/dl/xfile-slanted-icons.tar.xz";
    hash = "sha256-R6p1wpBfLGeD0PyjpilwxJkygdcMuykT5dkvykAidzk=";
    stripRoot = true;
  };

  addons = fetchzip {
    url = "https://fastestcode.org/dl/xfile-addon.tar.xz";
    hash = "sha256-Qjjpl9W/rxalyLrIr1Y8ETkuOB5CjF8zyOLavSIMRmE=";
    stripRoot = true;
  };

in

stdenv.mkDerivation rec {
  pname = "xfile";
  version = "1.2.0";

  src = fetchurl {
    url = "https://fastestcode.org/dl/xfile-src-${version}.tar.xz";
    hash = "sha256-x7ycxfaoNPANRnCLNFYM4OaCLw1L6kIWkR5X+Psjc5c=";
  };

  buildInputs = [
    libx11
    libxt
    libxext
    libxinerama
    libxrandr
    libxrender
    libxcursor
    libxcomposite
    libxft
    libxkbcommon
    libxpm
    libxres
    libxmu
    libxmi
    libxmp
    xorgproto
    libjpeg_turbo
    libpng
    libtiff
    motif
  ];

  buildPhase = ''
    runHook preBuild
    ln -sf ../mf/Makefile.Linux src/Makefile
    make -C src
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    cp src/xfile $out/bin/
    cp src/xfile.1 $out/share/man/man1/
    chmod 755 $out/bin/xfile
    runHook postInstall
  '';

  installTargets = [ ];

  postFixup = ''
    # Create Launcher
    cat > $out/bin/xfile-wrapped << 'EOF'
    #!/usr/bin/env bash

    CONF_DIR="$HOME/.xfile"

    if [ ! -f "$CONF_DIR/icons/dir.l.xpm" ]; then
      mkdir -p "$CONF_DIR/icons"
      mkdir -p "$CONF_DIR/types"
      cp -r ${slanted-icons}/* "$CONF_DIR/icons/"
      cp -r ${addons}/icons/* "$CONF_DIR/icons/"
      cp -r ${addons}/types/* "$CONF_DIR/types/"
    fi

    exec ${pname} "$@"

    EOF

    chmod +x $out/bin/xfile-wrapped

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Version=${version}
    Type=Application
    Name=${pname}
    Comment=Motif File Magaer
    Exec=$out/bin/xfile-wrapped
    EOF
  '';

  meta = {
    homepage = "https://fastestcode.org/xfile.html";
    description = "Image Viewer";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
