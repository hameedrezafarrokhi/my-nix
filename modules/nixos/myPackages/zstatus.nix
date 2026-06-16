{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  libX11,
  libxft,
  libxinerama,
  libxrandr,
  libxcb,
  libxcb-util,
  libxcb-keysyms,
  libxcb-wm,
  libxcb-cursor,
  libxcb-render-util,
  libxcb-image,
  libxcb-errors,
  xorgproto,
  libxkbcommon,
  freetype,
  tcl-9_0,
  tk-9_0,
  mpd,
  libmpd,
  sbclPackages,
  libbsd,
}:

stdenv.mkDerivation rec {
  pname = "zstatus";
  version = "2026-04-13";

  src = fetchFromGitHub {
    owner = "cmanv";
    repo = "zstatus";
   #rev = "main";
    rev = "5f290215d2bc99b41def9ede0ccac3057f94f2bc";
    sha256 = "03q2m3gjbpzj55xdpdcaasl9af770c09n03v45bmnygka0ivalkn";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    tcl-9_0
    tk-9_0
  ];

  buildInputs = [
    libX11
    libxft
    libxinerama
    libxrandr
    libxcb
    libxcb-util
    libxcb-keysyms
    libxcb-wm
    libxcb-cursor
    libxcb-render-util
    libxcb-image
    libxcb-errors
    xorgproto
    libxkbcommon
    freetype
    mpd
    libmpd
    sbclPackages.freebsd-sysctl
    libbsd
  ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt \
      --replace 'set(CMAKE_C_COMPILER /usr/bin/cc)' '#set(CMAKE_C_COMPILER /usr/bin/cc)'
    substituteInPlace CMakeLists.txt \
      --replace '/usr/local/include/tcl9.0' '${tcl-9_0}/include'
  '';

  cmakeFlags = [
   #"-DCMAKE_C_COMPILER=${stdenv.cc}/bin/cc"
    "-DTCL_INCLUDE_PATH=${tcl-9_0}/include"
  ];

  installTargets = [ "install" ];

  meta = with lib; {
    homepage = "https://github.com/cmanv/zstatus";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zstatus";
  };
}
