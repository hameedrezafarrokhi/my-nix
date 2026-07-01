{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxft,
  libxext,
  fontconfig,
  freetype,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "feather";
  version = "2019-07-08";

  src = fetchFromGitHub {
    owner = "dudik";
    repo = "feather";
   #rev = "main";
    rev = "bf5cc3341aeff824874e333e574c667a6798aa10";
    sha256 = "1504z9dn9ksrk546lb653kfa3k85splvq7i1xxcz6cq73p7kp7rd";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libx11 libxft libxext fontconfig freetype ];

  buildPhase = ''
    gcc feather.c -std=c99 -pedantic -lX11 -o feather-bar -lfontconfig -lXft -I/usr/include/freetype2
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp feather-bar $out/bin/feather-bar
  '';

  meta = with lib; {
    homepage = "https://github.com/dudik/feather";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "feather";
  };
}
