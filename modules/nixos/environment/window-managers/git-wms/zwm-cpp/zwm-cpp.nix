{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
 #ninja,
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
}:

stdenv.mkDerivation rec {
  pname = "zwm-cpp";
  version = "2026-03-01";

  src = fetchFromGitHub {
    owner = "cmanv";
    repo = "zwm";
   #rev = "main";
    rev = "37da72f65b1f2de9981620f1c61891c15aeacff9";
    sha256 = "1017rh3k174w730qanv32hnk8vlmy32dkn52f6rzaljrfv6sq8hi";
  };

  nativeBuildInputs = [
    cmake
   #ninja
    pkg-config
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
  ];

 #cmakeFlags = [ ];

  postInstall = ''
    mkdir -p $out/bin
    cp $out/bin/zwm $out/bin/zwm-cpp
    rm -f $out/bin/zwm
  '';

  meta = with lib; {
    homepage = "https://github.com/cmanv/zwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zwm-cpp";
  };
}
