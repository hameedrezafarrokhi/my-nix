{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libXinerama,
  libXext,
  libXcursor,
  libXrender,
  libXpm,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xclickroot";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "phillbush";
    repo = "xclickroot";
    rev = "master";
    hash = "sha256-c0jBn87UFekAtnHiYNMplEA/7h1v0z1iC4ut/6l/Rlc=";
  };

  buildInputs = [
    libX11
    libXft
    libXinerama
    libXext
    libXcursor
    libXrender
    libXpm
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "MAINPREFIX=$(out)/share/man"
  ];

  meta = {
    description = "X root window click actions";
    homepage = "https://github.com/phillbush/xclickroot";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "xclickroot";
  };
})
