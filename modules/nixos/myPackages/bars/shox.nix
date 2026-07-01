{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "shox";
  version = "2024-01-25";

  src = fetchFromGitHub {
    owner = "liamg";
    repo = "shox";
   #rev = "master";
    rev = "6a0506aebcafcd598fbcd824be9c5f0608836ab1";
    sha256 = "01qaakan72ccqycy9r7syyb5xavm6q82fp4n13kza3xsvgvl0m89";
  };

  vendorHash = null;

  nativeBuildInputs = [ pkg-config go ];

  buildPhase = ''
    runHook preBuild

    GOOS=linux GOARCH=amd64 go build -mod=vendor -o shox ./cmd/shox/

    runHook postBuild
  '';

  meta = {
    homepage = "https://github.com/liamg/shox";
    description = "go-powerd";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
