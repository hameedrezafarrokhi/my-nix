{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  gcc,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "bipolarbar";
  version = "2012-01-01";

  src = fetchFromGitHub {
    owner = "moetunes";
    repo = "bipolarbar";
    rev = "master";
    hash = "sha256-w9aghB8zSBldVep0O6O4K8skrJ4Ch9Ci7jewdCaNUbM=";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  nativeBuildInputs = [ gcc ];
  buildInputs = [ libX11 ];

  makeFlags = [ "PREFIX=$(out)" "CC=gcc" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 bipolarbar $out/bin/bipolarbar
    runHook postInstall
  '';

  buildPhase = ''
    runHook preBuild
    cp config.def.h config.h
    make CC=${stdenv.cc.targetPrefix}cc PREFIX=$out
    runHook postBuild
  '';

  dontUseMakeInstall = true;

  meta = with lib; {
    homepage = "https://github.com/moetunes/bipolarbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bipolarbar";
  };
}
