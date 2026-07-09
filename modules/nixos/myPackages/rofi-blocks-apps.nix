{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {

  pname = "rofi-blocks-apps";
  version = "2023-02-10";
  src = fetchFromGitHub {
    owner = "erik-overdahl";
    repo = "rofi-blocks-apps";
    rev = "35a3555dbf44a3481c5493d910be53a4a3bafb33";
    sha256 = "1m07k4d72mcph89v4p65x4pc5wyz9gp3hgbz2pa7xv5pamknlhza";
  };

  vendorHash = null;

 #postPatch = ''
 #  #substituteInPlace main.go \
 #  #  --replace 'examples.MakeFocusLinesApp(),' ' '
 #  substituteInPlace main.go \
 #    --replace 'examples.MakeShowLinesApp(),' ' '
 #  #substituteInPlace main.go \
 #  #  --replace 'examples.MakeActionLoggerApp(),' 'examples.MakeVolumeChangerApp(),'
 #'';

  meta = with lib; {
    homepage = "https://github.com/erik-overdahl/rofi-blocks-apps";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-blocks-apps";
  };
}
