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

  glib,

  writeText,
  fetchpatch,
  patches ? [ ],
  conf ? null,

  libpulseaudio,
  pulseaudio,
}:

stdenv.mkDerivation rec {
  pname = "glitch";
  version = "2026-04-30";

  src = fetchFromGitHub {
    owner = "mitjafelicijan";
    repo = "glitch";
   #rev = "master";
    rev = "45bdd25e444aa2887da8c24f9bc68d153b83bc77";
    sha256 = "1y0f2garsv8pgv6syq3j4ph8v4540lxamn1qyg815q8gnciq8wh8";
  };


  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  preBuild = ''
    cp config.def.h config.h
  '';

  nativeBuildInputs = [
    pkg-config
    glib
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

    libpulseaudio
    pulseaudio
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "DESTDIR=${placeholder "out"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 glitch $out/bin/glitch

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/mitjafelicijan/glitch";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "glitch";
  };
}
