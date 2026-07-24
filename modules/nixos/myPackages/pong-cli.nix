{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "pong-cli";
 #version = "2019-10-27";
  version = "v1.0.1";

  src = fetchFromGitHub {
    owner = "Noah2610";
    repo = "pong-cli";

   #rev = "b79055de9394e006e0c3a4ced9de727cc4830ec6";
   #sha256 = "1imbsw21jfwhbg15gpx7yhwvhgi9c5byz2zxgfcn0ziv7zz2drrf";

    tag = version;
    hash = "sha256-9Dt0bnXdPu0JsRnNue8MBsXX+uYstSFQo+QlJOfy/u8=";
  };

  cargoHash = lib.fakeHash;

  meta = {
    description = " ";
    homepage = "https://github.com/Noah2610/pong-cli";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "pong-cli";
  };
}
