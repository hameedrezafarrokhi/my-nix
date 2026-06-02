{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  cmake,
  qt6,
  pkg-config,
 #wrapQtAppsHook,
  i3lock,
}:

stdenv.mkDerivation rec {
  pname = "pod";
  version = "v1.1.1";

  src = fetchFromGitHub {
    owner = "maskedsyntax";
    repo = "pod";
   #rev = "master";
    tag = version;
    hash = "sha256-5BdVQBtmYSyVlNWSaqpW1v1fY1PIC175ksap69xCEUM=";
  };

  nativeBuildInputs = [ cmake qt6.qtbase pkg-config qt6.wrapQtAppsHook ];

  buildInputs = [ libX11 qt6.qtbase qt6.qtdeclarative ];

  propagatedBuilInputs = [ i3lock ];

  cmakeFlags = [ "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}" ];

  qtWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath propagatedBuilInputs}" ];

  meta = {
    homepage = "https://github.com/maskedsyntax/pod";
    description = "sleek logout screen";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
