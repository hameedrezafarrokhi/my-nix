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
  pname = "rustwm";
  version = "2025-12-25";

  src = fetchFromGitHub {
    owner = "varunsareen15";
    repo = "rwm";
   #rev = "master";
    rev = "f0be437df0c2aebc59b752b412418db557d7a35c";
    sha256 = "09ikpr3b3nbj9imbbxcgj0sg9sv0aclwimn3d4761a4ancmqi2y2";
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

  cargoHash = "sha256-wp33OfHnQYttzI21ALTIT1qVOGmLuDLuNiWDQn+CE5k=";

  doCheck = false;

  postInstall = ''
    cp -f $out/bin/rwm $out/bin/rustwm
    rm -f $out/bin/rwm
  '';

  meta = with lib; {
    homepage = "https://github.com/varunsareen15/rwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rwm";
  };
}
