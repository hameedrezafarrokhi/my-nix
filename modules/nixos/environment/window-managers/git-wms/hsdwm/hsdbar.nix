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
  libxkbfile,

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

  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "hsdbar";
  version = "2026-06-16";

  src = fetchFromGitHub {
    owner = "hsdcc";
    repo = "statusbar-hsdwm";
   #rev = "main";
    rev = "8c8d8b468eb8241c6727107ec90eb99393fc9645";
    sha256 = "1sg1xy0dkvnfxsiq90r7c73pgwnwqdblc4cw50kimm05bnh1pxnx";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "a.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} a.c";

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
    libxkbfile

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

  installPhase = ''
    mkdir -p $out/bin
    cp x11_status_bar $out/bin/hsdbar
    rm -f x11_status_bar
  '';

  meta = with lib; {
    homepage = "https://github.com/hsdcc/statusbar-hsdwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "hsdbar";
  };
}
