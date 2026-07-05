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

}:

stdenv.mkDerivation rec {
  pname = "cairo-dock-core";
  version = "2026-07-03";

  src = fetchFromGitHub {
    owner = "Cairo-Dock";
    repo = "cairo-dock-core";
    rev = "df1fb1538333cf64e4a549ef5f401c8c9fdfa8d4";
    sha256 = "1v1g8l757mj1sr5c2jyipxfgk7nbd8m7kgs6pqmqyysgspmdlkjk";
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
  ];

 #makeFlags = [
 # #"CC=${stdenv.cc.targetPrefix}cc"
 # #"PREFIX=${placeholder "out"}"
 #];

  cmakeFlags = [
   #"-DCMAKE_PREFIX_PATH=$out"
   #"-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_BUILD_TYPE=Release"
    "-Denable-desktop-manager=True"
  ];

  preConfigure = ''
    gio_unix_include_dir="${glib.dev}/include/gio-unix-2.0"
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$gio_unix_include_dir"
  '';

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp cairo-dock-core $out/bin/cairo-dock-core
 #
 #  runHook postInstall
 #'';

  postFixup = ''
    mkdir -p \
      $out/include/cairo-dock/gldit \
      $out/include/cairo-dock/implementations \
      $out/lib/cairo-dock \
      $out/lib/pkgconfig \
      $out/share/man/man1
    cp $out/$out/include/cairo-dock/implementations/* $out/include/cairo-dock/implementations/
    cp $out/$out/include/cairo-dock/gldit/* $out/include/cairo-dock/gldit/
    cp $out/$out/include/cairo-dock/cairo-dock.h $out/include/cairo-dock/
    cp $out/$out/lib/libgldi.so $out/lib/
    cp $out/$out/lib/libgldi.so.3 $out/lib/
    cp $out/$out/lib/libgldi.so.3.6.99 $out/lib/
    cp $out/$out/lib/cairo-dock/libcd-Help.so $out/lib/cairo-dock/
    cp $out/$out/lib/pkgconfig/gldi.pc $out/lib/pkgconfig/
    cp $out/$out/share/man/man1/* $out/share/man/man1/
  '';

  meta = with lib; {
    homepage = "https://github.com/Cairo-Dock/cairo-dock-core";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "cairo-dock-core";
  };
}
