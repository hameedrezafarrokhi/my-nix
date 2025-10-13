{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "ax-shell-2";
  version = "unstable-2025-08-26";

  src = fetchFromGitHub {
    owner = "Axenide";
    repo = "Ax-Shell";
    rev = "01558f42869ed124cd00e72a3ec6736c6062d8b3";
    hash = "sha256-mCrQ6KdA4Yt8AYsQvjWwn8WUhzN1TOxfz00EelAtvJs=";
  };

  meta = {
    description = "A hackable shell for Hyprland, powered by Fabric";
    homepage = "https://github.com/Axenide/Ax-Shell";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ax-shell";
    platforms = lib.platforms.all;
  };
}
