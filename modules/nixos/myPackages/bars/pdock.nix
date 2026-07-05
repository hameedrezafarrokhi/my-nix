{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  libGL,
  pkg-config,
  wayland,
  rustPlatform,
  glib,
  pango,
  cairo,
  gdk-pixbuf-xlib,
  gdk-pixbuf,
  dbus,
  graphene,
  gtk4,
}:

rustPlatform.buildRustPackage rec {
  pname = "pdock";
  version = "2023-07-09";

  src = fetchFromGitHub {
    owner = "TadaTeruki";
    repo = "pdock";
    rev = "302925e9e457ced32d4decfcdba103ea4e9e6700";
    sha256 = "1l7m87wycb4mz3k0hlbiw030z1dzkb36g4j86w61jr9jx2fldgx9";
  };

  cargoHash = "sha256-3vw7QO2UqQ+mD2IJ4Zf5uZ/v7TvpdoZ7cz8CZvL8n8I=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    glib
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype

    libGL
    wayland
    glib
    pango
    cairo
    gdk-pixbuf-xlib
    gdk-pixbuf
    dbus
    graphene
    gtk4
  ];

  postInstall = ''
    mkdir -p $out/share/pdock
    cp resources/style.css $out/share/pdock
    cp resources/config $out/share/pdock
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/TadaTeruki/pdock";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "pdock";
  };
}
