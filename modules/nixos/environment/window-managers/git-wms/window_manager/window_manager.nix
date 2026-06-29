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

  rustPlatform,

  cairo,
  dbus,

  gtk3,
  python3,

}:

rustPlatform.buildRustPackage rec {
  pname = "window_manager";
  version = "2024-10-17";

  src = fetchFromGitHub {
    owner = "JaMo42";
    repo = "window_manager";
   #rev = "main";
    rev = "738916d79af02ce25b76a39037b6da57d4529702";
    sha256 = "0g5yhajbqrfd3bgbz2fvmbqs64kcagjgfphdl596l3bbrhmbyh86";
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

    cairo
    dbus

    gtk3
    python3
  ];

  cargoHash = "sha256-DIzFgMgDU90giM15I5GZ9Kyew8n93UdaiIcmQ8EhEW0=";

  doCheck = false;

  buildPhase = ''
    runHook preBuild

    cargo build --no-default-features --release

    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://github.com/JaMo42/window_manager";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "window_manager";
  };
}
