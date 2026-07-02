{
  lib,
  stdenv,
  fetchFromGitHub,
}:

let

  ikz87 = fetchFromGitHub {
    owner = "ikz87";
    repo = "picom-shaders";
   #rev = "main";
    rev = "65ecd9d41c7c976704776c595ee5fe36c026063d";
    sha256 = "1j58cm7bnjzi98ql7sy056362kk5aa2fq43jbgqc897plvrqid7v";
  };

  SwayLE3 = fetchFromGitHub {
    owner = "SwayLE3";
    repo = "picom-shader-oldCRT-Bloom";
   #rev = "main";
    rev = "9db8b49b89e42bb9aead623fa2bed5ba031c530f";
    sha256 = "114fhrs25piwjhbdw07bn07qj3r2i56gp29rl1ghwvgasf8ys6h3";
  };

  tphLatte = fetchFromGitHub {
    owner = "tphLatte";
    repo = "picomShaders";
   #rev = "main";
    rev = "19464403f4c9450e256a48bc80a16130912f4d46";
    sha256 = "1cah6q4hyv8pl40jclxf8mkq8m2yfai6ad7n8kh8shkaxq0wrf7h";
  };

  mTvare6 = fetchFromGitHub {
    owner = "mTvare6";
    repo = "picom-shaders";
   #rev = "main";
    rev = "2b80366952da07a073e3bfd334b36aa73bc96a87";
    sha256 = "03ks706yrrfbizl1pr6vc3wmf52sxm54ijhzhvak6jklnhp2sizj";
  };

  PickNicko13 = fetchFromGitHub {
    owner = "PickNicko13";
    repo = "picom-o8dither";
   #rev = "main";
    rev = "6db583ba8d6e9627bac5ea5c2f4912b1802b5392";
    sha256 = "10f949gicwv4invsm77pjsl32zvjnk105q2kcv941b4ynl1lypr6";
  };

  pwfff = fetchFromGitHub {
    owner = "pwfff";
    repo = "picom-experiments";
   #rev = "main";
    rev = "23db3ee5db3bcf8d9174e4eeaffa0957140c2406";
    sha256 = "1n8cicf55vii32wdirvrfr85i4zlsgykrs286yvfzjmjmaixi7vc";
  };

  dedenholm = fetchFromGitHub {
    owner = "dedenholm";
    repo = "picom-rainbow-border-glsl";
   #rev = "main";
    rev = "5e68e88954d2a50b9c782b9ce73164682fc2e6fa";
    sha256 = "0d6nybzd8zdzakv9y2v60z2ib2c91px26ylmkvg7ccv25a3hh63b";
  };

  dedenholm2 = fetchFromGitHub {
    owner = "dedenholm";
    repo = "Chromab-Glitch-GLSL-";
   #rev = "main";
    rev = "ef3a588b088e758f38c67dca22714a2b93e88959";
    sha256 = "01jy05hcj651sg65zjw3wrwhzbpjrqaj3r01bi0x6z740z1gq5sv";
  };

  _4194304 = fetchFromGitHub {
    owner = "4194304";
    repo = "color-depth-shaders";
   #rev = "main";
    rev = "7e90227cdea470fa9eefe7c3c75824b3da1ff6e5";
    sha256 = "09d6pyrpbqz3xx9mkc1cx1nvwz0wrh38c8xqb1c8cm7q12swkn88";
  };

in

stdenv.mkDerivation rec {
  pname = "picom-shader-collection";
  version = "2026-07-02";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''

    mkdir -p \
      $out/share/${pname} \
      $out/share/${pname}/ikz87 \
      $out/share/${pname}/SwayLE3 \
      $out/share/${pname}/tphLatte \
      $out/share/${pname}/mTvare6 \
      $out/share/${pname}/PickNicko13 \
      $out/share/${pname}/pwfff \
      $out/share/${pname}/dedenholm \
      $out/share/${pname}/dedenholm2 \
      $out/share/${pname}/_4194304

    cp -r ${ikz87}/* $out/share/${pname}/ikz87
    cp -r ${SwayLE3}/* $out/share/${pname}/SwayLE3
    cp -r ${tphLatte}/* $out/share/${pname}/tphLatte
    cp -r ${mTvare6}/* $out/share/${pname}/mTvare6
    cp -r ${PickNicko13}/* $out/share/${pname}/PickNicko13
    cp -r ${pwfff}/* $out/share/${pname}/pwfff
    cp -r ${dedenholm}/* $out/share/${pname}/dedenholm
    cp -r ${dedenholm2}/* $out/share/${pname}/dedenholm2
    cp -r ${_4194304}/* $out/share/${pname}/_4194304

  '';

  meta = with lib; {
    description = " ";
    longDescription = '' '';
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
  };
}
