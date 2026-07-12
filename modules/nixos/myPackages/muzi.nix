{
  lib,
  stdenv,
  fetchFromGitHub,
  zig,
  fontconfig,
  freetype,
  pkg-config,
  git,
}:

stdenv.mkDerivation rec {
  pname = "muzi";
  version = "2026-03-22";

  src = fetchFromGitHub {
    owner = "tristanjet";
    repo = "muzi";
    rev = "0fbbb0cbed30d45222e46cb920be9a0aeaa2699b";
    sha256 = "06z8h48lkq9g4mf0a2d5lf8a2hd728kwwmjf4xla3wcqchrksc51";
  };

  nativeBuildInputs = [ pkg-config zig ];

  buildInputs = [ fontconfig freetype git ];

  buildPhase = ''
    runHook preBuild

    zig build -Drelease=true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp muzi $out/bin/muzi

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/tristanjet/muzi";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "muzi";
  };
}
