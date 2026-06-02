{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  cmake,
  qt6,
  ninja,
}:

stdenv.mkDerivation rec {
  pname = "xmulberry";
  version = "2025-08-01";

  src = fetchFromGitHub {
    owner = "alpqn";
    repo = "xmulberry";
    rev = "main";
    hash = "sha256-BdySyziOYgPWcUi1LW1ZntV5u3MspxkcUVpOPHbtOgA=";
  };

  nativeBuildInputs = [
    cmake
    qt6.qtbase
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libX11
    qt6.qtbase
    qt6.qttools
  ];

  dontFixup = true;

  cmakeFlags = [ "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp xmulberry $out/bin

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/alpqn/xmulberry";
    description = "X Control Story";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
