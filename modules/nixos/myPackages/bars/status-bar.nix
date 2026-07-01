{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cairo,
  pango,
  pulseaudio,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "status-bar";
  version = "2025-12-12";

  src = fetchFromGitHub {
    owner = "nktauserum";
    repo = "status-bar";
   #rev = "main";
    rev = "aed56f64786e4e1792513517c355b59f18db5b74";
    sha256 = "0hnr1xq8s28dri973gij5b0yicgs43jvk3mza3xryjnpjxc08rfs";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    pango
    cairo
    pulseaudio
    openssl
  ];

  cargoHash = "sha256-r/nWMLSRvVFRGe/wWOvE2+XdHCAINsArjNc8hY2//9M=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/nktauserum/status-bar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "status-bar";
  };
}
