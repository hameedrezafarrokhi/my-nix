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
  pname = "sophy";
  version = "2025-8-26";

  src = fetchFromGitHub {
    owner = "TextureRotations";
    repo = "SWM";
    rev = "main";
    hash = "sha256-zWmBCgUHxi9Su5MB4hR+0M/dcbqAO+1xd4jNAmJSWeQ=";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    make install DESTDIR=$out
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/TextureRotations/SWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sophy";
  };
}
