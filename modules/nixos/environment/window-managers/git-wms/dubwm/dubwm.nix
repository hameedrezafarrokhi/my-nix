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

  dub,
  dmd,
  buildDubPackage,

}:

buildDubPackage rec {
  pname = "dubwm";
  version = "2025-06-06";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "pastbear";
    repo = "dxwm";
    rev = "5834f86476ceea10b94635d18136fa8d7dfc5237";
    hash = "sha256-0FAoHH9Tdr0fDIV7SE9ZYlHNVW9TZg1vbYs10DJerMA=";
  };

  nativeBuildInputs = [
    pkg-config
    dub
    dmd
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

 #dubHash = lib.fakeHash;
 #dubLock = "${src}/dub.selections.json";
  dubLock = {
    dependencies = {
      arsd-official = {
        version = "11.5.3";
        sha256 = "08v1dvdam31ixdwvv9n5byhw21mkbaclglaiwp4hjs5892klrsx4";
      };
      libx11 = {
        version = "0.0.2";
        sha256 = "0mcf5w5gzifwwwyy784mjxa7mh3da29qdf4yaiycg9738v6picsy";
      };
      x11 = {
        version = "1.0.21";
        sha256 = "1hz2zdn2nnyb686wlmz6m8hnxg2wf6ns2xcc9i3iwi2qcsfpywmh";
      };
      x11d = {
        version = "1.0.24";
        sha256 = "1yn09jaqm74yv71rflwcs6bbp76bsrklg1pzhmzwck3wzydfm7fg";
      };
    };
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp dxwm $out/bin/dubwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/pastbear/dxwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "dubwm";
  };
}
