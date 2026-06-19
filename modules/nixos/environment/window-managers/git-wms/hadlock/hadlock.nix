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

  rustPlatform,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage rec {
  pname = "hadlock";
  version = "2020-10-04";

  src = fetchFromGitHub {
    owner = "AdaShoelace";
    repo = "hadlock";
   #rev = "master";
    rev = "154fd77e747aaf9a799c7d366b36235af22757d6";
    sha256 = "0n7qp5gm0nv85fz8mmsrbw78cqkk28hahyn7yjakgl3ndvrz5z2n";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
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
    dbus
  ];

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  meta = with lib; {
    homepage = "https://github.com/AdaShoelace/hadlock";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "hadlock";
  };
}
