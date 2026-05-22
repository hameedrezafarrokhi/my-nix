{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXinerama,
  dzen2,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "catwm-djmasde";
  version = "2019-03-014";

  src = fetchFromGitHub {
    owner = "djmasde";
    repo = "catwm";
    rev = "master";
    hash = "sha256-oykPpuOOQ/Rl6CGtAp3ZFaYAQj7HJw/HOhHikruwID8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libX11 libXinerama libXext dzen2 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [
    "MANPREFIX=${placeholder "out"}/share/man"
    "PREFIX=${placeholder "out"}"
  ];

  installTargets = [ "install" ];

  meta = with lib; {
    homepage = "https://github.com/djmasde/catwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "catwm-djmasde";
  };
}
