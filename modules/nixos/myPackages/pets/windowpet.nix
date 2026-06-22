{
  lib,
  appimageTools,
  fetchurl,
  version ? "0.0.9",
  hash ? "sha256-WZlD3iW7O1dZkZmPXxQ0QMWlTSAadk9psPJjcaOUuYY=",
  arch ? "x86_64",

  extraPkgs ? pkgs: [  ],
}:

let
  pname = "windowpet";

  src = fetchurl {
    url = "https://github.com/SeakMengs/WindowPet/releases/download/v${version}/window-pet_${version}_amd64.AppImage";
    inherit hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  inherit pname version src extraPkgs;

 #extraInstallCommands = ''
 #  install -m 444 -D ${appimageContents}/windowpet.desktop $out/share/applications/windowpet.desktop
 #
 #  install -m 444 -D ${appimageContents}/windowpet.png $out/share/icons/hicolor/512x512/apps/windowpet.png
 #
 #  substituteInPlace $out/share/applications/windowpet.desktop \
 #    --replace-fail 'Exec=AppRun %U' 'Exec=windowpet'
 #'';

 #passthru.updateScript = ./update.sh;

  meta = {
    homepage = "https://github.com/SeakMengs/WindowPet";
    platforms = [ "x86_64-linux" ];
  };
}
