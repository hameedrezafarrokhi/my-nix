{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
 #installFonts,
  kdePackages,
  qt5,
  gst_all_1,
  quickshell,
  formats,
  nix-update-script,
  themeConfig ? null,
  embeddedTheme ? "paper",
}:
let
  configFile = (formats.ini { }).generate "" { General = themeConfig; };
  basePath = "$out/share/qylock-gitlab";
  sddmPath = "$out/share/sddm/themes/qylock-gitlab";
  lockScreenPath = "${basePath}/quickshell-lockscreen";
in
stdenvNoCC.mkDerivation rec {
  pname = "qylock-gitlab";
  version = "0-unstable-2026-03-29";

  src = fetchFromGitLab {
    owner = "NorinB";
    repo = "qylock";
    rev = "7aa92a6b68bd18561d043576ecd1391b6c7f2544";
    sha256 = "1sa69bn6dff95wdxnpx74bz8fapm16wfx7lj9f17kjzf8azhjis9";
  };

  dontWrapQtApps = true;
  dontBuild = true;

 #nativeBuildInputs = [ installFonts ];

  propagatedBuildInputs =
  (with kdePackages; [
    # avoid .dev outputs propagation
    qtsvg.out
    qtmultimedia.out
    qtvirtualkeyboard.out
    qtdeclarative.out
    qt5compat.out
  ]) ++
  (with qt5; [
    qtgraphicaleffects.out
    qtquickcontrols2.out
    qtsvg.out
    qtmultimedia.out
  ]) ++
  (with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ]) ++
  [
    quickshell
  ]
  ;

  installPhase = ''
    runHook preInstall

    mkdir -p ${basePath}/themes ${lockScreenPath}/imports ${lockScreenPath}/shim

    cp -r $src/themes/* ${basePath}/themes
    cp -r $src/quickshell-lockscreen/imports/* ${lockScreenPath}/imports
    cp -r $src/quickshell-lockscreen/shim/* ${lockScreenPath}/shim
    cp $src/quickshell-lockscreen/lock_shell.qml ${lockScreenPath}/lock_shell.qml

    #chmod u+w ${basePath}/themes/
    #chmod u+w ${basePath}/
    chmod -R u+rw ${basePath}/

    #rm -f ${lockScreenPath}/imports/QtMultimedia/Video.qml

    ln -sf "${basePath}/themes" "${lockScreenPath}/themes_link"
  ''

  + lib.optionalString (themeConfig != null) ''
    ln -sf ${configFile} ${basePath}/themes/${embeddedTheme}/theme.conf.user
  ''

  + ''
    # SDDM
    mkdir -p ${sddmPath}
    ln -sf ${basePath}/* ${sddmPath}
  ''

  + ''
    # lockscreen launcher

    mkdir $out/bin

    cat > $out/bin/${pname} << 'EOF'
    #!/usr/bin/env bash

    # Get current directory
    DIR="/run/current-system/sw/share/qylock-gitlab/quickshell-lockscreen"

    # Export paths for Quickshell
    export QML2_IMPORT_PATH="$DIR/imports:$QML2_IMPORT_PATH"
    export QML_XHR_ALLOW_FILE_READ=1

    # Change theme
    if [[ -n "$1" ]]; then
      export QS_THEME="$1"
    else
      export QS_THEME="${embeddedTheme}"
    fi

    echo "Locking with Quickshell using theme: $QS_THEME"

    # Safety: Kill any other lockers that might be running (like hyprlock from hypridle)
    # Only one app can hold the Wayland session lock at a time.
    killall -9 hyprlock swaylock wlogout 2>/dev/null || true

    # Run the shell with a unique filename to avoid IPC interference with existing bars
    quickshell -p "$DIR/lock_shell.qml"


    EOF

    chmod +x $out/bin/${pname}
  ''

  + ''
    runHook postInstall
  '';

  meta = {
    description = "quickshell sddm theme and lock screens";
    homepage = "https://gitlab.com/NorinB/qylock ";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
