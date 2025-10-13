{ lib
, stdenv
, buildPythonApplication
, fetchFromGitHub
, wrapGAppsHook
, python3
, python3Packages
, meson
, ninja
, pkg-config
, desktop-file-utils
, gobject-introspection
, gtk4
, libadwaita
, gnome
}:

buildPythonApplication rec {
  pname = "timeswitch";
  version = "2023.04.03"; # Based on the latest release in the repo

  src = fetchFromGitHub {
    owner = "fsobolev";
    repo = "timeswitch";
    rev = "refs/tags/${version}"; # Using the tagged release
    hash = "sha256-7QnWrLJb1J3R9p6j8k2VZxYtFmGdHcPqBwKpLmNxSjE="; # This is a placeholder! You need to replace it with the actual hash
  };

  nativeBuildInputs = [
    wrapGAppsHook
    meson
    ninja
    pkg-config
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    libadwaita
    gnome.adwaita-icon-theme
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  # The project uses Meson build system, so we need to configure the build phases accordingly
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

  # This ensures the application can find its GLib schemas
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "$out/share"
      --prefix XDG_DATA_DIRS : "${gnome.adwaita-icon-theme}/share"
    )
  '';

  meta = with lib; {
    description = "Power off, reboot, suspend, send a notification or execute any command on timer";
    homepage = "https://github.com/fsobolev/timeswitch";
    license = licenses.mit; # Check COPYING file in the repo to confirm
    mainProgram = "timeswitch";
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
