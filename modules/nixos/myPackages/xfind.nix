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

stdenv.mkDerivation rec {
  pname = "xfind";
  version = "2026-06-26";

  src = fetchurl {
    url = "https://fastestcode.org/dl/xfind-src.tar.xz";
    hash = "sha256-WAcHcAmzwoSux9ZoAhtby/KWFucbw8JmtHUD7uw88lg=";
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
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp xfind $out/bin/
    chmod 755 $out/bin/xfind
    runHook postInstall
  '';

  installTargets = [ ];

  postFixup = ''
    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Version=${version}
    Type=Application
    Name=${pname}
    Comment=Motif File Magaer
    Exec=$out/bin/xfind
    EOF
  '';

  meta = {
    homepage = "https://fastestcode.org/xfind.html";
    description = "Find and Search for XFile";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
