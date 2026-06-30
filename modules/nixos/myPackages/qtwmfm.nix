{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  cmake,
  qt6,
}:

stdenv.mkDerivation rec {
  pname = "QtwmFM";
  version = "2026-06-14";

  src = fetchFromGitHub {
    owner = "Siddhartha351";
    repo = "QtwmFM";
   #rev = "main";
    rev = "51faff2cce53a9e54a3a671c201d990e2bd0c99c";
    sha256 = "0978llrbi86gkay08k1z9p569cxpaq4na8aw4zca74lf9iwgxpyc";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    fontconfig
    freetype
    qt6.qtbase
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp qtwmfm $out/bin/qtwmfm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Siddhartha351/QtwmFM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "QtwmFM";
  };
}
