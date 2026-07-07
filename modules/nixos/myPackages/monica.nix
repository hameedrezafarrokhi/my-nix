{
  lib,
  gcc13Stdenv,
  fetchFromGitea,

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

  fltk,

}:

gcc13Stdenv.mkDerivation rec {
  pname = "monica";
  version = "2025-11-12";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "BSDforge";
    repo = "monica";
    rev = "5cdd1de1eaaa4a06d5a0d29fff226e38a8e34b89";
    sha256 = "1ddqkwiplvc3jdxziz7zlbxvxbz9rma5mbc0x9sq21ibq6f6fcvz";
  };

  nativeBuildInputs = [
    pkg-config
    fltk
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
    fltk
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "DESTINATION=${placeholder "out"}/bin"
  ];

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp monica $out/bin/monica
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://codeberg.org/BSDforge/monica";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "monica";
  };
}
