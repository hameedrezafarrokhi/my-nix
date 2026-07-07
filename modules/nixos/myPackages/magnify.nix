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
  gcc,

}:

stdenv.mkDerivation rec {
  pname = "Magnify";
  version = "2026-01-19";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "schrmh";
    repo = "Magnify";
    rev = "442b658934fc63c2f6ad6654b6492b544d0ec2d9";
    sha256 = "1rx71cgci2pb7jmamjjiifmyi6c408vhmhci57qracrhwqrl3xza";
  };

  nativeBuildInputs = [
    pkg-config
    gcc
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
  ];

  buildPhase = ''
    runHook preBuild

    gcc -o magnify main.c window_management.c mouse_handling.c rendering.c utils.c status_output.c -lX11 -lXinerama

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp magnify $out/bin/Magnify

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/schrmh/Magnify";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "Magnify";
  };
}
