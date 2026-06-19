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

  wtftw,
}:

rustPlatform.buildRustPackage rec {
  pname = "wtftw-contrib";
  version = "2021-01-21";

  src = fetchFromGitHub {
    owner = "kintaro";
    repo = "wtftw-contrib";
   #rev = "master";
    rev = "e55f47df061d0c601a6e217b8bc3244e98b50e49";
    sha256 = "0vmlqfk2bi87gaxn32cv1szjvdqspv5nxdsfi5xjw4mp6clll7vh";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    wtftw

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
    homepage = "https://github.com/kintaro/wtftw-contrib";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wtftw-contrib";
  };
}
