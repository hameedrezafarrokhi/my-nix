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

  meson,
  ninja,
  vala,
  glib,
  bamf,
  wrapGAppsHook3,

  gnome-settings-daemon,
  dconf,
  git,
  gtk3,
  gnome-menus,
  libgee,
  libwnck,
  libcanberra,
  pango,
  desktop-file-utils,

}:

stdenv.mkDerivation rec {
  pname = "plank-reloaded";
  version = "2026-06-29";

  src = fetchFromGitHub {
    owner = "zquestz";
    repo = "plank-reloaded";
    rev = "164ac2c7355c7d02aea3bee8ccd553546afb7b1a";
    sha256 = "1wvdh0lx2wsqcm8hgiy040hqci6carf660zfxgwxjdpyc1hfilvq";
  };


  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    glib
    bamf
    wrapGAppsHook3  # Added for GSettings support
  ];

  buildInputs = [
    gnome-settings-daemon
    dconf
    glib
    git
    gtk3
    gnome-menus
    libgee
    libwnck
    libcanberra
    pango
    desktop-file-utils
  ];

  # Compile schemas in post-install phase
  postInstall = ''
      glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  patches = [
    "${src}/nix-hide-in-pantheon.patch"
  ];

  meta = with lib; {
    homepage = "https://github.com/zquestz/plank-reloaded";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "plank-reloaded";
  };
}
