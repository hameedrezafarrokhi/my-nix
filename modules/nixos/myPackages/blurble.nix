{
  lib,
  fetchFromGitLab,
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
  gtksourceview5,
  vala,
  stdenv,
  blueprint-compiler,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blurble";
  version = "v0.4.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "blurble";
    tag = finalAttrs.version;
    hash = "sha256-wxj+wyD09ueU6p/6Tc7ISI/oLre41DhGVhjsACDsmpE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils

    blueprint-compiler
  ];

  buildInputs = [
    glib
    gtk4
    librsvg
    libsecret
    libadwaita
    gtksourceview5
  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #  meson _build ..
 #
 #  runHook postBuild
 #'';

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin $out/share
 #  meson install -C _build ..
 #
 #  runHook postInstall
 #'';

  # prevent double wrapping
 #dontWrapGApps = true;
 #preFixup = ''
 #  makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
 #'';

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/World/blurble";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "blurble";
  };
})
