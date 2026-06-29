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

  libc,
  autoconf,
 #automake,
 #libtool,
  enlightenment,
 #dbus,

}:

stdenv.mkDerivation rec {
  pname = "moksha";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "JeffHoogland";
    repo = "moksha";
   #rev = "master";
    rev = "429daeba844c4e24354e70ee430e497f5e8481df";
    sha256 = "1k0l1i1g7c2w16agd8hzhxlil5ay8822rjmk9m0s214rl7093wsw";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
   #automake
   #libtool
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

    enlightenment.efl
   #dbus
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    #./autogen.sh
    #./configure --prefix=$out
    #autoupdate
    #aclocal
    #automake --foreign --add-missing
    autoconf --force
    autoreconf -vfi
    make
    make install

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    #mkdir -p $out/bin
    #cp moksha $out/bin/moksha

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/JeffHoogland/moksha";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "moksha";
  };
}
