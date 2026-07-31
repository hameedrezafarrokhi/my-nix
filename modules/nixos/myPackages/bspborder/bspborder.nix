{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libx11,
}:

stdenv.mkDerivation rec {
  pname = "bspborder";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libx11 ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bspborder $out/bin/bspborder

    runHook postInstall
  '';

  meta = with lib; {
    homepage = " ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bspborder";
  };
}
