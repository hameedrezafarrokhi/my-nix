{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
}:

stdenv.mkDerivation rec {
  pname = "xwww";
  version = "0.1.0";

 #src = ./xwww;
  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "xwww";
    rev = "v${version}";
    sha256 = "sha256-dTWlyYfmDuac+2uoDITY4HL4AHfoAcwNwoNZ7JtjO+A=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "X11 Wallpaper Animations";
    homepage = "https://github.com/hameedrezafarrokhi/xwww";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "xwww";
  };
}
