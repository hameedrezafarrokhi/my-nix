{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  pkg-config,
  buildGoModule,
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
}:

buildGoModule rec {
  pname = "cortile";
  version = "2024-11-02";

  src = fetchFromGitHub {
    owner = "leukipp";
    repo = "cortile";
    rev = "96a0eddbaf37706a7ed64ffdf93cfc675e144730";
    sha256 = "1zj878hcb4i7s8f94rrayrvvwr299kav6zpll3kfmg5n0fhkpxfv";
  };

  vendorHash = "sha256-VlIPsUogiCQeWWrFsueB6COa91CWIGx3hb7HKC59rS0=";

  nativeBuildInputs = [ pkg-config ];

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
  ];

  meta = {
    homepage = "https://github.com/leukipp/cortile";
    description = "cortile";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
