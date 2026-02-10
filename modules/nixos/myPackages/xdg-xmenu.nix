{
  lib,
  stdenv,
  fetchFromGitHub,
  inih,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-xmenu";
  version = "v1.0.0-beta.2";

  src = fetchFromGitHub {
    owner = "xlucn";
    repo = "xdg-xmenu";
    rev = "c_version";
    hash = "sha256-RtLMtwnXmuutudZslFU2+8+whN2wAzi/ViM44Rr7gI0=";
  };

  buildInputs = [
    inih
  ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    homepage = "https://github.com/xlucn/xdg-xmenu";
    description = "XDG Menu For Xmenu";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

})
