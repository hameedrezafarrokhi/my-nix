{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libx11,
  miniaudio,
}:

stdenv.mkDerivation rec {
  pname = "bspwm-sounds";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libx11 miniaudio ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bspwm-sounds $out/bin/bspwm-sounds

    runHook postInstall
  '';

  preBuild = ''
    cp ${miniaudio.dev}/include/miniaudio/miniaudio.h .
  '';

 #NIX_CFLAG_COMPILE = "-I${miniaudio.dev}/include/miniaudio/miniaudio.h";

  meta = with lib; {
    homepage = " ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bspwm-sounds";
  };
}
