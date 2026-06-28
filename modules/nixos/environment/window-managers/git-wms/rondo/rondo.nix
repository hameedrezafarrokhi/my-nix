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

  motif,
  unclutter-xfixes,
  imlib2Full,
}:

stdenv.mkDerivation rec {
  pname = "rondo";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "HougetsuOS";
    repo = "rondo-legacy";
   #rev = "master";
    rev = "87237767f1f791b9d274b943371ea7ab09039cb3";
    sha256 = "0f5wblbz3bj1ar8jg2lcyvv4izyr73521nzz2mqkk66zv1cgi6d0";
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

    motif
    unclutter-xfixes
    imlib2Full
  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp rondo $out/bin/rondo

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/HougetsuOS/rondo-legacy";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rondo";
  };
}
