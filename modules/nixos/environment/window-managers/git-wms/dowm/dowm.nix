{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  pkg-config,
  go,
  buildGoModule,
}:

buildGoModule rec {
  pname = "doWM";
  version = "2026-05-18";

  src = fetchFromGitHub {
    owner = "BobdaProgrammer";
    repo = "doWM";
   #rev = "main";
    rev = "17936205ba2cefc478d8dcfd81de52bee7614e9e";
    sha256 = "1k601yvzdnqc1w7qdys7gawgzdfm2hpm9i3j3rm4anv6a486mcb7";
  };

  vendorHash = "sha256-ndafgwhEzv3F15IinT75/zx8L15DFXuonB9Rx/HBE4M=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libX11 ];

  makeFlags = [ "PREFIX=$(out)" ];

  buildPhase = ''
    go build -o ./doWM
  '';

  installPhase = ''
    #make install config
    mkdir -p $out/bin
    mkdir -p $out/share/doWM
    install -Dm755 doWM $out/bin/doWM
    cp -r exampleConfig/* $out/share/doWM/
  '';

  meta = with lib; {
    homepage = "https://github.com/BobdaProgrammer/doWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "doWM";
  };
}
