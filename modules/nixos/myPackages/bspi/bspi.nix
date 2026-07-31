{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  fontconfig,
  freetype,
  pkg-config,
  libx11,
  libxft,
  libxext,
  libxrender,
  json_c,
  libxcb,
}:

stdenv.mkDerivation rec {
  pname = "bspi";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ dbus fontconfig freetype libx11 libxft libxext libxrender json_c libxcb ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bspi $out/bin/bspi

    runHook postInstall
  '';

  meta = with lib; {
    homepage = " ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bspi";
  };
}
