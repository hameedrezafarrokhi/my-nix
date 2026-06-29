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

}:

rustPlatform.buildRustPackage rec {
  pname = "fwwm";
  version = "2024-11-12";

  src = fetchFromGitHub {
    owner = "fawni";
    repo = "fwwm";
   #rev = "master";
    rev = "89fc6b217dadd8fb04636a1fa1e80069eb901811";
    sha256 = "09n04wa92x73vnyshndqga91qra5f2cqazz47721f7nvxq2zq988";
  };

  sourceRoot = "source/cherry";

  nativeBuildInputs = [
    pkg-config
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

  cargoHash = "sha256-akmZlMKzG2u4Vzg/XOqDKzJGStqRz/FmzEG06v6INo8=";

  meta = with lib; {
    homepage = "https://github.com/fawni/fwwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fwwm";
  };
}
