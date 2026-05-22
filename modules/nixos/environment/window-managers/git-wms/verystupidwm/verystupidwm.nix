{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "verystupidwm";
  version = "2021-01-01";

  src = fetchFromGitHub {
    owner = "fehawen";
    repo = "vswm";
    rev = "master";
    hash = "sha256-0rbkKWbO1yhG7AGQlZyfUdPFU97Yq9Zm+ZgrcdbzVIc=";
  };

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "vswm.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} vswm.c";

  makeFlags = [ "PREFIX=$(out)" "CC=${stdenv.cc.targetPrefix}cc" ];

  installTargets = [ "install" ];

  preInstall = ''
    makeFlagsArray+=("BINDIR=$out/bin")
  '';

  meta = with lib; {
    homepage = "https://github.com/fehawen/vswm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "verystupidwm";
  };
}
