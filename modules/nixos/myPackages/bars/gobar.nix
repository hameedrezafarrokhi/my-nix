{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "gobar";
  version = "2023-01-27";

  src = fetchFromGitHub {
    owner = "distatus";
    repo = "gobar";
   #rev = "master";
    rev = "51e2082fb2663f875f0a1cd087767e47aea38329";
    sha256 = "0j2jq0dgpm8a0dwbjmx6xzn0apka6zk1vs5cscv2wkrszcw4g5z7";
  };

  vendorHash = "sha256-sWbPuTvYCn57P4u81yXykGElHTsP8IG0ih2+P9Zz2Xo=";

  nativeBuildInputs = [ pkg-config go ];

  meta = {
    homepage = "https://github.com/distatus/gobar";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
