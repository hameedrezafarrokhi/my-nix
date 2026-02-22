{ lib
, symlinkJoin
, geany
, geany-plugins
}:

symlinkJoin {
  name = "geany-with-plugins-${geany.version}";
  paths = [ geany geany-plugins ];
  postBuild = ''
    ln -sf ${geany-plugins}/lib/geany/geany/*.so $out/lib/geany/
  '';

  meta = with lib; {
    description = "Geany with VTE terminal support and plugins";
    inherit (geany.meta)
      homepage
      license
      maintainers
      platforms
      mainProgram
      ;
  };
}
