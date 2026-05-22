{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,

  libxtst,
 #xmodmap,

  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  python3,
  python3Packages,
  makeWrapper,
  gobject-introspection,
  glib,
  wrapGAppsHook3,
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    configparser
    xlib
  ]);
in

stdenv.mkDerivation rec {
  pname = "hogewm";
  version = "2024-10-9";

 #src = fetchFromGitHub {
 #  owner = "void-hoge";
 #  repo = "hogewm";
 #  rev = "main";
 #  hash = "sha256-uv2TFnBmKjY0k9JsSsYFIhPWm9mLTNSqTlz/AA8s3sY=";
 #};

  src = ./hogewm;

  nativeBuildInputs = [ makeWrapper gobject-introspection wrapGAppsHook3 ];

  buildInputs = [
    pythonEnv
    libX11
    libXext
    libXrandr

    libxtst
   #xmodmap

    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
    python3
    python3Packages.xlib
    makeWrapper
    glib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    # Install the Python script
    mkdir -p $out/lib/${pname}
    cp ${src}/hogewm $out/lib/${pname}/
    cp ${src}/eternal_sleep $out/lib/${pname}/
    mkdir -p $out/home
    cp -r ${src}/home $out/
    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --add-flags "$out/lib/${pname}/hogewm" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"
    makeWrapper ${pythonEnv}/bin/python $out/bin/eternal_sleep \
      --add-flags "$out/lib/${pname}/eternal_sleep" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"
    runHook postInstall
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/hogewm || true
  '';

  meta = with lib; {
    homepage = "https://github.com/void-hoge/hogewm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "hogewm";
  };
}
