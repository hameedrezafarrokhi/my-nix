{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  xorgproto,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "mopag";
  version = "2012-01-01";

  src = fetchFromGitHub {
    owner = "c00kiemon5ter";
    repo = "mopag";
    rev = "master";
    hash = "sha256-0oGTtDQ1rc/5ffHR6SH/OH62jUeOi9HZWTjQ9OPL7+w=";
  };

  nativeBuildInputs = [ xorgproto ];

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "mopag.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} mopag.c";

  preBuild = ''
     substituteInPlace Makefile \
       --replace '/usr/include' "${libX11.dev}/include" \
       --replace '/usr/lib' "${libX11.out}/lib"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 ${pname} $out/bin/${pname}
    runHook postInstall
  '';

  installTargets = "";

  meta = with lib; {
    homepage = "https://github.com/c00kiemon5ter/mopag";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mopag";
  };
}
