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
}:

stdenv.mkDerivation rec {
  pname = "xcountdown";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libx11 libxft libxext libxrender libxinerama ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp countdown $out/bin/xcountdown

    runHook postInstall
  '';

  meta = with lib; {
    homepage = " ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xcountdown";
  };
}
