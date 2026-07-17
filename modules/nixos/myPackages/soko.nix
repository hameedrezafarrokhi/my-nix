{
  lib,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  go,
  buildGoModule,
  lua,
  SDL,
  SDL2,
  SDL_image,
  SDL_Pango,
  SDL_ttf,
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
}:

buildGoModule rec {
  pname = "soko";
  version = "2024-03-31";

  src = fetchFromGitHub {
    owner = "glupi-borna";
    repo = "soko";
    rev = "01d0df655a9ebce9394de5a2351d850b4d3053f1";
    sha256 = "1qixmfpjyn0nki3ahhdikxki0hk2svks5xq30l947jjszqz2cq4a";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fontconfig
    freetype
    lua
    SDL
    SDL2
    SDL_image
    SDL_Pango
    SDL_ttf
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
  ];

  vendorHash = "sha256-BJWLvu7urydQzjmIowYabzpTfLTWnhZtls9nD00DGUE=";

  meta = with lib; {
    homepage = "https://github.com/glupi-borna/soko";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "soko";
  };
}
