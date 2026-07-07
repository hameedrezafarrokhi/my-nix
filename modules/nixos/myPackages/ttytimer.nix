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

  ncurses5,

  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "ttytimer";
  version = "2025-12-18";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "laladrik";
    repo = "ttytimer";
    rev = "f0e80902bb6a9002dd298b63b71660b438c3d469";
    sha256 = "1viviq2w1m47ia3ana6kp6px9hrsgwk8cp2s6wqqlxwn0w4h3k50";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "ttytimer.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} ttytimer.h";


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

    ncurses5
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    make TOOT=no

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ttytimer $out/bin/ttytimer
    chmod +x $out/bin/ttytimer

    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/laladrik/ttytimer";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ttytimer";
  };
}
