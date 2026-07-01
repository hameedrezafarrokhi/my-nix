{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "barbara";
  version = "2018-10-16";

  src = fetchFromGitHub {
    owner = "seeruk";
    repo = "barbara";
   #rev = "master";
    rev = "ad944e53f0b430e124bbcf8963ab3e039788c82a";
    sha256 = "1vvnd6jls1liq2fmqh0hblw59y606vlfcby82yrl83na16ia16ym";
  };

  vendorHash = null;

  nativeBuildInputs = [ pkg-config go ];

  meta = {
    homepage = "https://github.com/seeruk/barbara";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
