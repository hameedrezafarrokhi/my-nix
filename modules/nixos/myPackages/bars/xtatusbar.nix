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

  libpulseaudio,
  pulseaudio,

  clang-tools,
}:

stdenv.mkDerivation rec {
  pname = "xtatusbar";
  version = "2026-05-18";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "caskstrength";
    repo = "xtatusbar";
    rev = "32cbc0737b6c9860ae36591b685f5c7d96d057e4";
    sha256 = "0cihzfbznidvwpz345kqwqhs1bv5p1bd2z5a7zmxf1xra902x23a";
  };

  nativeBuildInputs = [
    pkg-config
    clang-tools
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
    libpulseaudio
    pulseaudio
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "DESTDIR=${placeholder "out"}/bin"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/man/man1
    cp xtatusbar $out/bin/xtatusbar
    cp man/xtatusbar.1 $out/share/man/man1/xtatusbar.1

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/caskstrength/xtatusbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xtatusbar";
  };
}
