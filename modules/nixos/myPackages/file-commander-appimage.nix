{
  lib,
  appimageTools,
  fetchurl,
  version ? "0.9.9.7",
  hash ? "sha256-TnZSpDfeQRLIwXTWWdKZqihjfLsFojWqPwA05VoWOc0=",
  arch ? "x86_64",

  extraPkgs ? pkgs: [  ],
}:

let
  pname = "file-commander";

  src = fetchurl {
    url = "https://github.com/VioletGiraffe/file-commander/releases/download/${version}/FileCommander.AppImage";
    inherit hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  inherit pname version src extraPkgs;

 #extraInstallCommands = ''
 #  mkdir -p $out/share/applications
 #  cat > $out/share/applications/${pname}.desktop <<EOF
 #  [Desktop Entry]
 #  Version=${version}
 #  MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/chromium;
 #  StartupNotify=true
 #  Terminal=false
 #  Type=Application
 #  Categories=Network;WebBrowser;
 #  Name=${pname}
 #  Comment=Zen Browser
 #  Exec=$out/bin/${pname}
 #  EOF
 #'';

 #passthru.updateScript = ./update.sh;

  meta = {
    homepage = "https://github.com/VioletGiraffe/file-commander";
    platforms = [ "x86_64-linux" ];
  };
}
