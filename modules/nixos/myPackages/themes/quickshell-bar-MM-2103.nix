{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  quickshell,
  makeWrapper,
  writeText,
  themeConfig ? null,
  sliderConfig ? null,
}:

let

 #configFile = (formats.ini { }).generate "" { General = themeConfig; };
  basePath   = "$out/share/quickshell-bar-MM-2103";
  themeFile  = if lib.isDerivation themeConfig  || builtins.isPath themeConfig  then themeConfig  else writeText "Theme.qml"  themeConfig;
  sliderFile = if lib.isDerivation sliderConfig || builtins.isPath sliderConfig then sliderConfig else writeText "Slider.qml" sliderConfig;

in

stdenvNoCC.mkDerivation rec {

  pname = "quickshell-bar-MM-2103";
  version = "0-unstable-2026-06-07";

  src = fetchFromGitHub {
    owner = "MM-2103";
    repo = "quickshell-bar";
    rev = "f1ee12574d13a1edb4ccc5ee4dba3dfc62b86d85";
    sha256 = "1bghmdnq1kx6z64cv4k8yfqsdvm42wlx7p0rgybxgq93dikcipv2";
  };

  dontWrapQtApps = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ quickshell ];

  installPhase = ''
    runHook preInstall

    mkdir -p ${basePath}
    cp -r $src/*  ${basePath}/
    chmod -R u+rw ${basePath}/

    ''
    + lib.optionalString (themeConfig != null) ''
      cp -f ${themeFile}  ${basePath}/Theme.qml
    ''
    + lib.optionalString (sliderConfig != null) ''
      cp -f ${sliderFile} ${basePath}/Slider.qml
    ''
    + ''

    # launcher
    mkdir $out/bin
    cat > $out/bin/${pname} << 'EOF'
    #!/usr/bin/env bash
    DIR="/run/current-system/sw/share/${pname}"
    quickshell -p "$DIR/shell.qml"
    EOF

    chmod +x $out/bin/${pname}

    runHook postInstall
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/MM-2103/quickshell-bar";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
