{
  lib,
  stdenv,
  fetchFromGitea,

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
  meson,
  ninja,

}:

stdenv.mkDerivation rec {
  pname = "xfidget-spinner";
  version = "2025-06-28";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "babalark";
    repo = "xfidget-spinner";
    rev = "268f0cfb80bf8ba46e640125705ae241cae599a7";
    sha256 = "17wv3vckhvkyrx12b21nbqzj3m3y7j30lsg2b80xna1cshifd19g";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
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

  installPhase = ''
    runHook preInstall

    pwd
    ls

    mkdir -p $out/bin
    cp xfidget-spinner $out/bin/xfidget-spinner

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/babalark/xfidget-spinner";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xfidget-spinner";
  };
}
