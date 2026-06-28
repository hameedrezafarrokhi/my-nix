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
  graphviz,
  pandoc,
  dmenu,

}:

rustPlatform.buildRustPackage rec {
  pname = "oxidewm";
  version = "2023-09-13";

  src = fetchFromGitHub {
    owner = "FelixSchladt";
    repo = "OxideWM";
   #rev = "main";
    rev = "afa6285434f35e81c129708785dca074c9e7b094";
    sha256 = "19brnhvm2dqd79w5y6vncr9al69cpb9qlmkr5w26j4r3s6vdl8vk";
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
    graphviz
    pandoc
    dmenu
  ];

 #cargoLock = {
 #  lockFile = "${src}/Cargo.lock";
 #};

  cargoHash = lib.fakeHash;

  doCheck = false;

  buildPhase = ''
    runHook preBuild
    cargo build --release
    cargo build -p oxide-bar --release
    cargo build -p oxide-msg --release
    runHook postBuild
  '';

  installPhase = ''
    runHook preBuild
    mkdir -p $out/bin $out/etc/oxide $out/share/man/man1 $out/share/oxide
    install -Dm755 \
		target/release/oxide \
		target/release/oxide-bar \
		target/release/oxide-msg \
		-t $out/bin/
	cp -t $out/etc/oxide/oxide/ \
		resources/config.yml \
		bar_config.yml

	cp man/oxide.1 \
		man/oxide-bar.1 \
		man/oxide-config.1 \
		man/oxide-msg.1 \
		$out/share/man/man1/
    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://github.com/FelixSchladt/OxideWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "oxidewm";
  };
}
