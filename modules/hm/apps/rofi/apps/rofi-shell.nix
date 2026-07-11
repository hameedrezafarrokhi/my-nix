{
  lib,
  stdenv,
  fetchFromGitHub,
  installFonts,
  makeWrapper,
  bg ? "#0C0F09",
  fg ? "#05E289",
  bgAlt ? "#1B1E25",
}:

stdenv.mkDerivation rec {
  pname = "rofi-shell";
  version = "2022-02-27";

  src = fetchFromGitHub {
    owner = "niraj998";
    repo = "Rofi-Scripts";
    rev = "1d0809a7f24107643461e68304ee9d020044e61b";
    sha256 = "1cw4l64fdqldjrgh5kswnzqhsxgfhwpkxmiy3v9ykjj91dpndnj2";
  };

  postPatch = ''
    substituteInPlace rofi/mount/cellmount \
      --replace '~/.config/rofi/mount/prompt.rasi' '/run/current-system/sw/share/rofi-shell/mount/prompt.rasi'
    substituteInPlace rofi/mount/mountusb \
      --replace '~/.config/rofi/mount/prompt.rasi' '/run/current-system/sw/share/rofi-shell/mount/prompt.rasi'
    substituteInPlace rofi/mount/mountusb \
      --replace '~/.config/rofi/mount/dmenu.rasi' '/run/current-system/sw/share/rofi-shell/mount/dmenu.rasi'
    substituteInPlace rofi/mount/askpass \
      --replace '~/.config/rofi/mount/passwd.rasi' '/run/current-system/sw/share/rofi-shell/mount/passwd.rasi'

    substituteInPlace rofi/music/music \
      --replace '~/.config/rofi/music/music.jpg' '/run/current-system/sw/share/rofi-shell/music/music.jpg'
    substituteInPlace rofi/music/music \
      --replace '$HOME/.config/rofi/music/config.rasi' '/run/current-system/sw/share/rofi-shell/music/config.rasi'
    substituteInPlace rofi/music/music \
      --replace '~/.config/rofi/music/lyrics' '/run/current-system/sw/share/rofi-shell/music/lyrics'

    substituteInPlace rofi/screen/screen \
      --replace '~/.config/rofi/screen/screen.png' '/run/current-system/sw/share/rofi-shell/screen/screen.png'
    substituteInPlace rofi/screen/screen \
      --replace '~/.config/rofi/screen/config.rasi' '/run/current-system/sw/share/rofi-shell/screen/config.rasi'

    substituteInPlace rofi/screenshot/screenshot \
      --replace '~/.config/rofi/screenshot/camera.png' '/run/current-system/sw/share/rofi-shell/screenshot/camera.png'
    substituteInPlace rofi/screenshot/screenshot \
      --replace '~/.config/rofi/screenshot/config.rasi' '/run/current-system/sw/share/rofi-shell/screenshot/config.rasi'

    substituteInPlace rofi/wifi/wifi \
      --replace '~/.config/rofi/wifi/prompt.rasi' '/run/current-system/sw/share/rofi-shell/wifi/prompt.rasi'
    substituteInPlace rofi/music/music \
      --replace '~/.config/rofi/wifi/dmenu.rasi' '/run/current-system/sw/share/rofi-shell/wifi/dmenu.rasi'
    substituteInPlace rofi/music/music \
      --replace '~/.config/rofi/wifi/passwd.rasi' '/run/current-system/sw/share/rofi-shell/wifi/passwd.rasi'

    find . -type f -name "*.rasi" -print0 | while IFS= read -r -d "" file; do
      substituteInPlace "$file" \
        --replace "#0C0F09" "${bg}"
    done

    find . -type f -name "*.rasi" -print0 | while IFS= read -r -d "" file; do
      substituteInPlace "$file" \
        --replace "#05E289" "${fg}"
    done

    find . -type f -name "*.rasi" -print0 | while IFS= read -r -d "" file; do
      substituteInPlace "$file" \
        --replace "#1B1E25" "${bgAlt}"
    done

    find . -type f -name "*.rasi" -print0 | while IFS= read -r -d "" file; do
      substituteInPlace "$file" \
        --replace "#1E222A" "${bg}"
    done

    find . -type f -name "*.rasi" -print0 | while IFS= read -r -d "" file; do
      substituteInPlace "$file" \
        --replace "#61AFEF" "${fg}"
    done

    find . -type f -name "*.rasi" -print0 | while IFS= read -r -d "" file; do
      substituteInPlace "$file" \
        --replace "#252931" "${bgAlt}"
    done
  '';

  nativeBuildInputs = [ installFonts makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/rofi-shell $out/bin
    cp -r ./rofi/* $out/share/rofi-shell

    cat > $out/bin/rofi-shell << 'EOF'
    #!/usr/bin/env bash
    rofi -show drun -config /run/current-system/sw/share/rofi-shell/config.rasi
    EOF

    cp rofi/mount/askpass $out/bin/rofi-shell-askpass
    cp rofi/mount/cellmount $out/bin/rofi-shell-cellmount
    cp rofi/mount/mountusb $out/bin/rofi-shell-mountusb

    cp rofi/music/music $out/bin/rofi-shell-music
    cp rofi/music/lyrics $out/bin/rofi-shell-lyrics

    cp rofi/screen/screen $out/bin/rofi-shell-screen

    cp rofi/screenshot/screenshot $out/bin/rofi-shell-screenshot

    cp rofi/wifi/wifi $out/bin/rofi-shell-wifi

    chmod +x $out/share/rofi-shell/mount/askpass
    chmod +x $out/share/rofi-shell/mount/cellmount
    chmod +x $out/share/rofi-shell/mount/mountusb
    chmod +x $out/share/rofi-shell/music/music
    chmod +x $out/share/rofi-shell/music/lyrics
    chmod +x $out/share/rofi-shell/screen/screen
    chmod +x $out/share/rofi-shell/screenshot/screenshot
    chmod +x $out/share/rofi-shell/wifi/wifi
    chmod +x $out/bin/rofi-shell-askpass
    chmod +x $out/bin/rofi-shell-cellmount
    chmod +x $out/bin/rofi-shell-mountusb
    chmod +x $out/bin/rofi-shell-music
    chmod +x $out/bin/rofi-shell-lyrics
    chmod +x $out/bin/rofi-shell-screen
    chmod +x $out/bin/rofi-shell-screenshot
    chmod +x $out/bin/rofi-shell-wifi
    chmod +x $out/bin/rofi-shell
  '';

  meta = with lib; {
    homepage = "https://github.com/niraj998/Rofi-Scripts";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-shell";
  };
}
