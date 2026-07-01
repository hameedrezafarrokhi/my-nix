{
  lib,
  stdenv,
  fetchFromGitea,
  rustPlatform,
  cairo,
  pango,
  pulseaudio,
  pkg-config,
  wayland,
  wayland-protocols,
  libxkbcommon,
  libx11,
  libxft,
  libxext,
  libxrandr,
  libxinerama,
}:

rustPlatform.buildRustPackage rec {
  pname = "kessoku";
  version = "2025-06-01";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ext0l";
    repo = "kessoku";
    rev = "949d74e16721a8e74d98574261dcffc05454f9e7";
    hash = "sha256-9HYrDDAySjPKwcrxD9vfP/ld+hfkgd6rO9rkxvQlJjI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    pango
    cairo
    pulseaudio
    wayland
    wayland-protocols
    libxkbcommon
    libxkbcommon
    libx11
    libxft
    libxext
    libxrandr
    libxinerama
  ];

  cargoHash = "sha256-RigJN72Ktv7klc0A+f+OsIUbBlWADpEE1o8MFqfOKAc=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://codeberg.org/ext0l/kessoku";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "kessoku";
  };
}
