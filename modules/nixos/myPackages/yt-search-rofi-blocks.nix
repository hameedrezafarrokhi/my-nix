{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "yt_search_rofi_blocks";
  version = "2022-09-02";

  src = fetchFromGitHub {
    owner = "su55y";
    repo = "yt_search_rofi_blocks";
    rev = "eb4201a3b2644e6007fe7c49b690b3998de9871d";
    sha256 = "0dqizmpd3bn3lwn3c68iahfn48yynvccvhhlhh0arcpqipmajb5h";
  };

  env = { CGO_ENABLED = 0; };

  vendorHash = "sha256-2dJTaM6HSY2h+yX0bApJk1xwrKUJNkUS3fIee2FG/Vg=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/su55y/yt_search_rofi_blocks";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "yt_search_rofi_blocks";
  };
}
