# Nixpkgs-style package for dunst-notif-center.
#
# This is a single-script app (no setup.py/pyproject.toml), so the idiomatic
# nixpkgs shape for it is `stdenv.mkDerivation` + `wrapGAppsHook3` + a Python
# env built with `python3.withPackages`, rather than
# `python3Packages.buildPythonApplication` (that hook expects something
# pip/setuptools can actually build). If this ever grows a proper
# pyproject.toml, switching to buildPythonApplication is a five-minute job.
#
# Usage:
#   nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
# or drop it into an overlay / flake `packages.<system>.dunst-notif-center`.

{ lib
, stdenv
, python3
, gtk3
, librsvg
, gobject-introspection
, wrapGAppsHook3
, makeWrapper
, dunst
}:

let
  pythonEnv = python3.withPackages (ps: [ ps.pygobject3 ]);
in
stdenv.mkDerivation rec {
  pname = "dunst-notif-center";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    makeWrapper
  ];

  # gtk3 needs to be a buildInput (not just nativeBuildInput) so
  # wrapGAppsHook3 picks up its typelibs/GSettings schemas/icon theme paths
  # for GI_TYPELIB_PATH & friends. librsvg provides the gdk-pixbuf loader
  # that SVG urgency/header/close/pin icons actually decode through —
  # without it, .svg icon paths in config.toml would silently fail to load
  # (falls back to the default dot/glyph, per the config's documented
  # fallback behavior, but SVG support just wouldn't work as intended).
  buildInputs = [
    gtk3
    librsvg
  ];

  dontBuild = true;
  dontConfigure = true;
  # We build our own wrapper below via makeWrapper; wrapGAppsHook3 will still
  # find it in $out/bin during its automatic postFixup pass and layer its
  # gapps env vars on top (GI_TYPELIB_PATH, GSETTINGS_SCHEMA_DIR, etc).
  dontWrapGApps = false;

  installPhase = ''
    runHook preInstall

    install -Dm755 notif_center.py "$out/share/dunst-notif-center/notif_center.py"
    install -Dm644 config.toml     "$out/share/dunst-notif-center/config.toml"
    install -Dm644 style.css       "$out/share/dunst-notif-center/style.css"
    install -Dm644 README.md       "$out/share/doc/dunst-notif-center/README.md"

    mkdir -p "$out/bin"
    makeWrapper "${pythonEnv}/bin/python3" "$out/bin/dunst-notif-center" \
      --add-flags "$out/share/dunst-notif-center/notif_center.py" \
      --set DUNST_NOTIF_CENTER_DATA_DIR "$out/share/dunst-notif-center" \
      --prefix PATH : ${lib.makeBinPath [ dunst ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Full-featured notification history center for dunst/X11";
    longDescription = ''
      A GTK3 panel that browses and manages dunst's notification history via
      dunstctl: configurable sort/group, fuzzy search, per-notification
      context-menu actions inferred from the notification's content or a
      user-defined rule table, pinning notifications across reboots, and
      fully configurable layout/keybinds (config.toml) and theming
      (style.css, real GTK CSS).
    '';
    homepage = "https://github.com/YOURNAME/dunst-notif-center";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "dunst-notif-center";
  };
}
