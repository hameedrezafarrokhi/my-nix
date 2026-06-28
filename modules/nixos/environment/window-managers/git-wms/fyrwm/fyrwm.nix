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

  buildNpmPackage,
  nodejs,
  electron,

}:

buildNpmPackage rec {
  pname = "fyrWM";
  version = "2025-07-23";

  src = fetchFromGitHub {
    owner = "danielmeloalencar";
    repo = "fyrWM";
   #rev = "dev";
    rev = "bebb5af96508fe848dd334fa5687475a380ea127";
    sha256 = "0ldjs89m3q2g7jx283a9gcj65x02n20qz720mk67fhs80gw2q2r3";
  };

  npmDepsHash = "sha256-nzcNa80KWYH/532r8taBgvCyUKM0CI5fue27wt0wExo=";

  nativeBuildInputs = [
    pkg-config
    nodejs
    electron
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
    electron
  ];

  buildPhase = ''
    runHook preBuild

    npm install -g @vue/cli corepack electron npm@9.8.1 prettier typescript webpack

    npm install
    npm run build

    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://github.com/danielmeloalencar/fyrWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fyrWM";
  };
}
