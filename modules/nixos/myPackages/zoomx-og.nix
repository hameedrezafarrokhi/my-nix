{
  lib,
  stdenv,
  fetchFromGitHub,

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

}:

stdenv.mkDerivation rec {
  pname = "zoomx-og";
  version = "2021-02-20";

  src = fetchFromGitHub {
    owner = "nprezant";
    repo = "zoomx";
    rev = "0fbe35169a5c31a405706383a326544daae77402";
    sha256 = "1y7jf54ff7s4xcppm17ivbi33m37lhw58n23lmy3m0yiq52k6xa5";
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
  ];

  buildPhase = ''
    runHook preBuild

    gcc -g zoomx.c -L/usr/X11R6/lib -lX11 -o zoomx

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zoomx $out/bin/zoomx-og

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/nprezant/zoomx";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zoomx-og";
  };
}
