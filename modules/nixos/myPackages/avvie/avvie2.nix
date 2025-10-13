{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wrapGAppsHook
, makeWrapper
, python3
, python3Packages
, gobject-introspection
, gtk4
, libadwaita
, adwaita-icon-theme
, gnome
, desktop-file-utils
, glib
, gsound
, appstream-glib
, appstream
, gdk-pixbuf
, pango
}:

stdenv.mkDerivation rec {
  pname = "avvie";
  version = "v2.4";

  src = fetchFromGitHub {
    owner = "Taiko2k";
    repo = "Avvie";
    rev = "refs/tags/${version}";
    hash = "sha256-GNV/GpWHMhW/QJTdmDE+W8QIP2Q9oUdytTJ5Ok49YmI="; # Replace with actual hash
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook
    makeWrapper
    gobject-introspection
    python3
    desktop-file-utils
    glib
    gsound
    appstream-glib
    appstream
    gdk-pixbuf
    python3Packages.graphene
    pango
  ];

  buildInputs = [
    gtk4
    libadwaita
    adwaita-icon-theme
    desktop-file-utils
    glib
    gsound
    appstream-glib
    appstream
    gdk-pixbuf
    python3Packages.graphene
    pango
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
  ];

  configurePhase = ''
    runHook preConfigure
    meson setup build --prefix=$out
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    meson compile -C build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    meson install -C build
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "$out/share"
      --prefix XDG_DATA_DIRS : "${adwaita-icon-theme}/share"
    )
  '';

  postFixup = ''
    wrapProgram $out/bin/avvie \
      --set PYTHONPATH "$PYTHONPATH:$out/share/avvie"
  '';

  meta = with lib; {
    description = "wallpaper thingi";
    homepage = "https://github.com/Taiko2k/Avvie";
    license = licenses.mit;
    mainProgram = "timeswitch";
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
