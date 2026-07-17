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
  fontconfig,
  freetype,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "menmu";
  version = "2026-07-05";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ocdb";
    repo = "mu";
    rev = "5108c7ace5f73d62d416921c181ba8e9652e9ef8";
    sha256 = "0c5zy8cbb31yrr43rh0mlf3h2x8my1ridpr2118b3hsb30468nd3";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";


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
    fontconfig
    freetype
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp mu $out/bin/menmu

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/ocdb/mu";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "menmu";
  };
}
