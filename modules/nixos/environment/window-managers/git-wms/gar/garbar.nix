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

  rustPlatform,
  pkg-config,
  glib,
  cairo,
  pango,
  lua,
}:

rustPlatform.buildRustPackage rec {
  pname = "garbar";
  version = "2026-03-06";

  src = fetchFromGitHub {
    owner = "gardesk";
    repo = "garbar";
   #rev = "trunk";
    rev = "2a2e158c57a90cd1caaef17c2321c136c5df1cd5";
    sha256 = "0caxw91y8zw1axb22ls1ng7b626a3fzwd3bx4n1j7nbkql11jj39";
  };

  nativeBuildInputs = [ pkg-config glib lua ];

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
    pkg-config
    glib
    cairo
    pango
    lua
  ];

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  meta = with lib; {
    homepage = "https://github.com/gardesk/garbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "garbar";
  };
}
