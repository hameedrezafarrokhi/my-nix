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

  libxfixes,

  fontconfig,
  freetype,

  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "sxot";
  version = "2026-05-01";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "NRK";
    repo = "sxot";
    rev = "ce59b990a350fa5126487937602a6a4eb3f96a49";
    sha256 = "15fwm4wizcf259hw99xkpc518aan90pd2glld7n8hpsgzwnsc4pn";
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

    libxfixes

    fontconfig
    freetype
  ];

  buildPhase = ''
    runHook preBuild

    cc -o sxot sxot.c -O3 -s -l X11 -l Xfixes

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/man/man1
    install -Dm755 sxot $out/bin/sxot
    install -Dm644 sxot.1 $out/share/man/man1/sxot.1

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/NRK/sxot";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sxot";
  };
}
