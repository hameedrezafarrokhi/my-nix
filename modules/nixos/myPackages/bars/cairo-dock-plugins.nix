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
  cmake,
 #ninja,
  gettext,
  wayland,
  wayland-protocols,
  wayland-scanner,
  vala,
  python3,
  gtk3,
  gtk4,
  glib,
  cairo,
  pango,
  dbus,
  librsvg,
  dbus-glib,
  libxml2,
  libGL,
  egl-x11,
  egl-wayland,
  libGLX,
  libGLU,
  glew,
  glm,
  curl,
  libxtst,
  json_c,
  gtk-layer-shell,
  gtk4-layer-shell,
  libevdev,
  alsa-lib,
  libetpan,
  gnome-menus,
  libxklavier,
  libxxf86vm,
  gvfs,
  upower,
  zeitgeist,
  libexif,
  vte,
  lm_sensors,
  wget,
  libdbusmenu,
  libdbusmenu-gtk3,
  libayatana-appindicator,
  libayatana-indicator,
  libayatana-common,
  ayatana-webmail,
  ayatana-indicator-sound,
  ayatana-indicator-session,
  ayatana-indicator-power,
  ayatana-indicator-messages,
  ayatana-indicator-display,
  ayatana-indicator-datetime,
  ayatana-indicator-bluetooth,
  ayatana-ido,
  libical,
  libpulseaudio,
  pulseaudio,
  webkitgtk_4_1,
  fftw,
  xwininfo,
  wayland-utils,
  libgdiplus,
  gtk-sharp-3_0,
  wirelesstools,
  ruby,
  git,

  cairo-dock,
  crystal,

}:

stdenv.mkDerivation rec {
  pname = "cairo-dock-plug-ins";
  version = "2026-05-13";

  src = fetchFromGitHub {
    owner = "Cairo-Dock";
    repo = "cairo-dock-plug-ins";
    rev = "77abb5eb6b68d59571a690b11d9cf1609c36d023";
    sha256 = "0q8an9xwr893rq2hh71p89rcaicmi08r1rxg83qnz6i02kiwaapj";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
   #ninja
    glib.dev
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

    gettext
    wayland
    wayland-protocols
    wayland-scanner
    vala
    python3
    gtk3
    gtk4
    glib.dev
    cairo
    pango
    dbus
    librsvg
    dbus-glib
    libxml2
    libGL
    egl-x11
    egl-wayland
    libGLX
    libGLU
    glew
    glm
    curl
    libxtst
    json_c
    gtk-layer-shell
    gtk4-layer-shell
    libevdev
    alsa-lib
    libetpan
    gnome-menus
    libxklavier
    libxxf86vm
    gvfs
    upower
    zeitgeist
    libexif
    vte
    lm_sensors
    wget
    libdbusmenu
    libdbusmenu-gtk3
    libayatana-appindicator
    libayatana-indicator
    libayatana-common
    ayatana-webmail
    ayatana-indicator-sound
    ayatana-indicator-session
    ayatana-indicator-power
    ayatana-indicator-messages
    ayatana-indicator-display
    ayatana-indicator-datetime
    ayatana-indicator-bluetooth
    ayatana-ido
    libical
    libpulseaudio
    pulseaudio
    webkitgtk_4_1
    fftw
    xwininfo
    wayland-utils
    libgdiplus
    gtk-sharp-3_0
    wirelesstools
    ruby
    git
    crystal

    cairo-dock
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  cmakeFlags = [
   #"-DCMAKE_PREFIX_PATH=$out"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_BUILD_TYPE=Release"
    "-Denable-desktop-manager=True"
  ];

  preConfigure = ''
    gio_unix_include_dir="${glib.dev}/include/gio-unix-2.0"
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$gio_unix_include_dir"
  '';

 #propagatedBuildInputs = [ cairo-dock ];

  preInstall = ''

    mkdir -p $out
    cp -rf ${cairo-dock}/* $out/

    chmod -R u+rw $out/

    rm -rf $out/lib/systemd/user
    rm -rf $out/share/man/man1
  '';

  installPhase = ''
    runHook preInstall

    make
    make DESTDIR="$out" install
    #cp -rf ${cairo-dock}/* $out/

    runHook postInstall
  '';

 #postInstall = '' '';
 #
 #fixupPhase = '' '';

  meta = with lib; {
    homepage = "https://github.com/Cairo-Dock/cairo-dock-plug-ins";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "cairo-dock-core";
  };
}
