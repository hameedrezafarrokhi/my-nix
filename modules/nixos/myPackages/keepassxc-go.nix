{
  lib,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "keepassxc-go";
  version = "2025-05-20";

  src = fetchFromGitHub {
    owner = "MarkusFreitag";
    repo = "keepassxc-go";
    rev = "02baad98b0523b270ea753050a2ffa1fb11d31f5";
    sha256 = "1w6v29qac0l5v9zzlglbxczs7w51f4kyxwjnaanfkykc30zrp137";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fontconfig
    freetype
  ];

  vendorHash = lib.fakeHash;

  meta = with lib; {
    homepage = "https://github.com/MarkusFreitag/keepassxc-go";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "keepassxc-go";
  };
}
