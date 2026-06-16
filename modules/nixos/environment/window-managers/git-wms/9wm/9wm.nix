{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
}:

stdenv.mkDerivation rec {
  pname = "9wm";
  version = "2022-01-20";

  src = fetchFromGitHub {
    owner = "9wm";
    repo = "9wm";
   #rev = "master";
    rev = "8c59a57d708dbf25c321790db57efa3401dca12f";
    sha256 = "0q3plhwm92i4lmrb30vp5a8j23frjfmsmwdaswsbcbn069k8cd42";
  };

  buildInputs = [ libX11 libXext ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    homepage = "http://www.github.com/9wm/9wm";
    description = " ";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
  };
}
