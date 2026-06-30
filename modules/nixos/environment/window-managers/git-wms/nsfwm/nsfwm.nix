{
  lib,
  gcc13Stdenv,
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

  chicken,
  chickenPackages_5,


}:

gcc13Stdenv.mkDerivation rec {
  pname = "nsfwm";
  version = "2026-02-07";

  src = fetchFromGitHub {
    owner = "mario-goulart";
    repo = "nsfwm";
   #rev = "master";
    rev = "c594e0cd28fa927b7e18e2efa26d7aaef828f631";
    sha256 = "1b6akmnmhaqfgmw2ck532phmd3af9ri4w3rqw7v35ff997zdiw0q";
  };

  nativeBuildInputs = [
    pkg-config
    chicken
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

    chicken
    chickenPackages_5.chickenEggs.xlib
    chickenPackages_5.chickenEggs.matchable
    chickenPackages_5.chickenEggs.linenoise
    chickenPackages_5.chickenEggs.simple-logger
    chickenPackages_5.chickenEggs.srfi-1
    chickenPackages_5.chickenEggs.srfi-18
    chickenPackages_5.chickenEggs.xdg-basedir
  ];

  buildPhase = ''
    runHook preBuild

    csc -static nsfwm.scm -o nsfwm

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp nsfwm $out/bin/nsfwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/mario-goulart/nsfwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "nsfwm";
  };
}
