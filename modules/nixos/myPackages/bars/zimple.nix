{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "zimple";
  version = "2024-07-13";

  src = fetchFromGitHub {
    owner = "ALX99";
    repo = "zimple";
   #rev = "main";
    rev = "f0d73ec38f917802988fb1f3484a65b2818533fe";
    sha256 = "1pk1ayclrz3si2ik4pqkdsgjia8rjy7l1gvz9pf8dzs4crq9cmvm";
  };

  vendorHash = "sha256-g+yaVIx4jxpAQ/+WrGKxhVeliYx7nLQe/zsGpxV4Fn4=";

  nativeBuildInputs = [ pkg-config go ];

  meta = {
    homepage = "https://github.com/ALX99/zimple";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
