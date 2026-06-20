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

}:

gcc13Stdenv.mkDerivation rec {
  pname = "stressfulwm";
  version = "2019-12-02";

  src = fetchFromGitHub {
    owner = "ayzenquwe";
    repo = "stressfulwm";
   #rev = "master";
    rev = "d06531d286a5f00424bf12f7c77b18e11437ff20";
    sha256 = "0qziiim18q3h6k8wa5ac5sb9g331b6fvjzgjm6pp3l4qd7amass3";
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

  makeFlags = [
    "CC=${gcc13Stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    ${gcc13Stdenv.cc.targetPrefix}cc -Os -pedantic -Wall stressfulwm.c -lX11 -o stressfulwm
    ${gcc13Stdenv.cc.targetPrefix}cc -Os -pedantic -Wall slow_solution.c -lX11 -o slow_solution

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp stressfulwm $out/bin/stressfulwm
    cp slow_solution $out/bin/stressfulwm-slow

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/ayzenquwe/stressfulwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "stressfulwm";
  };
}
