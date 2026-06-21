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

  buildGoModule,
  go,

  writeText,
  conf ? null,
  rule ? null,

}:

buildGoModule rec {
  pname = "gowm";
  version = "2026-01-06";

  src = fetchFromGitHub {
    owner = "0xb0b1";
    repo = "gowm";
   #rev = "main";
    rev = "102c677923ef9600facb3bb552735e21b60cb39f";
    sha256 = "0qlmfzss9ac8hpnqqxvssjhfah611s0y8wniccbzg25qkmf8dgg1";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.go" conf;
      ruleFile =
        if lib.isDerivation rule || builtins.isPath rule then rule else writeText "rules.go" rule;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.go"
    + " \n " +
    lib.optionalString (rule != null) "cp ${ruleFile} rules.go"
    ;

  nativeBuildInputs = [
    pkg-config
    go
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

  vendorHash = "sha256-gJ64L2LitMSDMONC9Zo+/5v39OO9A7/oFaOKLd7xKyA=";

  buildPhase = ''
    runHook preBuild
    go build -o gowm .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp gowm $out/bin/gowm
    cp gowmctl $out/bin/gowmctl
    chmod +x $out/bin/gowmctl
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/0xb0b1/gowm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "gowm";
  };
}
