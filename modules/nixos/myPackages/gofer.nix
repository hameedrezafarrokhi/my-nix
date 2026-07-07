{
  lib,
  fetchFromGitea,

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

  go,
  buildGoModule,
}:

buildGoModule rec {
  pname = "gofer";
  version = "2026-06-02";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "JakeAtLinux";
    repo = "Gofer";
    rev = "2394bc75990d5c6f9332e395b508f06542e3b596";
    sha256 = "02vvghq5c42jkxm0p6s26fz9a7d7479dnbjfppxv8n1740avm41f";
  };

  nativeBuildInputs = [
    pkg-config
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
  ];

  vendorHash = "sha256-mCYgwTRukszYhQmm6leUXP26Ip6UDqHcV0CiSPCV47Y=";

  postInstall = ''
    mkdir -p $out/share/man/man1
    cp gofer.1 $out/share/man/man1/gofer.1
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/JakeAtLinux/Gofer";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "gofer";
  };
}
