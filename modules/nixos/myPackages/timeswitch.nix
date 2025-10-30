{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wrapGAppsHook3
, makeWrapper
, python3
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
}:

stdenv.mkDerivation rec {
  pname = "timeswitch";
  version = "2023.04.03";

  src = fetchFromGitHub {
    owner = "fsobolev";
    repo = "timeswitch";
    rev = "refs/tags/${version}";
    hash = "sha256-GNV/GpWHMhW/QJTdmDE+W8QIP2Q9oUdytTJ5Ok49YmI="; # Replace with actual hash
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    makeWrapper
    gobject-introspection
    python3
    desktop-file-utils
    glib
    gsound
    appstream-glib
    appstream
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
    wrapProgram $out/bin/timeswitch \
      --set PYTHONPATH "$PYTHONPATH:$out/share/timeswitch"
  '';

  meta = with lib; {
    description = "Power off, reboot, suspend, send a notification or execute any command on timer";
    homepage = "https://github.com/fsobolev/timeswitch";
    license = licenses.mit;
    mainProgram = "timeswitch";
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
