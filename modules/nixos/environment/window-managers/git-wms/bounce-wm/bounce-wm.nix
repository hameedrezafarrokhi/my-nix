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

  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "bounce-wm";
  version = "2019-12-06";

  src = fetchFromGitHub {
    owner = "whichxjy";
    repo = "bounce-wm";
   #rev = "master";
    rev = "602e779829870b417f3b20a240eaf1bf4a0e5a44";
    sha256 = "0a0qv9c9rqsbzwsn7wnlvmp72fb0h9fgg5959shzlk146aclyh2y";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "bounce-wm.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} bounce-wm.c";


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
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bounce-wm $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/whichxjy/bounce-wm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bounce-wm";
  };
}
