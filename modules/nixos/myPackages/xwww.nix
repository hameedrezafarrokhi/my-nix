{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
}:

stdenv.mkDerivation {
  pname = "xwww";
  version = "0.1.0";

  src = ./xwww;

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "X11 Wallpaper Animations";
    homepage = "https://github.com/hameedrezafarrokhi/xwww";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "xwww";
  };
}
