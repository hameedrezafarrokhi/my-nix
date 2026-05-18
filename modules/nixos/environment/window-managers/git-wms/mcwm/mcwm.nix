{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libxcb,
  libxcb-cursor,
 #libxcb-errors,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "mcwm";
  version = "2018-10-07";

  src = fetchFromGitHub {
    owner = "mchackorg";
    repo = "mcwm";
    rev = "e4b558fa9e063be7e1a48d4d90d3f69f4ad3df71";
    hash = "sha256-0TnPN9hpjZJpqK8YX/Uzav55Tkp0VlWZqiV74VeHwak=";
  };

  buildInputs = [
    libX11
    libxcb
    libxcb-cursor
   #libxcb-errors
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
  ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace '/usr/local' '$out' \
      --replace '/bin/rm' 'rm' \
      --replace '-I/usr/local/include' "" \
      --replace '-L/usr/local/lib' "" \
      --replace '-lxcb-util' '-lxcb'
  '';

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "PREFIX=$(out)" ];

  installTargets = [ "install" ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1

    install -m755 mcwm $out/bin/
    install -m755 hidden $out/bin/

    install -m644 mcwm.man $out/share/man/man1/mcwm.1
    install -m644 hidden.man $out/share/man/man1/hidden.1
  '';

  meta = with lib; {
    homepage = "https://github.com/mchackorg/mcwm";
    description = "mcwm is minimalist, floating window manager written using XCB, the X protocol C binding.";
    longDescription = ''
      mcwm is minimalist, floating window manager written using XCB, the X protocol C binding.
      The only window decoration is a thin border. All functions can be done with the keyboard, but moving, resizing, raising and lowering can also be done with the mouse.
      If you don't like the default key bindings, border width, et cetera, look in the config.h file, change and recompile.
      See the manual page for how to use it.
      mcwm has been forked a few times. It was the beginning of the 2bwm window manager, for instance.
      https://hack.org/mc/projects/mcwm
      To contact me, write to:
      Michael Cardell Widerkrantz, mc at the domain hack.org.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mcwm";
  };
}
