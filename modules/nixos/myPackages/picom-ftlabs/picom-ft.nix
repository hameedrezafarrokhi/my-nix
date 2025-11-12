{
  picom,
  writeShellScript,
  unstableGitUpdater,

  llvmPackages_18,

  asciidoctor,
  dbus,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchFromGitHub,
  lib,
  libconfig,
  libdrm,
  libev,
  libGL,
  libepoxy,
  libX11,
  libxcb,
  libxdg_basedir,
  libXext,
  libxml2,
  libxslt,
  makeWrapper,
  meson,
  ninja,
  pcre2,
  pixman,
  pkg-config,
  stdenv,
  uthash,
  xcbutil,
  xcbutilimage,
  xcbutilrenderutil,
  xorgproto,
  xwininfo,
  withDebug ? false,
  versionCheckHook,
  nix-update-script,
}:

picom.overrideAttrs (previousAttrs: {
  pname = "picom-ft";
  version = "v12.5";

  src = fetchFromGitHub {
    owner = "r0-zero";
    repo = "picom";
    rev = "XX834631b85da58d1f9cb258a0eXXXeedda581XX";
    hash = "sha256-XXQdFAmoROZpiqDgrbn3XXXzAmsPibEB4Wy/cTtjMHXX";
  };

  dontVersionCheck = true;

  nativeBuildInputs = [
    asciidoctor
    docbook_xml_dtd_45
    docbook_xsl
    makeWrapper
    meson
    ninja
    pkg-config

    pcre2
    xcbutil
    libepoxy
  ];

  buildInputs = [
    dbus
    libconfig
    libdrm
    libev
    libGL
    libepoxy
    libX11
    libxcb
    libxdg_basedir
    libXext
    libxml2
    libxslt
    pcre2
    pixman
    uthash
    xcbutil
    xcbutilimage
    xcbutilrenderutil
    xorgproto

    llvmPackages_18.clang-tools
    llvmPackages_18.clang-unwrapped.python
  ];

  hardeningDisable = ["fortify"];

  shellHook = ''
    # Workaround a NixOS limitation on sanitizers:
    # See: https://github.com/NixOS/nixpkgs/issues/287763
    export LD_LIBRARY_PATH+=":/run/opengl-driver/lib"
  '';

  mesonBuildType = if withDebug then "debugoptimized" else "release";
  dontStrip = withDebug;

  mesonFlags = [
    "-Dwith_docs=true"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/picom-trans \
      --prefix PATH : ${lib.makeBinPath [ xwininfo ]} \
      --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib"
  ''
  + lib.optionalString withDebug ''
    cp -r ../src $out/
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

 #passthru.updateScript = unstableGitUpdater {
 #  tagFormat = "v([A-Z]+)([a-z]+)|v([1-9]).([1-9])|v([1-9])-rc([1-9])";
 #  tagConverter = writeShellScript "picom-pijulius-tag-converter.sh" ''
 #    sed -e 's/v//g' -e 's/([A-Z])([a-z])+/8.2/g' -e 's/-rc([1-9])|-rc//g' -e 's/0/8.2/g'
 #  '';
 #};

  meta = {
    inherit (previousAttrs.meta)
      license
      longDescription
      mainProgram
      platforms
      ;

    description = "ft labs's picom fork with extensive animation support";
    homepage = "https://github.com/r0-zero/picom";
    maintainers = with lib.maintainers; [
      me
    ];
  };
})
