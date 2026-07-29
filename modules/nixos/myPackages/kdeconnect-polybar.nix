{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  fontconfig,
  freetype,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "kdeconnect-polybar";
  version = "unstable";

  src = ./.;

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def";


  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ dbus fontconfig freetype ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp polybar-kdeconnect $out/bin/kdeconnect-polybar

    runHook postInstall
  '';

  meta = with lib; {
    homepage = " ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "kdeconnect-polybar";
  };
}
