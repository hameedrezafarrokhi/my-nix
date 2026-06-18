{
  stdenv,
  lib,
  libX11,
  libXext,
  libXinerama,
  libXft,
  libXrandr,
  xorgproto,
  fetchFromGitHub,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libsxwm";
  version = "2020-01-01";

  src = fetchFromGitHub {
    owner = "jasonmxyz";
    repo = "sxwm";
    rev = "master";
    hash = "sha256-BMh6WC8e1NdCFMrkV+B23RqrOo3Eea4HkyKYjN8I1RI=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libX11
    libXrandr
    xorgproto
    libXext
    libXinerama
    libXft
  ];

  buildPhase = ''
    runHook preBuild
    make libsxwm/libsxwm.so
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    install -Dm755 libsxwm/libsxwm.so $out/lib/libsxwm.so
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/jasonmxyz/sxwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "libsxwm";
  };
}
