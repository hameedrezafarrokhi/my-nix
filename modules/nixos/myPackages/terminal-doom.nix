{
  lib,
  stdenv,
  fetchFromGitHub,
  zig,
}:

stdenv.mkDerivation rec {
  pname = "terminal-doom";
  version = "2026-04-26";

  src = fetchFromGitHub {
    owner = "cryptocode";
    repo = "terminal-doom";
    rev = "35ab605e37e92616417bc901b2762599fc979a72";
    sha256 = "1j922fsicy1vyg832sricnddhq7d70iqvj3pzr0dvfkgvl6kc36y";
  };

  nativeBuildInputs = [ zig ];

  buildPhase = ''
    runHook preBuild

    zig build -Doptimize=ReleaseFast

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zig-out/bin/terminal-doom $out/bin/terminal-doom

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/cryptocode/terminal-doom";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "terminal-doom";
  };
}
