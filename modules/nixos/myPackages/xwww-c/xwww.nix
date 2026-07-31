{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libx11,
  libxft,
  libxext,
  libxrender,
  libxinerama,
  imlib2Full,
}:

stdenv.mkDerivation rec {
  pname = "xwww";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libx11 libxft libxext libxrender libxinerama imlib2Full ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp xwww $out/bin/xwww

    runHook postInstall
  '';

  NIX_CFLAG_COMPILE = "-I${imlib2Full.dev}";

  #/include/miniaudio/miniaudio.h

  meta = with lib; {
    homepage = " ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xwww";
  };
}
