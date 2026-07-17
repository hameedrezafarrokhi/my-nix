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
  pname = "raijuwm";
  version = "2026-07-05";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "Raiju";
    repo = "raijuwm";
    rev = "fdcd2e46860b5547592afe625ac9b08c54e445e7";
    sha256 = "13ky7knjjvc29d36ip96adbmpsdm9hlgzgdlab5f0jvw45fbda0p";
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
    cp raijuwm $out/bin/raijuwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/Raiju/raijuwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "raijuwm";
  };
}
