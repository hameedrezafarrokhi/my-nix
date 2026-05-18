{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
 #st,
 #dmenu,
}:

stdenv.mkDerivation rec {
  pname = "aphelia";
  version = "2020-1-31";

  src = fetchFromGitHub {
    owner = "vardy";
    repo = "aphelia";
    rev = "master";
    hash = "sha256-DNQf6clFoDbLTSjGVGWdD2wjV3N5vyA8j1ooct7u5Ow=";
  };

 #src = ./aphelia;

  buildInputs = [ libX11 ];

  #makeFlags = [
  #  "CC=${stdenv.cc.targetPrefix}cc"
  #  "PREFIX=$(out)"
  #];

  buildPhase = ''
    runHook preBuild
    $CC $CFLAGS -I${libX11}/include aphelia.c -L${libX11}/lib -lX11 -o aphelia
    runHook postBuild
  '';

  #  substitueInPlace aphelia.c \
  #    --replace 'system("st &")' 'system("${st}/bin/st &")' \
  #    --replace 'system("dmenu_run")' 'system("${dmenu}/bin/dmenu_run")'

  #postPatch = ''
  #  sed -i 's/system("st &");/\/\/ system("st &");/' aphelia.c && sed -i 's/system("dmenu_run");/\/\/ system("dmenu_run");/' aphelia.c
  #  sed -i 's/Mod1Mask/Mod4Mask/g' aphelia.c
  #'';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp aphelia $out/bin/aphelia

    mkdir -p $out/share/man/man1
    cp aphelia.1 $out/share/man/man1/aphelia.1

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/vardy/aphelia";
    description = "The minimalist window manager (~112 LOC)";
    longDescription = ''
      This window manager is single-file and small binary with low resource consumption. Personally, I find it's useful for focused work where you aren't moving around too much and don't need multiple workspaces (it doesn't support them, obviously).
      This project was previously a work of satire, going under a different name, however I have decided to continue the project as it seems functional and ready to be improved upon.
      Push window backwards Alt+a
      Pull window forward Alt+s
      Kill window Alt+q
      Open (Suckless) Simple Terminal (st) Alt+Return
      Open dmenu Alt+d
      Kill window manager Alt+Backspace
      Move windows Alt+Left Click
      Resize windows Alt+Right Click
      New key-binds are added by editing aphelia.c and re-compiling. It's actually pretty self-explanatory as the code is quite repetetive. Couple copy-pastes, tops.
      Here is the repository before the sanitising commit: https://github.com/vardy/aphelia/tree/01dc35684c14d09a4f9b760ce7bb6377fd40c8c2 (uwurawrxdwm)
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "aphelia";
  };
}
