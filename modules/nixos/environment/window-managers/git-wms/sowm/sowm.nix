{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  writeText,
  fetchpatch,
  patches ? [

    # Titlebar FFFFFFUUUUUUUUUUUUUCKKKKKKK NO INTERNET
   #(fetchpatch {
   #  url = "https://patch-diff.githubusercontent.com/raw/dylanaraps/sowm/pull/57.patch";
   #  sha256 = "sha256-AAAffBjz7+0Khyn9cAAAzReoLTqAAA9gVGshYARGAAA=";
   #})

  ],
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "sowm";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = "sowm";
    rev = "master";
    hash = "sha256-Q65sU5K86pFk3QNlzfxgyoEw6NpBaZQmFOkUFnmoh+U=";
  };

  buildInputs = [ libX11 ];

  inherit patches;

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/dylanaraps/sowm";
    description = "An itsy bitsy floating window manager (220~ sloc!)";
    longDescription = ''
      Floating only.
      Fullscreen toggle.
      Window centering.
      Mix of mouse and keyboard workflow.
      Focus with cursor.
      Rounded corners (through patch)
      Titlebars (through patch)
      Alt-Tab window focusing.
      All windows die on exit.
      No window borders.
      No ICCCM.
      No EWMH.
      etc etc etc
      Patches available here: https://github.com/dylanaraps/sowm/pulls
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sowm";
  };
}
