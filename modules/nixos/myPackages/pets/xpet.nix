{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXcursor,
  libXft,
  libXpm,
  xorgproto,
  fontconfig,
  freetype,
  pkg-config,
  gnumake,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "xpet";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "uint23";
    repo = "xpet";
    rev = "master";
    hash = "sha256-neMfdX9ac3fWciOnt90XzWjfSU2Tf9f1Azuok7QWr3g=";
  };

  nativeBuildInputs = [ pkg-config gnumake ];

  buildInputs = [
    libX11
    libXext
    libXcursor
    libXft
    libXpm
    xorgproto
    freetype
    fontconfig
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";


  makeFlags = [
    "PREFIX=$out"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  buildPhase = ''
    make clean xpet
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp xpet $out/bin/xpet
    mkdir -p $out/share/man/man1
    cp xpet.1 $out/share/man/man1/xpet.1
    mkdir -p $out/share/xpet
    cp -r pets $out/share/xpet/
  '';

  postInstall = ''
    install -Dm644 xpet.1 $out/share/man/man1/xpet.1
  '';

  meta = with lib; {
    homepage = "https://github.com/uint23/xpet";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xpet";
  };
}
