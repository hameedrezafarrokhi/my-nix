{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  pkg-config,
  buildGoModule,
  cairo,
  pulseaudio,
}:

buildGoModule rec {
  pname = "bar3x";
  version = "2021-04-25";

  src = fetchFromGitHub {
    owner = "ShimmerGlass";
    repo = "bar3x";
   #rev = "master";
    rev = "11e0b0449807a3dc7b131044705f3a0b4d633235";
    sha256 = "001w3f0nbc9rx2ihj4x3cy0363pab36lry3n6b2gwj48jbsr7k9y";
  };

  vendorHash = "sha256-XMD6w2yu+whMuoY7bLScvhOITTb4y/9dUkxU8ed3vjU=";

  nativeBuildInputs = [ pkg-config go ];

  buildInputs = [ cairo pulseaudio ];

  meta = {
    homepage = "https://github.com/ShimmerGlass/bar3x";
    description = "go-powerd";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
