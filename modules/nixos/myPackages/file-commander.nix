{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXft,
  libXinerama,
  libXrandr,
  libXrender,
  libXcursor,
  qt6,
  pkg-config,
  hunspell,
}:

stdenv.mkDerivation rec {
  pname = "file-commander";
  version = "2026-06-25";

  src = fetchFromGitHub {
    owner = "VioletGiraffe";
    repo = "file-commander";
   #rev = "master";
    rev = "25b66aaffb34c6e9acdcf7e9aaff4211c60a1d97";
    sha256 = "04nhmnxl41msfci6hh08b9r3fykn8p474xmnw49lmn9517ya6g5i";
  };

  env = {
    QT_SELECT=6;
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    libX11
    libXft
    libXinerama
    libXrandr
    libXrender
    libXcursor
    hunspell
    qt6.qtbase
    qt6.qttools
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild
    qmake -r
    make -j
    runHook postBuild
  '';

 #installPhase = ''
 #  runHook preInstall
 #  mkdir -p $out/share/file-commander
 #  mkdir -p $out/bin
 #  install -d $out/share/file-commander
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/VioletGiraffe/file-commander";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "file-commander";
  };
}
