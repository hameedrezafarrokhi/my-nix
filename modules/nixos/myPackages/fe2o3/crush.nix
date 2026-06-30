{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

let

  crust = fetchFromGitHub {
    owner = "isene";
    repo = "crust";
   #rev = "master";
    rev = "7d2e5ef009042c299b3c84ebd249df1f0f3e3103";
    sha256 = "0fsxiwp25qf7p8h6674n1bmmfci3kahkjhvvc0n9xz1fy4d2dfl3";
  };

in

rustPlatform.buildRustPackage rec {
  pname = "crush";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "crush";
   #rev = "master";
    rev = "391806447134f5899c766b95c19cbbf7b597f3b9";
    sha256 = "05rqn7bzd6r5ymf8jnw6k9mii6xr0zs3s5zmzc8mxj1s1i5lgbl9";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-ElSTtDDvBKDY6CbPuXBJCPqowpjlShfMe+1TE9BDmBY=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/crush";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "crush";
  };
}
