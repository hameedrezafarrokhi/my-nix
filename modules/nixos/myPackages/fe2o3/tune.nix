{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pulseaudio,
  makeWrapper,
  autoPatchelfHook,
}:

let

  crust = fetchFromGitHub {
    owner = "isene";
    repo = "crust";
   #rev = "master";
    rev = "7d2e5ef009042c299b3c84ebd249df1f0f3e3103";
    sha256 = "0fsxiwp25qf7p8h6674n1bmmfci3kahkjhvvc0n9xz1fy4d2dfl3";
  };

  glow = fetchFromGitHub {
    owner = "isene";
    repo = "glow";
   #rev = "master";
    rev = "9af8ac03e37f79d87ef8fe81a1ce14e4d729efec";
    sha256 = "1ms56p58dsvx2yfsj7iqjgk550q4mp4xgx8nvpswsi235ir24606";
  };

in

rustPlatform.buildRustPackage rec {
  pname = "tune";
  version = "2026-06-18";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "tune";
   #rev = "master";
    rev = "698ac8172f9ddb3a10c505490e0f5be4ffe45db2";
    sha256 = "08yz5diflassdbdy3bpd4aqz5cvnrf7821xfwif7ynlidx9s0v9x";
  };

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];

  buildInputs = [ pulseaudio ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../glow' '${glow}'
  '';

  cargoHash = "sha256-RFGKTYcwV7ujAE02JumZFAGI9+YabcK5CFT0JHpLeFw=";

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/tune \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/tune || true
  '';

  meta = with lib; {
    homepage = "https://github.com/isene/tune";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "tune";
  };
}
