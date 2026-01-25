{ lib
, stdenvNoCC
, fetchzip
, writeScript
, steamDisplayName ? "Proton-Cachyos"
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-cachyos";
  version = "cachyos-10.0-20260102-slr";  # UPDATE THIS

  src = fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/${finalAttrs.version}/proton-${finalAttrs.version}-x86_64.tar.xz";
    hash = "sha256-BMWknqrLiGxcW6oDRwdrX50qty7Ym79d+PfxZHz+c4Y=";  # nix will tell you the right hash
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
      Proton CachyOS, a fork of Proton-GE that is optiomised for High Performance
    '';
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ meeeeeee ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
