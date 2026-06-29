{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,

  fvwm3,
  gettext,
  imagemagick,
  ksh,
  python3,
  stalonetray,
  xdg-utils,
  xdotool,
  xprop,
  xmodmap,
  xrdb,
  xrefresh,
  xset,
  xsettingsd,
  xorgproto,
  gtk2,
  gtk2-x11,
  gkrellm,
  xclip,
  xscreensaver,
  libsForQt5,
  dex,
  makeWrapper,

}:

stdenv.mkDerivation rec {
  pname = "NsCDE";
  version = "2023-11-06";

  src = fetchFromGitHub {
    owner = "NsCDE";
    repo = "NsCDE";
   #rev = "master";
    rev = "3552a76c3e5f97a230b4b66efe12ec4f9b5a8d22";
    sha256 = "0m5la2blg8kfan9s4y4xa6ar2k0kmy2dyg29n1ir841mvrfngp9b";
  };

  pythonEnv = python3.withPackages (ps: with ps; [
    xlib
    psutil
    setuptools
    pyxdg
    qtpy
    yamlcore
  ]);

  nativeBuildInputs = [
    pkg-config
    xorgproto
    makeWrapper
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype

    fvwm3
    gettext
    imagemagick
    ksh

    pythonEnv

    stalonetray
    xdg-utils
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugins

    xdotool
    xprop
    xmodmap
    xrdb
    xrefresh
    xset
    xsettingsd
    xorgproto
    gtk2
    gtk2-x11
    gkrellm
    xclip
    xscreensaver
    dex

  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    ./configure --prefix='$out' --libexecdir='$out/lib'
    make
    make DESTDIR="$out" install

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    #cd nscde_tools # TODO: we need stuff from here
    #pwd
    #ls
    #cd ..

    mkdir -p $out/bin
    cp bin/nscde $out/bin/nscde
    cp bin/nscde_fvwmclnt $out/bin/nscde_fvwmclnt

    chmod +x $out/bin/nscde
    chmod +x $out/bin/nscde_fvwmclnt

    wrapProgram $out/bin/nscde \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    wrapProgram $out/bin/nscde_fvwmclnt \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/NsCDE/NsCDE";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "NsCDE";
  };
}
