{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libbsd,
  writeText,
  pkg-config,
  installShellFiles,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "coma";
  version = "2025-11-01";

  src = fetchFromGitHub {
    owner = "jorisvink";
    repo = "coma";
    rev = "master";
   #hash = "sha256-ebLdNtY8Haeyt5C2Bg4H2Ls06ukae/kmKBPyxyJ3SGc=";
    hash = "sha256-nJhqU5H7Pub2b3UEgwFuhWnE/eHYe8fCcuZ5eB52R40=";
  };

  nativeBuildInputs = [ installShellFiles pkg-config ];

  buildInputs = [
    libX11
    libXft
    libbsd
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.c";

  makeFlags = [ "PREFIX=$(out)" ];

  env = {
    CFLAGS = "-D_GNU_SOURCE";
    LDFLAGS = "-lbsd";
  };

  installPhase = ''
    runHook preInstall

    install -Dm555 coma $out/bin/coma
    install -Dm555 scripts/coma-cmd $out/bin/coma-cmd
    install -Dm555 scripts/coma-remote $out/bin/coma-remote
    install -Dm644 coma.1 $out/share/man/man1/coma.1

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/jorisvink/coma";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "coma";
  };
}
