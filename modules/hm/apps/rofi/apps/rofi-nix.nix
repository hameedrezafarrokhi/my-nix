{
  lib,
  stdenvNoCC,
  tk,
  fetchFromGitea,
}:

stdenvNoCC.mkDerivation {
  name = "rofi-nix";
  version = "2026-05-14";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fgaz";
    repo = "rofi-nix";
    rev = "7b1b500bf1693ad25434c5f31ed9cf6d4d3a2e26";
    sha256 = "0zhavn0r0yxqmis76cxi4w3a3qgvxq4xj6ykx0s76ak4vccv2z3h";
  };

  buildInputs = [ tk ];

  installPhase = ''
    runHook preInstall
    install -Dm755 rofi-nix $out/bin/rofi-nix
    runHook postInstall
  '';

  meta = {
    homepage = "https://codeberg.org/fgaz/rofi-nix";
    license = lib.licenses.eupl12;
  };
}
