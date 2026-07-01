{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "dwmStatus";
  version = "2019-01-12";

  src = fetchFromGitHub {
    owner = "KimHe";
    repo = "dwmStatus";
   #rev = "master";
    rev = "f77920bbcb76813aa6366770eea8de5d21bf3bec";
    sha256 = "111ml7030wv56mqfgx443xzq0ff83fmqb68nzf403cc4ih2971f5";
  };

  vendorHash = null;

  nativeBuildInputs = [ pkg-config go ];

  buildPhase = ''
    runHook preBuild

    go build dwmStatus.go

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp dwmStatus $out/bin/dwmStatus
    chmod +x $out/bin/dwmStatus

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/KimHe/dwmStatus";
    description = "go-powerd";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
