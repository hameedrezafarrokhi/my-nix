{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  ninja,
  libsForQt5,
  lua5_4,

}:

stdenv.mkDerivation rec {
  pname = "loom";
  version = "beta_1.3.0";

  src = fetchFromGitHub {
    owner = "TrisH0x2A";
    repo = "loom";
    rev = version;
    hash = "sha256-GRe4Ps3SzAyYGeuXU5C8Cx09XgA8rQ9IWX+dOLrXeq0=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    lua5_4
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.wrapQtAppsHook
    libsForQt5.qttools
    libsForQt5.ktexteditor
    libsForQt5.syntax-highlighting
    lua5_4
  ];

  buildPhase = ''
    cmake -DCMAKE_BUILD_TYPE=Release ..
    cmake --build . -j$(nproc)
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp loom $out/bin/loom
  '';

  meta = {
    homepage = "https://github.com/TrisH0x2A/loom";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
