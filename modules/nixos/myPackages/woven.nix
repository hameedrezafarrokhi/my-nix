{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libxkbcommon,
  wayland,
  libX11,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "woven";
  version = "v2.5.3";

  src = fetchFromGitHub {
    owner = "viewerofall";
    repo = "woven";
   #rev = "mian";
    tag = version;
    hash = "sha256-fnzrhipbnEkInfUdsFZ6rAUGMRBVQ9RGeIHgPOBuXko=";
  };

 #cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  cargoLock = {
    lockFile = ./Woven-Cargo.lock;
  };

 #cargoPatches = [ ./Woven-Cargo.lock ];

 #prePatch = ''
 #  cp ${cargoLock.lockFile} src/Cargo.lock
 #'';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libX11
    wayland
    libxkbcommon
  ];

  propagatedBuildInputs = buildInputs;

  dependencies = buildInputs;

  installPhase = ''
    install -Dm755 exec/woven $out/bin/woven-unwrapped
    install -Dm755 exec/woven-ctrl $out/bin/woven-ctrl

    install -Dm644 woven-ctrl.desktop $out/share/applications/woven-ctrl.desktop

    install -Dm644 woven.lua $out/etc/woven/woven.lua

    install -Dm644 woven_icon.png $out/share/icons/hicolor/256x256/apps/woven.png

    #install -Dm755 $out/share/woven/runtime
    mkdir -p $out/share/woven/runtime
    cp -r plugins/. $out/share/woven/runtime/

    #makeWrapper $out/bin/woven-unwrapped $out/bin/woven \
    #  --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
    #  --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

  '';

  meta = {
    homepage = "https://github.com/viewerofall/woven";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
