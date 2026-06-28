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
  fetchpatch,
  patches ? [ ],
  conf ? null,

  lua5_1,
}:

stdenv.mkDerivation rec {
  pname = "clubar";
  version = "2024-09-10";

  src = fetchFromGitHub {
    owner = "lycuid";
    repo = "clubar";
   #rev = "master";
    rev = "0481e60a50c6ab4c01d42ab8493aa9418279df21";
    sha256 = "050fbjwajqdszarb3549ln11fx0pfzh6y6fqb4rx4ls8kn8b48cs";
  };


  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.h";


  nativeBuildInputs = [
    pkg-config
    lua5_1
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
    lua5_1
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
   #"DESTDIR=${placeholder "out"}"
   #"BINPREFIX=/bin"
   #"MANPREFIX=/share/man/man1"
  ];

  buildPhase = ''
    runHook preBuild

    make PLUGINS="luaconfig xrmconfig"

    runHook postBuild
  '';

  preInstall = ''
    mkdir -p $out/bin $out/bin $out/share/man/man1
  '';

  installPhase = ''
    runHook preInstall

    strip .build/bin/clubar

    cp -f .build/bin/clubar $out/bin/clubar
    cp clubar.1.tmpl $out/share/man/man1/clubar.1

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/lycuid/clubar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "clubar";
  };
}
