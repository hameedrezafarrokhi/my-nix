{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  glib,
  libdbusmenu-gtk3,
  gtk3,
  gobject-introspection,
  pkg-config,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "gray";
  version = "unstable-2024-12-12";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "gray";
    rev = "d5a8452c39b074ef6da25be95305a22203cf230e";
    hash = "sha256-s9v9fkp+XrKqY81Z7ezxMikwcL4HHS3KvEwrrudJutw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gobject-introspection
    pkg-config
    vala
  ];

  buildInputs = [
    glib
    libdbusmenu-gtk3
    gtk3
  ];

  meta = {
    description = "Libgray; a status notifier GObject library which can be used to create system trays";
    homepage = "https://github.com/Fabric-Development/gray";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gray";
    platforms = lib.platforms.all;
  };
}
