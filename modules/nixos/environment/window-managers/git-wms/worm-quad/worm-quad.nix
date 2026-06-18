{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  gcc13,
  writeText,
  fetchpatch,
  patches ? [ ],
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "worm-quad";
  version = "2023-07-03";

  src = fetchFromGitHub {
    owner = "kaicarlisle";
    repo = "worm";
   #rev = "master";
    rev = "a4f87a99a7ec004b89c5d3a8d154733cd5dd76ab";
    sha256 = "14s1a2kv1v2i0cxaj2dsb22f4lz66wa3h9s2dzh26pbf1jm3snvk";
  };

  nativeBuildInputs = [ gcc13 ];

  buildInputs = [ libX11 ];

  inherit patches;

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "CC=${gcc13}/bin/gcc"
    "PREFIX=$(out)"
  ];

  installPhase = ''
    install -Dm 755 worm $out/bin/worm-quad
  '';

  meta = with lib; {
    homepage = "https://github.com/kaicarlisle/worm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "worm-quad";
  };
}
