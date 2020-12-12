{ stdenv, runCommandNoCC, unzip }:

let
  version = "v1.21";
  sha256 = "1cqhxy51jyry13nkbqxm8i0vhazd1vavlgfbfva8hhzqfnmiljav";
  src = builtins.fetchurl {
    url = "https://github.com/pftf/RPi4/releases/download/${version}/RPi4_UEFI_Firmware_${version}.zip";
    inherit sha256;
  };
in
  runCommandNoCC "rpi4-uefi-fw-${version}" {} ''
    mkdir -p $out/
    echo ${unzip}/bin/unzip "${src}" -d $out/
    ${unzip}/bin/unzip "${src}" -d $out/
  ''