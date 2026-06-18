{
  lib,
  stdenv,
  gcc,
  libX11,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "sewm";
  version = "2026-03-01";

  src = fetchFromGitHub {
    owner = "Satomatic";
    repo = "SEWM";
    rev = "master";
    hash = "sha256-QaXMFJH0c26tseF1lgu8k78MocKNfgm/n9Rod9IuzWI=";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [ libX11 ];

 #makeFlags = [ "PREFIX=$(out)" ];

 #buildPhase = ''
 #  runHook preBuild
 #  g++ -std=c++11 -I${libX11.dev}/include src/*.cpp src/**/*.cpp -Isrc/include -L${libX11.out}/lib -lX11 -o sewm -O2
 #  runHook postBuild
 #'';

  installPhase = ''
    runHook preInstall
    install -Dm755 sewm $out/bin/sewm
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Satomatic/SEWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sewm";
  };

}
