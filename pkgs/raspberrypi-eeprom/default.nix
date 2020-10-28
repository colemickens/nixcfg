{ stdenv, fetchFromGitHub, python, writeText
, binutils-unwrapped, raspberrypi-tools, makeWrapper }:

let
  version = "2020.09.03-138a1";
  rev = "v2020.09.03-138a1";
  pieeprom-latest = "pieeprom-2020-09-03.bin";
  vl805-latest = "vl805-000138a1.bin";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpi-eeprom";
    inherit rev;
    sha256 = "sha256-BlVjFb0WC+ukn00i4O5Qv56OwC+AAnyh+j9e0KLnSKY=";
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

    mkdir -p $out/stable/
    cp "firmware/stable/${pieeprom-latest}" $out/stable/
    cp "firmware/stable/${vl805-latest}" $out/stable/
    ln -s "$out/stable/${pieeprom-latest}" $out/stable/pieeprom-latest.bin
    ln -s "$out/stable/${vl805-latest}"      $out/stable/vl805-latest.bin
  '';

  fixupPhase = ''
    wrapProgram $out/bin/rpi-eeprom-update \
      --prefix PATH : ${binutils-unwrapped}/bin \
      --prefix PATH : ${raspberrypi-tools}/bin \
      --prefix PATH : $out
  '';

  meta.platforms = [ "aarch64-linux" ];
}
