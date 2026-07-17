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

  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "nora";
  version = "2026-07-05";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "stinta";
    repo = "nora";
    rev = "34b7d3378f3613200c0479dd72f4c86ba928eccc";
    sha256 = "08csr0aqsnaz48pga3vj6isbhfbfwbpyjwb3qc92fl5xj2sa3jpr";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.hpp" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.hpp";


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

    g++ main.cpp -o nora $(pkg-config --cflags --libs x11) -O3 -Wall -Wextra

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp nora $out/bin/nora

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/stinta/nora";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "nora";
  };
}
