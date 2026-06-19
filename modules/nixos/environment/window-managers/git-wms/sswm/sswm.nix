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

  rustup,
  wayland,
  udev,
  libinput,
  libgbm,
  seatd,
}:

rustPlatform.buildRustPackage rec {
  pname = "sswm";
  version = "2023-08-23";

  src = fetchFromGitHub {
    owner = "Walker-00";
    repo = "sswm";
   #rev = "rust";
    rev = "15565d70903e32273b782de106366fc45fc270dd";
    sha256 = "0q2a38c7dr4fpd1agd085gxysjc3b0rbv5g230apj3zqf6ivyp5y";
  };

  nativeBuildInputs = [
    rustup
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

    wayland
    libinput
    udev
    libgbm
    seatd
  ];

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  postFixup = ''
    cp $out/bin/sswm $out/bin/sswm
    rm $out/bin/sswm
  '';

  meta = with lib; {
    homepage = "https://github.com/Walker-00/sswm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sswm";
  };
}
