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

  xprop,
  meson,
  ninja,
  cmake,
  cairo,
  xcbutilxrm,
  pod2mdoc,
  perl,
  dash,
}:

stdenv.mkDerivation rec {
  pname = "heawm";
  version = "2022-12-16";

  src = fetchFromGitHub {
    owner = "zsugabubus";
    repo = "heawm";
   #rev = "x11";
    rev = "0b625f7ab542c3eb97a7eadceff414f98c723ce7";
    sha256 = "05z6wx0cxccqvrwb0c53rf17r6l5k7b01sglalaf1jzgds9c9zz9";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    cmake
    cairo
    perl
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

    xprop
    xcbutilxrm
    pod2mdoc
    dash
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/man/man1

    cp heawm.1 $out/share/man/man1/heawm.1
    cp heawm $out/bin/heawm
    cp ${src}/heawmctl $out/bin/heawmctl
    chmod +x $out/bin/heawm
    chmod +x $out/bin/heawmctl

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/zsugabubus/heawm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "heawm";
  };
}
