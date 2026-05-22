{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libXext,
  libXcursor,
  libXrandr,
  libXcomposite,
  gcc,
  freetype,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "meow";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "wdkaza";
    repo = "meow";
    rev = "main";
    hash = "sha256-HQq7mvZPxI0sHmesLseUThZ4gQqIezxatOihBg3THEI=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libX11
    libXft
    libXext
    libXrandr
    libXcomposite
    libXcursor
    freetype
    gcc
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  buildPhase = ''
    CFLAGS="-Wall -Wextra -I${freetype}/include/freetype2 $(pkg-config --cflags xft x11)"
    LDFLAGS="$(pkg-config --libs xft x11)"
    $CC $CFLAGS -o meow meow.c $LDFLAGS
  '';

  installPhase = ''
    install -Dm755 meow $out/bin/meow
  '';

  meta = with lib; {
    homepage = "https://github.com/wdkaza/meow";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "meow";
  };
}
