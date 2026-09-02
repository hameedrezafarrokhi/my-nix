{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
 #installFonts,
  kdePackages,
  qt5,
  gst_all_1,
  quickshell,
  formats,
  makeWrapper,
  nix-update-script,
  themeConfig ? null,
  embeddedTheme ? "last-of-us",
  systemd,
  psmisc,
  coreutils,
}:
let
  configFile = (formats.ini { }).generate "" { General = themeConfig; };
  basePath = "$out/share/qylock";
  sddmPath = "$out/share/sddm/themes/qylock";
  lockScreenPath = "${basePath}/quickshell-lockscreen";
in
stdenvNoCC.mkDerivation rec {
  pname = "qylock";
  version = "0-unstable-2026-06-05";

  src = fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    rev = "db61a972b4b23728d9944a906e70029ca8a5899d";
    sha256 = "0d0bpzqpykzs4lz1h43z86fabm9v2q575a96v1a4j0sx525l2lwd";
  };

  dontWrapQtApps = true;
  dontBuild = true;

  nativeBuildInputs = [
    #installFonts
    makeWrapper
    systemd
    psmisc
    coreutils
  ];

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

    qmlPath="${kdePackages.qt5compat}/lib/qt-6/qml:${kdePackages.qtdeclarative}/lib/qt-6/qml:${kdePackages.qtmultimedia}/lib/qt-6/qml:${kdePackages.qtsvg}/lib/qt-6/qml"

    cat > $out/bin/${pname} << 'EOF'
    #!/usr/bin/env bash

    # Get current directory
    DIR="/run/current-system/sw/share/qylock/quickshell-lockscreen"

    # Export paths for Quickshell
    export XDG_SESSION_TYPE="$(loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type --value 2>/dev/null || echo wayland)"

    export QML2_IMPORT_PATH="$DIR/imports:$QML2_IMPORT_PATH"
    export QML_XHR_ALLOW_FILE_READ=1

    CONFIG_FILE="$HOME/.config/qylock/theme"

    # Change theme
    if [[ -n "$1" ]]; then
      export QS_THEME="$1"
    elif [ -f "$CONFIG_FILE" ]; then
      export QS_THEME=$(cat "$CONFIG_FILE")
    else
      export QS_THEME="${embeddedTheme}"
    fi

    export QS_THEME_PATH="$DIR/themes_link/$QS_THEME"

    echo "Locking with Quickshell using theme: $QS_THEME"

    # Safety: Kill any other lockers that might be running (like hyprlock from hypridle)
    # Only one app can hold the Wayland session lock at a time.
    killall -9 hyprlock swaylock wlogout 2>/dev/null || true

    # Run the shell with a unique filename to avoid IPC interference with existing bars

    if pgrep bspwm > /dev/null; then

      quickshell -p "$DIR/lock_shell.qml" &

      #while ! pgrep quickshell > /dev/null; do
      #  sleep 0.1
      #done
      #sleep 0.5
      #bspc node -t fullscreen
      #bspc node -g sticky=on

      win_count=$(bspc query -N -d | wc -l)
      while [ "$win_count" = "$(bspc query -N -d | wc -l)" ]; do
        sleep 0.05
      done
      #sleep 0.1
      bspc node -g follow=on focus=on manage=on layer=above
      bspc node -t fullscreen
      bspc node -g sticky=on
      bspc node -g manage=off
    else
      quickshell -p "$DIR/lock_shell.qml"
    fi

    EOF

    chmod +x $out/bin/${pname}

    makeWrapper $out/bin/${pname} $out/bin/qylock-lock \
      --set-default QS_THEME "${embeddedTheme}" \
      --set QYLOCK_THEMES_ROOT "$out/share/qylock/themes" \
      --suffix QML2_IMPORT_PATH : "$qmlPath" \
      --suffix QML_IMPORT_PATH : "$qmlPath" \
      --prefix PATH : ${lib.makeBinPath [
        quickshell
        psmisc
        systemd
        coreutils
      ]}


  ''

  + ''
    runHook postInstall
  '';

  meta = {
    description = "quickshell sddm theme and lock screens";
    homepage = "https://github.com/Darkkal44/qylock";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
