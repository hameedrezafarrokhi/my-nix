{
  lib,
  stdenv,
  fetchFromGitHub,
  installFonts,
  fontconfig,
  freetype,
}:

stdenv.mkDerivation rec {
  pname = "bar-skull-cat-fonts";
  version = "2026-01-18";

  src = fetchFromGitHub {
    owner = "CarloCattano";
    repo = "waycat";
    rev = "423a59c29accc0f73cf0f35cf2f823081fa26184";
    sha256 = "1bjx19k1cydl7kis56svzdx8pha34f8c90wqmdbsbmgs4ygsh4ys";
  };

  nativeBuildInputs = [ installFonts ];

  buildInputs = [  ];

  buildPhase = ''
    runHook preBuild

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/CarloCattano/waycat";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bar-skull-cat";
  };
}
