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

  rustPlatform,

  python313Packages,

}:

rustPlatform.buildRustPackage rec {
  pname = "bouncy-window-manager";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "tnjd";
    repo = "bouncy-window-manager";
   #rev = "master";
    rev = "5be21ec39b784c920553c02ee940ae4e601b3414";
    sha256 = "0jlhfwh1bpzqyhy6d9z3s8yyja9nv69r58r76l0iisq965mglr27";
  };

  nativeBuildInputs = [
    pkg-config
    python313Packages.python
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

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  meta = with lib; {
    homepage = "https://github.com/tnjd/bouncy-window-manager";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bouncy-window-manager";
  };
}
