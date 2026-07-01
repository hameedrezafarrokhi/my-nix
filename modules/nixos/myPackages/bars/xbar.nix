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
  clang,
  clang-tools,
}:

stdenv.mkDerivation rec {
  pname = "xbar";
  version = "2011-12-16";

  src = fetchFromGitHub {
    owner = "mpu";
    repo = "xbar";
   #rev = "master";
    rev = "6cc788d2889f7e2f872e9d483c1f60b11483f886";
    sha256 = "10wandq2rxfn528f165mb21x0sxk969s0y3vzcnjc9dn047mdrph";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  nativeBuildInputs = [ pkg-config clang clang-tools ];

  buildInputs = [ libx11 libxft libxext fontconfig freetype ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp xbar $out/bin/xbar
  '';

  meta = with lib; {
    homepage = "https://github.com/mpu/xbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xbar";
  };
}
