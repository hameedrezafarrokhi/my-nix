{ lib
, stdenvNoCC
, fetchzip
, writeScript
, steamDisplayName ? "Proton-Sarek-Async-git"
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-sarek-async";
  version = "10-8";  # UPDATE THIS

  src = fetchzip {
    url = "https://github.com/pythonlover02/Proton-Sarek/releases/download/Proton-Sarek${finalAttrs.version}/Proton-Sarek${finalAttrs.version}-async.tar.gz";
    hash = "sha256-3IfT/xoKioXYP7xUU59TKSBevVRp1SlhHQQd5YVY9U8=";  # nix will tell you the right hash
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [ "out" "steamcompattool" ];

  installPhase = ''
    runHook preInstall

    # Prevent direct environment installation
    echo "${finalAttrs.pname} should be used via programs.steam.extraCompatPackages in NixOS." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "${finalAttrs.version}" "${steamDisplayName}"
  '';

  meta = {
    description = ''
      Proton Sarek, a fork of Proton-GE that is optiomised for legacy GPUs
    '';
    homepage = "https://github.com/pythonlover02/Proton-Sarek";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ meeeeeee ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
