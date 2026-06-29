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

  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "srwm";
  version = "2026-06-29";

  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "unpatched-bins";
    rev = "623f2df0c13940db73e9b52cdc681a4cea9d6578";
    sha256 = "1y415x7kj9ghqpdf6m28dkiza13a55mks461l6y8k59nasvkwizj";
  };

  nativeBuildInputs = [
    pkg-config
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



  buildPhase = ''
    mkdir -p $out/bin
    cp ${src}/srwm/* $out/bin/srwm
    chmod +x $out/bin/srwm
  '';

  installPhase = ''
    runHook preInstall

    wrapProgram $out/bin/srwm \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    runHook postInstall
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/srwm || true
  '';

  meta = with lib; {
    homepage = "https://github.com/infraflakes/srwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "srwm";
  };
}
