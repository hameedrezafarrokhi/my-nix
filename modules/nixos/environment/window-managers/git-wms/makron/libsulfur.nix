{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,

  meson,
  ninja,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "libsulfur";
  version = "2019-06-06";

  src = fetchFromGitHub {
    owner = "goshhhy";
    repo = "libsulfur";
   #rev = "master";
    rev = "76f74cff4a4594faf4c4b1a1c3da147bc1d59331";
    sha256 = "0pfrvnp3pjxm35jz3k8km326i3250jpl2jyq6h14b1zyrkayp274";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    cmake
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype
  ];

  meta = with lib; {
    homepage = "https://github.com/goshhhy/libsulfur";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "libsulfur";
  };
}
