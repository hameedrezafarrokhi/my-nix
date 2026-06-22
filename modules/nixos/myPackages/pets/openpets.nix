{
  lib,
  appimageTools,
  fetchurl,
  version ? "3.2.1",
  hash ? "sha256-RwNdSPrwQSYUIJpYo9jN2+mh+3RUTmlSiOgxZMGoT98=",
  arch ? "x86_64",

  extraPkgs ? pkgs: [  ],
}:

let
  pname = "openpets";

  src = fetchurl {
    url = "https://github.com/alvinunreal/${pname}/releases/download/v${version}/OpenPets-${version}-linux-${arch}.AppImage";
    inherit hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  inherit pname version src extraPkgs;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/openpets.desktop $out/share/applications/openpets.desktop

    install -m 444 -D ${appimageContents}/openpets.png $out/share/icons/hicolor/512x512/apps/openpets.png

    substituteInPlace $out/share/applications/openpets.desktop \
      --replace-fail 'Exec=AppRun %U' 'Exec=openpets'
  '';

 #passthru.updateScript = ./update.sh;

  meta = {
    homepage = "https://github.com/alvinunreal/openpets";
    platforms = [ "x86_64-linux" ];
  };
}
