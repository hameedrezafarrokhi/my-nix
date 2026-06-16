{ lib
, stdenv
, fetchurl
, autoconf
, automake
, libtool
, m4
, libXpm
, libXmu
, libXft
, libXinerama
, libXrandr
, libX11
, libXt
, libXext
, libXrender
, libxkbfile
, xorgproto
, flex
, bison
, byacc
, writeText
}:

stdenv.mkDerivation rec {
  pname = "vtwm";
  version = "5.5.0";

  src = fetchurl {
    url = "https://sourceforge.net/projects/vtwm/files/${pname}-${version}.tar.gz";
    hash = "sha256-RI16/Y1aX8+r8bnGS4Ec+mvb+IksBn/gGhQYBu9h6vQ=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    m4
    xorgproto
    flex
    bison
    byacc
  ];

  buildInputs = [
    libXpm
    libXmu
    libXft
    libXinerama
    libXrandr
    libX11
    libXt
    libXext
    libXrender
    libxkbfile
  ];

  preConfigure = ''
    sed -i 's/PKG_CHECK_MODULES(VTWM, x11 xext xt xmu)/ /' configure.ac

    # Fix configure.ac version
    sed -e "/^AC_INIT/s|^.*$|AC_INIT([vtwm],[$version], [mailto:vtwm-hackers@lists.sandelman.ca],[vtwm])|" \
      -i configure.ac

    # Create COPYRIGHT file
    (
      head -n 26 add_window.c
      head -n 20 applets.c
      head -n 18 desktop.c
      head -n 22 sound.c
      cat contrib/nexpm/xpm.COPYRIGHT
    ) >COPYRIGHT

    # Fix missing includes
    sed -i '/prototypes.h/a #include <time.h>' add_window.c
    sed -i '/prototypes.h/a #include <sys/wait.h>' menus.c

    # Regenerate build system
    aclocal
    automake --foreign --add-missing
    autoconf
  '';

  configureFlags = [
    "--prefix=${placeholder "out"}"
    "--sysconfdir=/etc"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-int -std=gnu11";

  installFlags = [
    "DESTDIR=$(out)"
  ];

  postInstall = ''
    # Install license
    install -Dm0644 COPYRIGHT "$out/share/licenses/${pname}/COPYRIGHT"

    # Create desktop entry
    mkdir -p "$out/share/xsessions"
    cat > "$out/share/xsessions/${pname}.desktop" << EOF
[Desktop Entry]
Name=vtwm
Comment=A lightweight, customizable window manager with a virtual desktop
Exec=${pname}
TryExec=${pname}
Icon=
Type=Application
EOF
  '';

  meta = with lib; {
    description = "A lightweight, customizable window manager with a virtual desktop";
    homepage = "http://www.vtwm.org";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    mainProgram = "vtwm";
  };
}
