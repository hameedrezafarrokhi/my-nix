{
  lib,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  gobject-introspection,
  wrapGAppsHook4,
  appstream-glib,
  desktop-file-utils,
  glib,
  gtk4,
  librsvg,
  libadwaita,
  blueprint-compiler,
  rustPlatform,
  libsForQt5,
  yamllint,
  reuse,
  shellcheck,
  cargo-toml-lint,
  appstream,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "muttum";
  version = "2026-03-22";

  src = fetchFromGitLab {
    domain = "gitlab.adorsaz.ch";
    owner = "muttum";
    repo = "muttum";
    rev = "9de1cee81f042f38b90f1996357ba960ead3e2bf"; # main
    sha256 = "13b357sylb6ibiaridndwfj5yrqn895qwhvfnmgn8n9qy8zjwxbh";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils

    blueprint-compiler
    libsForQt5.wrapQtAppsHook
    yamllint
    reuse
    shellcheck
    cargo-toml-lint
    appstream
    libsForQt5.qtbase
    libsForQt5.qtquickcontrols2
    libsForQt5.qtdeclarative
  ];

  buildInputs = [
    glib
    gtk4
    librsvg
    libadwaita
    libsForQt5.qtbase
    libsForQt5.qtquickcontrols2
    libsForQt5.qtdeclarative
  ];

  cargoHash = "sha256-iTiSlAM/4g8Cja5EuGG4hNgjB+ZsMAlka5Hasr4+obo=";

 #dontWrapQtApps = true;
 #dontWrapGApps = true;

  preBuild = ''
    meson setup build-dir
  '';

  buildPhase = ''
    runHook preBuild

    cd build-dir
    #meson configure -Dlomiri=true
    meson configure -Dgnome=true
    meson compile

    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./src/muttum-devel $out/bin/muttum
    chmod +x $out/bin/muttum

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://gitlab.adorsaz.ch/muttum/muttum";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "muttum";
  };
})
