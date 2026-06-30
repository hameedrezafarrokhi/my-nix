{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "glow";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "glow";
   #rev = "master";
    rev = "9af8ac03e37f79d87ef8fe81a1ce14e4d729efec";
    sha256 = "1ms56p58dsvx2yfsj7iqjgk550q4mp4xgx8nvpswsi235ir24606";
  };

  buildInputs = [ ];

  cargoHash = "sha256-wIlEmTYd38XhA2WV7TxHFeNcMz1ipTV05yj58n4E8KI=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/glow";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "glow";
  };
}
