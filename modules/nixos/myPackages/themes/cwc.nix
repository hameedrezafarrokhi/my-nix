{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  quickshell,
  makeWrapper,
  writeText,
  themeConfig ? null,
  dock1Config ? null,
  dock2Config ? null,
}:

let

 #configFile  = (formats.ini { }).generate "" { General = themeConfig; };
  basePath    = "$out/share/cwc";
  configFile  = if lib.isDerivation themeConfig || builtins.isPath themeConfig then themeConfig else writeText "appearance.json" themeConfig;
  configDock1 = if lib.isDerivation dock1Config || builtins.isPath dock1Config then dock1Config else writeText "default.json" dock1Config;
  configDock2 = if lib.isDerivation dock2Config || builtins.isPath dock2Config then dock2Config else writeText "power-menu.json" dock2Config;

in

stdenvNoCC.mkDerivation rec {

  pname = "cwc";
  version = "0-unstable-2025-06-12";

  src = fetchFromGitHub {
    owner = "crawraps";
    repo = "widgets-collection";
    rev = "815eb36765c1f01eff53c12fba150b550436a8b4";
    sha256 = "1gbbn2vr6f4bc4k9dg4r0wkmlbyswiijx2g9cfs5zc40fcv8gah2";
  };

  dontWrapQtApps = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ quickshell ];

  installPhase = ''
    runHook preInstall

    mkdir -p ${basePath}
    cp -r $src/* ${basePath}/
    chmod -R u+rw ${basePath}/

    cp -f ${configFile}  ${basePath}/appearance.json
    cp -f ${configDock1} ${basePath}/widgets/dock/configs/default.json
    cp -f ${configDock2} ${basePath}/widgets/dock/configs/power-menu.json

    # launcher
    mkdir $out/bin
    cat > $out/bin/${pname} << 'EOF'
    #!/usr/bin/env bash
    DIR="/run/current-system/sw/share/cwc"
    quickshell -p "$DIR/shell.qml"
    EOF

    chmod +x $out/bin/${pname}

    runHook postInstall
  '';

  meta = {
    description = "quickshell sddm theme and lock screens";
    homepage = "https://github.com/crawraps/widgets-collection";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
