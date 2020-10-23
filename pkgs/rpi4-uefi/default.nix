{ stdenv, runCommandNoCC, unzip }:

let
  version = "v1.20";
  sha256 = "112ym2qrpaa0ay74n83gsvnf42zizkyrvdzgh53pll2mn6diw7j6";
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
    #mv $out/boot/RPI_EFI.fd $out/boot/RPI_EFI.fd.backup
    #cp ${ ./. + "/RPI_EFI.fd.${version}.custom" } $out/boot/RPI_EFI.fd
  #''
