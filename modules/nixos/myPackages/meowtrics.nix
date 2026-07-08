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

  kdePackages,

  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "meowtrics";
  version = "2026-05-08";

  src = fetchFromGitHub {
    owner = "ra-yavuz";
    repo = "meowtrics";
    rev = "2d7e05a0d321dee64c9ddd2d1c13ec8cb1ef360b";
    sha256 = "0ik25i79fx9n7b9msqb1lh96ix82yd8g7nzznqhk3776l44qihpv";
  };

  nativeBuildInputs = [
    pkg-config
    kdePackages.wrapQtAppsHook
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

    kdePackages.qtbase
  ];

  postInstall = ''
    mkdir -p $out/share/meowtrics
    cp data/messages.json $out/share/meowtrics/messages.json
    cp systemd/meowtrics.service $out/share/meowtrics/meowtrics.service
  '';

  cargoHash = "sha256-g44u3JWtanrR1KUZIxgZ9/7FvkYVIcyflNCrFBUbOE4=";

  meta = with lib; {
    homepage = "https://github.com/ra-yavuz/meowtrics";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "meowtrics";
  };
}
