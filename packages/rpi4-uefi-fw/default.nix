{ stdenv, runCommandNoCC, unzip }:

let
  version = "v1.17";
  sha256 = "1vvyngins1fgvlllsmlpkrw3jxc4yq4c61q4knhgzx799b4hn9is";
  src = builtins.fetchurl {
    url = "https://github.com/pftf/RPi4/releases/download/${version}/RPi4_UEFI_Firmware_${version}.zip";
    inherit sha256;
  };
in
  runCommandNoCC "rpi4-uefi-fw-${version}" {} ''
    mkdir -p $out/boot
    echo ${unzip}/bin/unzip "${src}" -d $out/boot
    ${unzip}/bin/unzip "${src}" -d $out/boot
  ''
