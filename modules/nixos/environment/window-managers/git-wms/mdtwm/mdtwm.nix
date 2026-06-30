{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  pkg-config,
  go,
  buildGoModule,
  writeText,
  conf ? null,
}:

buildGoModule rec {
  pname = "mdtwm";
  version = "2026-03-22";

 #src = fetchFromGitHub {
 #  owner = "ziutek";
 #  repo = "mdtwm";
 # #rev = "master";
 #  rev = "84a50a0ea00b81080263e35ae2500470ed6925ce";
 #  sha256 = "117lgrl99jaabsl8dwmcqsnq3j1mi9dyyg0wl389d42vnnca8zwb";
 #};

  src = ./mdtwm;

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.go" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.go"
    ;


  vendorHash = lib.fakeHash;

  nativeBuildInputs = [ pkg-config go ];

  buildInputs = [ libX11 ];

 #buildPhase = ''
 #  #go get code.google.com/p/x-go-binding/xgb
 #  go get github.com/ziutek/mdtwm
 #  go build
 #'';

 #installPhase = ''
 #  mkdir -p $out/bin
 #  cp mdtwm $out/bin/mdtwm
 #'';

  meta = with lib; {
    homepage = "https://github.com/ziutek/mdtwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mdtwm";
  };
}
