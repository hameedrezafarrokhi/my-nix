{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "b(ar)-a(in't)-r(ecursive)";
  version = "2012-01-01";

  src = fetchFromGitHub {
    owner = "c00kiemon5ter";
    repo = "bar";
    rev = "master";
    hash = "sha256-Vatq3O4B4B1sythJ4fiatzR22g4zyCTXZ3whit8K7Oo=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libX11
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 bar $out/bin/bar-aint-recursive
    runHook postInstall
  '';

  buildPhase = ''
    runHook preBuild
    cp config.def.h config.h
    make CC=${stdenv.cc.targetPrefix}cc
    runHook postBuild
  '';

  dontUseMakeInstall = true;

  meta = with lib; {
    homepage = "https://github.com/c00kiemon5ter/bar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bar";
  };
}
