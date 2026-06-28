{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,

  pnpm_10_29_2,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,

}:

stdenv.mkDerivation rec {
  pname = "bond-wm";
  version = "2026-03-29";

  src = fetchFromGitHub {
    owner = "wnayes";
    repo = "bond-wm";
   #rev = "main";
    rev = "1622b44591665246f9a88d1aa655d9ff761b1401";
    sha256 = "1808rlc5lda2rxc9qy9cpdc5aws2qnn8wq0k2bqz2zbdwr4q3zck";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm_10_29_2;
    fetcherVersion = 3;
    hash = "sha256-scGL6o714i9D3xM2fYyptfx4Fupwn8U9F5cY6lk7Ixg=";
  };

  nativeBuildInputs = [
    pkg-config
    nodejs
    pnpm_10_29_2
    pnpmConfigHook
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype
  ];

  buildPhase = ''
    runHook preBuild

    pnpm install
    pnpm build

    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://github.com/wnayes/bond-wm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bond-wm";
  };
}
