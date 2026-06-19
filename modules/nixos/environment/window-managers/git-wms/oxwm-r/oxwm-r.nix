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

  python313Packages,
}:

rustPlatform.buildRustPackage rec {
  pname = "oxwm-r";
  version = "2021-06-09";

  src = fetchFromGitHub {
    owner = "oxwm";
    repo = "oxwm";
   #rev = "main";
    rev = "d754b5e171003e2b214a36b2aedbbf90dcb33271";
    sha256 = "1z1z5cbnmlsg9w2cbga2b1jqc4b04kc24g1680b5dfd34yvzmpam";
  };

  nativeBuildInputs = [ python313Packages.python ];

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

    python313Packages.python
  ];

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  postFixup = ''
    cp $out/bin/oxwm $out/bin/oxwm-r
    rm $out/bin/oxwm
  '';

  meta = with lib; {
    homepage = "https://github.com/oxwm/oxwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "oxwm-r";
  };
}
