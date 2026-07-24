{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  wget,
}:

stdenv.mkDerivation rec {
  pname = "kitty-doom";
  version = "2025-12-09";

  src = fetchFromGitHub {
    owner = "jserv";
    repo = "kitty-doom";
    rev = "e264ed6039da22a48a22fbdf7ec2f6c760f9b523";
    sha256 = "12bmql0d6f26s3gzizfl9a70jh48vkipw04licrbbd47mhp7i7m1";
  };

  nativeBuildInputs = [ pkg-config wget ];

  buildInputs = [ fontconfig freetype ];

  buildPhase = ''
    runHook preBuild

    make download-assets

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./build/kitty-doom $out/bin/kitty-doom

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/jserv/kitty-doom";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "kitty-doom";
  };
}
