{ stdenv, runCommandNoCC, unzip }:

let
  version = "v1.22";
  sha256 = "0yklg00fmg82rg1plyz6wc3kdgss9xp85ilhmc61p6jgvn0s138q";
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