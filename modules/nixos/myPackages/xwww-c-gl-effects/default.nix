{ lib
, stdenv
, pkg-config
, xorg
, imlib2
, libGL
, glEnabled ? true
}:

# Nix packaging for the gl-effects branch (CPU 2D transitions + the
# optional GLX/GL 3.3-core renderer for cube/axis-spin/swing/page-turn/
# roll-carpet/shatter/paper-plane/burn/melt/ripple).
#
# Deliberately conservative: this just links against nixpkgs' `libGL`
# and does no runpath/driver patching. That's on purpose -- I can't
# verify hook signatures like `addOpenGLRunpath`/`addDriverRunpath`
# against a real nixpkgs checkout from here, and previously guessing
# one wasted your time. If GL fails to find a real driver at runtime,
# xwww degrades to the CPU transitions automatically (see
# README-GL.md) rather than crashing, so this derivation is safe to use
# as-is even in the worst case.
#
# If you want actual GPU acceleration and it's not finding your driver:
#   - NixOS: this is almost always `hardware.opengl.enable = true;`
#     (or `hardware.graphics.enable` on newer nixpkgs) not being set at
#     the system level -- that's what makes a real driver exist to find
#     in the first place, independent of anything in this file.
#   - Non-NixOS (nix-on-$distro, home-manager only): the standard,
#     well-documented community answer for "nix-built GL binary can't
#     see my system driver" is nixGL (https://github.com/guibou/nixGL)
#     -- run the binary through its wrapper, e.g.
#     `nixGLNvidia $out/bin/xwww ...` or `nixGLMesa $out/bin/xwww ...`.
#     I'm pointing you at it rather than trying to reimplement its
#     runpath logic here, since it's a maintained, tested tool built
#     exactly for this and I'd rather not hand you a second guess.
#
# Build without any GL code at all (falls back to the plain 2D CPU
# path for every effect, same as the non-GL branch) with:
#   nix-build --arg glEnabled false

stdenv.mkDerivation rec {
  pname = "xwww";
  version = "1.0.0-gl";

  src = ./.;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    imlib2
  ] ++ lib.optionals glEnabled [ libGL ];

  makeFlags = [
    "PREFIX=$(out)"
    "HAVE_XINERAMA=1"
  ] ++ lib.optional glEnabled "HAVE_GL=1"
    ++ lib.optional (!glEnabled) "HAVE_GL=0";

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Daemonless pure-C X11 animated wallpaper transitions, with an optional GLX/GLSL renderer for the 3D effects";
    homepage = "https://github.com/hameedrezafarrokhi/xwww";
    license = licenses.mit; # adjust if the project's actual license differs
    platforms = platforms.linux;
    mainProgram = "xwww";
  };
}
