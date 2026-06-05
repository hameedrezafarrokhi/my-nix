{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  bash,
  installShellFiles,
  pkg-config,
  git,
  buildGoModule,
}:

buildGoModule rec {
  pname = "go-powerd";
  version = "v0.4.0";

  src = fetchFromGitHub {
    owner = "VicDeo";
    repo = "go-powerd";
    tag = version;
    hash = "sha256-OeAmrYixWYnGpJbg9H8Erg3q/aLX6mZQdwiCxMJtDn8=";
  };

   vendorHash = "sha256-pMmxn+CzjKE8SHLbk5B0sXtxPVyBcVVl3moYkiH8JEg=";

   nativeBuildInputs = [ pkg-config bash git installShellFiles ];

   makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    homepage = "https://github.com/VicDeo/go-powerd";
    description = "go-powerd";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
