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

  makeWrapper,
}:

rustPlatform.buildRustPackage rec {
  pname = "critwm";
  version = "2023-07-15";

  src = fetchFromGitHub {
    owner = "claby2";
    repo = "critwm";
   #rev = "master";
    rev = "080b642ceb086e6ec570c2da12c6001978adb5f3";
    sha256 = "0aq5kwyxm4bcvhx6babm2alxbq7plmzhqhaafx7igqmpc5zhwcf8";
  };

  nativeBuildInputs = [
    makeWrapper
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

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  postInstall = ''
    wrapProgram $out/bin/critwm \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = with lib; {
    homepage = "https://github.com/claby2/critwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "critwm";
  };
}
