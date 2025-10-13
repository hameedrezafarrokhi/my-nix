{ stdenv
, lib
, fetchFromGitHub
, meson
, ninja
, pkg-config
, python3
, wrapGAppsHook4
, gtk4
, libadwaita
, gobject-introspection
, jpegoptim
, python3Packages
, wrapGAppsHook
, makeWrapper
, adwaita-icon-theme
, gnome
, desktop-file-utils
, glib
, gsound
, appstream-glib
, appstream
}:

stdenv.mkDerivation rec {
  pname = "avvie";
  version = "v2.4";

  src = fetchFromGitHub {
    owner = "Taiko2k";
    repo = "Avvie";
    rev = "refs/tags/${version}"; # Update to latest commit/tag if needed
    sha256 = "sha256-GNV/GpWHMhW/QJTdmDE+W8QIP2Q9oUdytTJ5Ok49YmI="; # Run with fake hash first, then replace
  };

 #pyproject = true;
 #build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gobject-introspection
    python3Packages.setuptools
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
  ];

  buildInputs = [
    gtk4
    libadwaita
    jpegoptim
    python3Packages.setuptools
    gtk4
    libadwaita
    adwaita-icon-theme
    desktop-file-utils
    glib
    gsound
    appstream-glib
    appstream
  ];

  pythonPath = with python3.pkgs; [
    piexif
    pycairo
    pillow
    pygobject3
    setuptools
  ];

 #dontUseMesonConfigure = true;

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
  ];

  configurePhase = ''
    runHook preConfigure
    meson builddir --prefix=$out
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    ninja -C builddir install
    runHook postBuild
  '';

 #installPhase = ''
 #  runHook preInstall
 #  ninja -C builddir install
 #  runHook postInstall
 #'';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "$out/share"
      --prefix XDG_DATA_DIRS : "${adwaita-icon-theme}/share"
    )
  '';

  postFixup = ''
    wrapProgram $out/bin/timeswitch \
      --set PYTHONPATH "$PYTHONPATH:$out/share/avvie"
  '';



  meta = with lib; {
    description = "Avatar and profile picture editor for GNOME";
    homepage = "https://github.com/Taiko2k/Avvie";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
