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

  ninja,
  imlib2Full,
  fribidi,
  zig,
}:

stdenv.mkDerivation rec {
  pname = "seiwm";
  version = "2024-05-23";

  src = fetchFromGitHub {
    owner = "Fuwn";
    repo = "seiwm";
   #rev = "main";
    rev = "884164c616593b7efe77d5c50aebc6bd0ce0f34f";
    sha256 = "1dvidww3yjg3f7mqqva8b67kxls5vcz3wb33zif12954hdpd900c";
  };

  prePatch = ''
    substituteInPlace build.ninja \
      --replace '/usr/' '${placeholder "out"}/'

    substituteInPlace config.ninja \
      --replace '/usr/local' '${placeholder "out"}'

    substituteInPlace config.ninja \
      --replace '-flto=auto' ' '

    substituteInPlace config.ninja \
      --replace 'BDINC = /usr/include/fribidi' 'BDINC = ${fribidi.dev}/include/fribidi'

    mkdir -p $out/share/xsessions

  '';

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";


  nativeBuildInputs = [
    pkg-config
    ninja
    zig
    fribidi.dev
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
    imlib2Full
   #fribidi
    fribidi.dev

  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    CC="zig cc" ninja install

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    #mkdir -p $out/bin
    #cp sei $out/bin/sei

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Fuwn/seiwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "seiwm";
  };
}
