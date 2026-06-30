{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "rush";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "rush";
   #rev = "master";
    rev = "3f87b8abed210fb136d2f83b4a6c8cd7fa666e86";
    sha256 = "16hbqcbsnhs038qcs53r96dcwjbnks7hhlfafmh1j69hkjbbwwr6";
  };

  buildInputs = [ ];

  cargoHash = "sha256-62pe/0Sa5R5kH6/xvKGUZRTzqDCrMS3dKo+JtTydscc=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/rush";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rush";
  };
}
