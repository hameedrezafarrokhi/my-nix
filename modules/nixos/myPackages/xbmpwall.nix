{
  lib,
  stdenv,
  fetchFromGitea,

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

  libxaw,

}:

stdenv.mkDerivation rec {
  pname = "xbmpwall";
  version = "2024-01-06";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "daltomi";
    repo = "xbmpwall";
    rev = "cfdb35bdd9427975f86c051c8f3e6fe2712a3677";
    sha256 = "02izk8j66pbdfshywzf1iafdjisl880x34yv6a2gi13x265kiv8i";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
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

    libxaw
  ];

 #makeFlags = [
 # #"CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications $out/share/xbmpwall/bitmaps $out/share/icons/hicolor/512x512/apps
    cp xbmpwall $out/bin/xbmpwall
    chmod +x $out/bin/xbmpwall
    cp desktop/xbmpwall.xbm $out/share/xbmpwall/bitmaps/xbmpwall.xbm
    cp desktop/xbmpwall.png $out/share/icons/hicolor/512x512/apps/xbmpwall.png

    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=XBmpWall
    Icon=xbmpwall
    Exec=bash -c "/run/current-system/sw/bin/xbmpwall /run/current-system/sw/share/xbmpwall/bitmaps/xbmpwall.xbm"
    Terminal=false
    MimeType=
    Categories=Utility
    Name[es_ES]=XBmpWall
    Comment[es_ES]=Administrador de bitmaps (.xbm) para xsetroot
    Name[en_US]=XBmpWall
    Comment[en_US]=X11 bitmaps file manager (.xbm) for xsetroot
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/daltomi/xbmpwall";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xbmpwall";
  };
}
