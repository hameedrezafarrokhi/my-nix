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

  pkg-config,

  rustPlatform,

  cairo,
  pango,
  pulseaudio,
  dbus,
  wayland,
  wayland-protocols,
  alsa-lib,
  alsa-tools,
  gdk-pixbuf,
  gdk-pixbuf-xlib,
  atk,
  gtk3,
  appmenu-gtk-module,
  makeWrapper,
  autoPatchelfHook,

}:

rustPlatform.buildRustPackage rec {
  pname = "YetAnotherBar";
  version = "2021-08-12";

  src = fetchFromGitHub {
    owner = "PolyMeilex";
    repo = "YetAnotherBar";
   #rev = "master";
    rev = "88a234b435aa76691d27dcb1105185595db33fd6";
    sha256 = "1kx6ijsmh11dbqxks3zwlm1da66w03df927cy6c5kxnlfyf5zpir";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    autoPatchelfHook
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

    cairo
    dbus
    wayland
    wayland-protocols
    pango
    pulseaudio
    alsa-lib
    alsa-tools
    gdk-pixbuf
    gdk-pixbuf-xlib
    atk
    gtk3
    appmenu-gtk-module
  ];

  cargoHash = "sha256-MmP3ZAaKYq1pqMVLSfsLWf8LaGxsaCN+jFthRBJ65AQ=";

 #doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/yetanotherbar \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/yetanotherbar || true
  '';

  meta = with lib; {
    homepage = "https://github.com/PolyMeilex/YetAnotherBar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "YetAnotherBar";
  };
}
