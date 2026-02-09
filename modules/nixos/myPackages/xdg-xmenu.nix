{
  lib,
  stdenv,
  fetchFromGitHub,
  xorgproto,
  libX11,
  libXft,
  inih,
  xmenu,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-xmenu";
  version = "v1.0.0-beta.2";

  src = fetchFromGitHub {
    owner = "xlucn";
    repo = "xdg-xmenu";
    rev = "c_version";  # Or use a specific commit/tag
    hash = "sha256-RtLMtwnXmuutudZslFU2+8+whN2wAzi/ViM44Rr7gI0=";  # Update this
  };

  buildInputs = [
    xorgproto
    libX11
    libXft
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
