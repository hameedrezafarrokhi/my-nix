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
  imlib2Full,
  fontconfig,
  freetype,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "macaron";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "leanghok120";
    repo = "macaron";
    rev = "30ef86725518a02b199f702f1092b94be33648fb";
    sha256 = "0k665q8b9fy8h86w0zq5vcgcg116cxdfrp0gwvzyvpsndns96wq3";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "macaron.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} macaron.c";


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
    imlib2Full
    fontconfig
    freetype
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp macaron $out/bin/macaron

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/leanghok120/macaron";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "macaron";
  };
}
