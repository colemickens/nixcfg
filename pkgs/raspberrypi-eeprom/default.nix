{ stdenv, fetchFromGitHub, python, writeText
, binutils-unwrapped, raspberrypi-tools, makeWrapper }:

let
  version = "2020.07.31-stable";
  rev = "0e7da7ecd84cdf7b65d6fc8d43446aee665187dc";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpi-eeprom";
    inherit rev;
    sha256 = "sha256-1kYKCQ2idMjeVACC46WYv0acouUbcLWkTLGGmfw4yiQ=";
  };

  configFile = writeText "rpi-eeprom-update-config" ''
    FIRMWARE_ROOT="${src}/firmware"
    FIRMWARE_RELEASE_STATUS="stable"
    FIRMWARE_IMAGE_DIR="''${FIRMWARE_ROOT}/''${FIRMWARE_RELEASE_STATUS}"
    FIRMWARE_BACKUP_DIR="/var/lib/raspberrypi/bootloader/backup"
    BOOTFS=/boot
    USE_FLASHROM=0
    EEPROM_CONFIG_HOOK=
  '';
in stdenv.mkDerivation {
  pname = "rpi-eeprom";

  inherit version src;

  patchPhase = ''
    patchShebangs rpi-eeprom-update rpi-eeprom-config
    substituteInPlace rpi-eeprom-update --replace /etc/default/rpi-eeprom-update ${configFile}
  '';

  buildPhase = "";

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ python ];

  checkPhase = ''
    (
      cd test
      ./test-rpi-eeprom-config
    )
  '';

  doCheck = true;

  installPhase = ''
    mkdir -p $out/bin/
    cp rpi-eeprom-config rpi-eeprom-update firmware/vl805 $out/bin/
  '';

  fixupPhase = ''
    wrapProgram $out/bin/rpi-eeprom-update \
      --prefix PATH : ${binutils-unwrapped}/bin \
      --prefix PATH : ${raspberrypi-tools}/bin \
      --prefix PATH : $out
  '';
}
