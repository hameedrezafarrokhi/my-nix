{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, autoreconfHook
, geany

, gtk3
, glib
, glib-networking
, gdk-pixbuf
, atk
, pango
, cairo
, lua5_1
, gtkspell3
, libgit2
, vte
, ctpl
, gpgme
, libsoup_3
, webkitgtk_4_1
, libxml2
, python3
, intltool

, enableAllPlugins ? false
, enabledPlugins ? []
}:

let
  plugins =
    if enableAllPlugins then
      [ "--enable-all-plugins" ]
    else
      [ "--disable-all-plugins" ]
      ++ map (p: "--enable-${p}") enabledPlugins;
in

stdenv.mkDerivation rec {
  pname = "geany-plugins";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "geany";
    repo = "geany-plugins";
    rev = version;
    hash = "sha256-52Z3Mes5A/Hp8umTyZlL+DxFtOTAn6k3amGm9giIwTM=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    intltool
    glib
  ];

  buildInputs = [
    geany
    gtk3
    glib
    glib.dev
    glib-networking
    gdk-pixbuf
    atk
    pango
    cairo
    lua5_1
    gtkspell3
    libgit2
    vte
    ctpl
    gpgme
    libsoup_3
    webkitgtk_4_1
    libxml2
    python3
    intltool
  ];

 #PKG_CONFIG_PATH = "${glib.dev}/lib/pkgconfig";
  PKG_CONFIG_PATH = "${geany.dev}/lib/pkgconfig";

 #GEANY_LIB = "${geany}/lib/geany";

  configureFlags = plugins ++ [ "--with-geany-libdir=${placeholder "out"}/lib/geany" ];

 #inherit configureFlags;

  preConfigure = ''
    gio_unix_include_dir="${glib.dev}/include/gio-unix-2.0"
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$gio_unix_include_dir"
    ./autogen.sh
  '';

  meta = with lib; {
    description = "Combined Geany Plugins collection";
    homepage = "https://plugins.geany.org/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [];
  };
}
