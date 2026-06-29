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

  go,
  buildGoModule,

  cairo,

}:

buildGoModule rec {
  pname = "mitewm-go";
  version = "2021-03-18";

  src = fetchFromGitHub {
    owner = "Perukii";
    repo = "mitewm_advanced";
   #rev = "newform";
    rev = "baffe16f0b5d3bb7bbea1bd5e990a7b24be44c18";
    sha256 = "1n0vpvn909mpnjbzfal844myhayq15xdvnfi8cjs7fagqpjqk2bl";
  };

  nativeBuildInputs = [
    pkg-config
    go
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

    cairo
  ];

  vendorHash = null;
  sourceRoot = "source/src";

  buildPhase = ''
    runHook preBuild

    go build -o mitewm ./

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp mitewm $out/bin/mitewm-go
  '';

 #postInstall = ''
 #  cp -f $out/bin/mitewm $out/bin/mitewm-go
 #  rm -f $out/bin/mitewm
 #'';

  meta = with lib; {
    homepage = "https://github.com/Perukii/mitewm_advanced";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mitewm-go";
  };
}
