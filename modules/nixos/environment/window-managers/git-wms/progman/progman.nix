{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libXpm,
  libXext,
  gdk-pixbuf-xlib,
  gdk-pixbuf,
  glib,
  glibc,
  pkg-config,
  xxd,
}:

stdenv.mkDerivation rec {
  pname = "progman";
  version = "2024-11-17";

  src = fetchFromGitHub {
    owner = "jcs";
    repo = "progman";
   #rev = "master";
    rev = "dba2dc691b97a182d233412f022de4643ca83eae";
    sha256 = "1vjb7hy8hx43rn6jxy6vw8bwcbcy0iai8lhijx72f25afwkslr2l";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXft
    libXpm
    libXext
    gdk-pixbuf-xlib
    gdk-pixbuf
    glib
    glibc
    xxd
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
    "X11BASE=${libX11.dev}"
  ];

  installFlags = [  ];

  meta = with lib; {
    homepage = "https://github.com/jcs/progman";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "progman";
  };
}
