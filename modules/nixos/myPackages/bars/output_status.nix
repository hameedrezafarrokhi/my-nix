{
  lib,
  stdenv,
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

}:

stdenv.mkDerivation rec {
  pname = "output_status";
  version = "2025-07-16";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "tsugibayashi";
    repo = "output_status";
    rev = "6773337502156acdc5ee75035be0edec5a180d96";
    hash = "sha256-W//UCtYKw9s39INEfSEhryLKW05duysSM/80E1tiv5c=";
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

  buildPhase = ''

  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/output_status
    cp output_status.sh $out/bin/output_status
    chmod +x $out/bin/output_status
    cp start_dwm_statusbar $out/share/output_status_example

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/tsugibayashi/output_status";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "output_status";
  };
}
