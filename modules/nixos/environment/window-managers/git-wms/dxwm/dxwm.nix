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
  pname = "dxwm";
  version = "2026-02-28";

  src = fetchFromGitHub {
    owner = "CMOISDEAD";
    repo = "dxwm";
   #rev = "master";
    rev = "c591ed7f9334fccbb4d5357e0af4a7538335218c";
    sha256 = "17lcbq8b9s01m0wwqni3dxl93hgk53v0ddqni7lzc25ywp4g7pbi";
  };

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

 #cargoLock = {
 #  lockFile = "${src}/Cargo.lock";
 #};

  cargoHash = "sha256-wZ/g71lbpGEw01WDhKJz5zKNxw0QYkZBOGEf2L+uqNo=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/CMOISDEAD/dxwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "dxwm";
  };
}
