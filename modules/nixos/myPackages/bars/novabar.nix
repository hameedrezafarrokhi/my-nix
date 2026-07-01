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

  meson,
  ninja,
  gtk3,
  glib,
  libwnck,
  networkmanager,
  vala,

}:

stdenv.mkDerivation rec {
  pname = "NovaBar";
  version = "2026-02-07";

  src = fetchFromGitHub {
    owner = "novik133";
    repo = "NovaBar";
   #rev = "main";
    rev = "e82387e7af5c6d23babd9285b41d3fa792f84649";
    sha256 = "0mjlgnaw2dl05p0smbvbxshmnhj5w3scma0xyaf2z43ib7wfzxb8";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    vala
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

    gtk3
    glib
    libwnck
    networkmanager
  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];
 #
 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp NovaBar $out/bin/NovaBar
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/novik133/NovaBar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "NovaBar";
  };
}
