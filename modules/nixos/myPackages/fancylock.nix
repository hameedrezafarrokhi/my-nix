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

  go,
  mpv,
  pam,
  git,

  fetchurl,

  makeWrapper,
  autoPatchelfHook,
  zlib,

}:

stdenv.mkDerivation rec {
  pname = "fancylock";
  version = "2025-10-11";

 #src = fetchFromGitHub {
 #  owner = "tuxx";
 #  repo = "fancylock";
 # #rev = "master";
 #  rev = "ceaca99817c00c7a76fc61b1334171a19f86b620";
 #  sha256 = "1mn5yrfrvclkbqmbp46g48i52nfriz2j0p5ggi1nlnvh6xi9dsx7";
 #};

 #src = fetchurl {
 #  url = "https://github.com/tuxx/fancylock/releases/download/v0.0.9/fancylock-linux-amd64.tar.gz";
 #  hash = "sha256-yK2IHTmwG3WJyJWDo0JEudLUk/eTDDuhQcBXKIBzKKQ=";
 #};

  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "unpatched-bins";
    rev = "b75b645622aa5f5a22ec8926eea392dd7fd2228b";
    sha256 = "18s0k0z7a3vdy9wql2187nd0jscwhmrj8kis9ap2683nsc0g1fip";
  };

 #nativeBuildInputs = [
 #  pkg-config
 #  go
 #];

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

    mpv

    pam

   #git

    makeWrapper
    autoPatchelfHook
    zlib
  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #  "INSTALL_PATH=${placeholder "out"}"
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
 #  cp fancylock-linux-amd64 $out/bin
 #
 #  runHook postInstall
 #'';

  buildPhase = ''
    mkdir -p $out/bin
    cp ${src}/fancylock/fancylock-linux-amd64 $out/bin/fancylock
  '';

  installPhase = ''
    wrapProgram $out/bin/fancylock \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/fancylock || true
  '';

  meta = with lib; {
    homepage = "https://github.com/tuxx/fancylock";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fancylock";
  };
}
