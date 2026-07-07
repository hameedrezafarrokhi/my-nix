{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  fpc,

}:

stdenv.mkDerivation rec {
  pname = "ttymine";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "mine";
    rev = "b05f655a645a32325268b4a08fb1bc369256c5a1";
    sha256 = "0q2f01k9q7cbvj1zm5w6vdixwji5z7nri8ngfc1sd651k2rfxb2j";
  };

  nativeBuildInputs = [
    pkg-config
    fpc
  ];

  buildInputs = [
    fontconfig
    freetype
  ];

  buildPhase = ''
    runHook preBuild

    fpc ./mine.pas
    cc -o agent agent.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp mine $out/bin/ttymine
    cp agent $out/bin/ttymine-solve
    chmod +x $out/bin/ttymine
    chmod +x $out/bin/ttymine-solve

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/tsoding/mine";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mine";
  };
}
