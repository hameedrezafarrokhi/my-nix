{
  lib,
  python3,
  fetchFromGitea,
  meson,
  ninja,
  pkg-config,
  gobject-introspection,
  wrapGAppsHook4,
  appstream-glib,
  desktop-file-utils,
  glib,
  gtk4,
  librsvg,
  libsecret,
  libadwaita,

  blueprint-compiler,
  appstream,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "lockpicker";
  version = "v1.4.1";
  pyproject = false;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "sstendahl";
    repo = "lockpicker";
    tag = finalAttrs.version;
    hash = "sha256-P3iYYKCeiagYoOJvEZSYs58wHvbR2j1epclFyeOhNaQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils

    appstream
    blueprint-compiler
  ];

  buildInputs = [
    glib
    gtk4
    librsvg
    libsecret
    libadwaita
  ];

  dependencies = with python3.pkgs; [
    pygobject3
    requests
    packaging
  ];

  # prevent double wrapping
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    description = " ";
    homepage = "https://codeberg.org/sstendahl/lockpicker";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "lockpicker";
    maintainers = with lib.maintainers; [ ];
  };
})
