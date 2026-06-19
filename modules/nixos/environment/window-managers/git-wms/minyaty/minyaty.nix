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

in

#crystal.buildCrystalPackage rec {
stdenv.mkDerivation rec {
  pname = "minyaty";
  version = "2023-01-04";

  src = fetchFromGitHub {
    owner = "elebow";
    repo = "minyaty";
   #rev = "trunk";
    rev = "325c23853172e27f9c633be89676bf20083f7033";
    sha256 = "0riyfzmb9549za8rs28pa4kz356f1851avw8sfzjzkjs4am1jd9m";
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

  shardsinfo = ./shards.info;

 #format = "crystal";

 #crystalBinaries.minyaty.src = "src/minyaty.cr";

  buildPhase = ''
    #shards install

    mkdir -p lib/x11
    cp -r ${x11dep}/* lib/x11/
    cp ${shardsinfo} lib/

    crystal build src/minyaty.cr --release
    #--link-flags="-L${x11dep}/lib" -o minyaty
  '';

  postInstall = ''
    mkdir -p $out/bin
    cp minyaty $out/bin/
    cp command.sh $out/bin/minyatyc
    chmod +x $out/bin/minyatyc

    wrapProgram $out/bin/minyaty \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = with lib; {
    homepage = "https://github.com/elebow/minyaty";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "minyaty";
  };
}
