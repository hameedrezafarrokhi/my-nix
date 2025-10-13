{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, python3
, gtk4
, libadwaita
, wrapGAppsHook
, glib
, gobject-introspection
, desktop-file-utils
, libjpeg_turbo
}:

stdenv.mkDerivation rec {
  pname = "avvie";
  version = "2.4";

  src = fetchFromGitHub {
    owner = "Taiko2k";
    repo = "Avvie";
    rev = "v${version}";
    sha256 = "sha256-Y3Tf+EC7uwgVpHltV3qa5aY/5S3ANminfX5RNpGTQGA="; # Replace with actual SHA256
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    gobject-introspection
    (python3.withPackages (ps: with ps; [
      piexif
      pycairo
      pillow
      pygobject3
    ]))
  ];

  postPatch = ''
    substituteInPlace src/main.py \
      --replace-warn 'shutil.which("jpegtran")' 'shutil.which("${libjpeg_turbo}/bin/jpegtran")'
  '';

  mesonFlags = [
    "--prefix=${placeholder "out"}"
  ];

  postInstall = ''
    if [ -d $out/share/glib-2.0/schemas ]; then
      glib-compile-schemas $out/share/glib-2.0/schemas
    fi
    if [ -d $out/share/icons/hicolor ]; then
      gtk4-update-icon-cache -q -t -f $out/share/icons/hicolor
    fi
    update-desktop-database $out/share/applications
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PYTHONPATH : "${python3.withPackages (ps: with ps; [ piexif pycairo pillow pygobject3 ])}/${python3.sitePackages}:$out/share/avvie"
      --prefix GI_TYPELIB_PATH : "${lib.makeLibraryPath [ gtk4 libadwaita glib gobject-introspection ]}"
    )
  '';

  meta = with lib; {
    description = "A simple image cropping and resizing tool for avatars";
    homepage = "https://github.com/Taiko2k/Avvie";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
