{
  stdenv,
  lib,
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

  crystal,
  #shards,

  glibc,
  makeWrapper,
}:

let

  x11dep = fetchFromGitHub {
    owner = "tamasszekeres";
    repo = "x11-cr";
    rev = "v1.0.1";
    sha256 = "1m5pprp5mkxw2ca595zshk6mv3694zznc0zvgps2isrpjac5077d";
  };

  loggerc = fetchFromGitHub {
    owner = "restart-archive";
    repo = "logger.cr";
   #version = "0.0.1";
    rev = "c5bcd4c8dec64aff4a7040baf613c9bf1822340c";
    sha256 = "0n8wivlx01l5ql8n70jhvwckm9qacqcshiflzw8xl78qskrf5j0s";
  };

  tomlc = fetchFromGitHub {
    owner = "crystal-community";
    repo = "toml.cr";
   #version = "0.8.1";
    rev = "fd2a97e8c2f6f22f50808893358e79ebaf0f7a71";
    sha256 = "0g8pyi96aynr12apjzy4rypljiidb47wmg6a27b9hlciyh8p1r7v";
  };


in

#crystal.buildCrystalPackage rec {
stdenv.mkDerivation rec {
  pname = "xstatus";
  version = "2024-11-13";

  src = fetchFromGitHub {
    owner = "restart-archive";
    repo = "xstatus";
   #rev = "trunk";
    rev = "932a82c4587cced2df8b07a9fe6ecd16bc2feb95";
    sha256 = "0c34ml13vi7mr3wjv5d3ndy8ylb2b930r8b894y45siylg6307ra";
  };

  nativeBuildInputs = [
    pkg-config
    crystal
    #shards
    glibc
    makeWrapper
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
    glibc
  ];

 #shardFile = ./shards.nix;

  shardsinfo = ./Xstatus-shards.info;

 #format = "crystal";

 #crystalBinaries.xstatus.src = "src/xstatus.cr";

  buildPhase = ''
    #shards install

    mkdir -p lib/x11 lib/logger lib/toml
    cp -r ${x11dep}/* lib/x11/
    cp -r ${loggerc}/* lib/logger/
    cp -r ${tomlc}/* lib/toml/
    cp ${shardsinfo} lib/

    crystal build src/xstatus.cr --release
    #--link-flags="-L${x11dep}/lib" -o xstatus
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp xstatus $out/bin/xstatus-cr
    chmod +x $out/bin/xstatus-cr
  '';

  postInstall = ''
    wrapProgram $out/bin/xstatus-cr \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = with lib; {
    homepage = "https://github.com/restart-archive/xstatus";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xstatus";
  };
}
