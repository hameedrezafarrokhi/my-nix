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
  libxcursor,
  libxi,
  libxfixes,
  cairo,
  pango,
  librsvg,
}:

stdenv.mkDerivation rec {
  pname = "cursor-scaler";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxft
    libxext
    libxrender
    libxinerama
    libxcursor
    libxi
    libxfixes
    cairo
    pango
    librsvg
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp cursor-scaler $out/bin/cursor-scaler

    runHook postInstall
  '';

  meta = with lib; {
    homepage = " ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "cursor-scaler";
  };
}
