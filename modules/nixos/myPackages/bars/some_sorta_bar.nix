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
  pname = "some_sorta_bar";
  version = "2012-01-01";

  src = fetchFromGitHub {
    owner = "moetunes";
    repo = "Some_sorta_bar";
    rev = "master";
    hash = "sha256-tVG0MSe5Q9AFYSULn7dlPCkXdkBd24eUht+rXq0eRGk=";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "some_sorta_bar.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} some_sorta_bar.c";

  makeFlags = [
    "PREFIX=$(out)"
    "CC=gcc"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm 755 some_sorta_bar $out/bin/some_sorta_bar
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/moetunes/Some_sorta_bar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "some_sorta_bar";
  };
}
