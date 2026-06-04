{
  lib,
  stdenv,
  fetchurl,
  libxkbcommon,
  wayland,
  libX11,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "woven";
  version = "v2.5.3";

  src = fetchurl {
    url = "https://github.com/viewerofall/woven/releases/download/${version}/${version}.tar.gz";
    hash = "sha256:733392fe7ee7405f9ccf30c0dacbdb55b184891ca1e55e0ad2cd6d98c469c710";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    libX11
    wayland
    libxkbcommon
  ];

  propagatedBuildInputs = buildInputs;

  dependencies = buildInputs;

  dontBuild = true;
  dontCheck = true;

  installPhase = ''
    install -Dm755 exec/woven $out/bin/woven-unwrapped
    install -Dm755 exec/woven-ctrl $out/bin/woven-ctrl

    install -Dm644 woven-ctrl.desktop $out/share/applications/woven-ctrl.desktop

    install -Dm644 woven.lua $out/etc/woven/woven.lua

    install -Dm644 woven_icon.png $out/share/icons/hicolor/256x256/apps/woven.png

    #install -Dm755 $out/share/woven/runtime
    mkdir -p $out/share/woven/runtime
    cp -r plugins/. $out/share/woven/runtime/

    makeWrapper $out/bin/woven-unwrapped $out/bin/woven \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

  '';

  meta = {
    homepage = "https://github.com/viewerofall/woven";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
