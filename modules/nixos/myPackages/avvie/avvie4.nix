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
  ];

  buildInputs = [
    python3
    gtk4
    libadwaita
    glib
    gobject-introspection
  ];

  pythonPath = with python3.pkgs; [
    piexif
    pycairo
    pillow
    pygobject3
  ];

  postPatch = ''
    substituteInPlace src/main.py \
      --replace 'shutil.which("jpegtran")' 'shutil.which("${libjpeg_turbo}/bin/jpegtran")'
  '';

  preConfigure = ''
    export PYTHONPATH=${lib.makeSearchPathOutput "python" "sitePackages" pythonPath}:$PYTHONPATH
  '';

  mesonFlags = [
    "--prefix=${placeholder "out"}"
  ];

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
    # Skip gtk-update-icon-cache if no icons are installed
    if [ -d $out/share/icons/hicolor ]; then
      gtk4-update-icon-cache -q -t -f $out/share/icons/hicolor
    fi
    update-desktop-database $out/share/applications
  '';

  meta = with lib; {
    description = "A simple image cropping and resizing tool for avatars";
    homepage = "https://github.com/Taiko2k/Avvie";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
