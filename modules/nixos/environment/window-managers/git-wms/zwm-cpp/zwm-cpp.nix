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
}:

stdenv.mkDerivation rec {
  pname = "zwm-cpp";
  version = "2026-03-01";

  src = fetchFromGitHub {
    owner = "cmanv";
    repo = "zwm";
   #rev = "main";
    rev = "b204b3ddb0ac98f6538a2d286434528ec0d3a467";
    sha256 = "1wkbysg3cm7id2f99zk053iw1148ymq9by1yq6mdcs7i08i6i7lc";
  };

  nativeBuildInputs = [
    cmake
    ninja
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
