#!/bin/sh
set -euo pipefail
set -x

# TODO:
# - configureability
# - better way of passthru since the bot checks it aggressively
# - DRY, and parallalize as a result (good chance to try nushell)

export CACHEDIR="${HOME}/.cache/rpi"; mkdir -p "${CACHEDIR}"

export UPSTREAM_BRANCH="nixos/nixos-unstable-small"
export RPI_BRANCH="rpi-wip"
export WORKTREE="rpi-updates-auto"

export NIXPKGS_GIT="/home/cole/code/nixpkgs/master"
export NIXPKGS_RPI_BRANCH="/home/cole/code/nixpkgs/${RPI_BRANCH}"
export NIXPKGS_WORKTREE="/home/cole/code/nixpkgs/${WORKTREE}"

export ARCH="x86_64-linux" # what system you're doing the update from

git -C "${NIXPKGS_GIT}" remote update
git -C "${NIXPKGS_GIT}" worktree prune

git -C "${NIXPKGS_RPI_BRANCH}" rebase --abort || true
git -C "${NIXPKGS_RPI_BRANCH}" rebase "${UPSTREAM_BRANCH}"

if [[ ! -d "${NIXPKGS_WORKTREE}" ]]; then
  git -C "${NIXPKGS_GIT}" branch -D "${WORKTREE}" || true
  git -C "${NIXPKGS_GIT}" worktree add "${NIXPKGS_WORKTREE}" -b "${WORKTREE}"
fi
git -C "${NIXPKGS_WORKTREE}" reset --hard "${RPI_BRANCH}"

########################################################################################################################
##
## UPDATE: raspberrypi-wireless-firmware

# NOTE THIS one is special, it has to check two things (why though, should we split these back apart?)
WORKDIR="${CACHEDIR}/raspberrypi-wireless-firmware"
if [[ ! -d "${WORKDIR}/btfw" ]]; then
  git clone --depth=1 'https://github.com/RPi-Distro/bluez-firmware' "${WORKDIR}/btfw" -b "master"
fi
if [[ ! -d "${WORKDIR}/wififw" ]]; then
  git clone --depth=1 'https://github.com/RPi-Distro/firmware-nonfree' "${WORKDIR}/wififw" -b "bullseye"
fi

git -C "${WORKDIR}/btfw" remote update
git -C "${WORKDIR}/wififw" remote update
git -C "${WORKDIR}/btfw" reset --hard "master"
git -C "${WORKDIR}/wififw" reset --hard "bullseye"

NEW_BTFW_REV="$(git -C "${WORKDIR}/btfw" log --pretty=format:"%H")"
NEW_BTFW_VERSION="$(git -C "${WORKDIR}/btfw" log --pretty=format:"%cs")"
NEW_WIFIFW_REV="$(git -C "${WORKDIR}/wififw" log --pretty=format:"%H")"
NEW_WIFIFW_VERSION="$(git -C "${WORKDIR}/wififw" log --pretty=format:"%cs")"

METADATA_FILE="${NIXPKGS_WORKTREE}/pkgs/os-specific/linux/firmware/raspberrypi-wireless/default.nix"
UPDATE_ATTR="${NIXPKGS_WORKTREE}#legacyPackages.${ARCH}.raspberrypiWirelessFirmware"
UPDATE_ATTR_NAME="raspberrypiWirelessFirmware"

NEW_WLFW_VERSION="${NEW_WIFIFW_VERSION}"
if [[ "${NEW_BTFW_VERSION}" > "${NEW_WIFIFW_VERSION}" ]]; then
  NEW_WLFW_VERSION="${NEW_BTFW_VERSION}"
fi

t="$(mktemp)"; trap "rm $t" EXIT;
nix "${nixargs[@]}" eval --json "${UPDATE_ATTR}.passthru.verinfo" > "${t}" 2>/dev/null
OLD_BTFW_REV="$(cat "${t}" | jq -r .btfw.rev)"
OLD_BTFW_HASH="$(cat "${t}" | jq -r .btfw.hash)"
OLD_WIFIFW_REV="$(cat "${t}" | jq -r .wififw.rev)"
OLD_WIFIFW_HASH="$(cat "${t}" | jq -r .wififw.hash)"

OLD_WLFW_VERSION="$(cat "${t}" | jq -r .version)"

PLACEHOLDER0="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

if [[ "${OLD_BTFW_REV}" != "${NEW_BTFW_REV}" ||  "${OLD_WIFIFW_REV}" != "${NEW_WIFIFW_REV}" ]]; then
  # do replacement!
  sed -i "s|${OLD_BTFW_REV}|${NEW_BTFW_REV}|g" "${METADATA_FILE}"
  sed -i "s|${OLD_BTFW_HASH}|${PLACEHOLDER0}|g" "${METADATA_FILE}"
  # copyable:
  nix "${nixargs[@]}" build --no-link "${UPDATE_ATTR}" &> "${t}" || true; cat "${t}"
  NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f2 | tr -d ' ' || true)"
  if [[ "${NEW_HASH}" == "sha256" ]]; then NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f3 | tr -d ' ' || true)"; fi
  NEW_HASH="$(nix "${nixargs[@]}" hash to-sri --type sha256 "${NEW_HASH}")"
  sed -i "s|${PLACEHOLDER0}|${NEW_HASH}|" "${METADATA_FILE}"

  # do replacement!
  sed -i "s|${OLD_WIFIFW_REV}|${NEW_WIFIFW_REV}|g" "${METADATA_FILE}"
  sed -i "s|${OLD_WIFIFW_HASH}|${PLACEHOLDER0}|g" "${METADATA_FILE}"
  # copyable:
  nix "${nixargs[@]}" build --no-link "${UPDATE_ATTR}" &> "${t}" || true; cat "${t}"
  NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f2 | tr -d ' ' || true)"
  if [[ "${NEW_HASH}" == "sha256" ]]; then NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f3 | tr -d ' ' || true)"; fi
  NEW_HASH="$(nix "${nixargs[@]}" hash to-sri --type sha256 "${NEW_HASH}")"
  sed -i "s|${PLACEHOLDER0}|${NEW_HASH}|" "${METADATA_FILE}"

  sed -i "s|${OLD_WLFW_VERSION}|${NEW_WLFW_VERSION}|" "${METADATA_FILE}"

  commitmsg="${UPDATE_ATTR_NAME}: ${OLD_WLFW_VERSION} -> ${NEW_WLFW_VERSION}"
  git -C "${NIXPKGS_WORKTREE}" commit "${METADATA_FILE}" -m "${commitmsg}"
fi


########################################################################################################################
##
## UPDATE: raspberrypi-eeprom
WORKDIR="${CACHEDIR}/raspberrypi-eeprom"
if [[ ! -d "${WORKDIR}" ]]; then
  mkdir -p "${WORKDIR}"
  git clone 'https://github.com/raspberrypi/rpi-eeprom' "${WORKDIR}"
fi
git -C "${WORKDIR}" remote update
git -C "${WORKDIR}" reset --hard origin/master
NEW_EEPROM_REV="$(git -C "${WORKDIR}" log --pretty=format:"%H" -n1 'firmware/stable')"
LATEST_PIEEPROM_FILENAME="$(basename "$(ls "${WORKDIR}"/firmware/stable/pieeprom*bin | sort | tail -1)")"
[[ "${LATEST_PIEEPROM_FILENAME}" =~ pieeprom-([0-9-]+).bin ]]
NEW_EEPROM_VERSION="${BASH_REMATCH[1]}" # match it out of filename

METADATA_FILE="${NIXPKGS_WORKTREE}/pkgs/os-specific/linux/raspberrypi-eeprom/default.nix"
UPDATE_ATTR="${NIXPKGS_WORKTREE}#legacyPackages.${ARCH}.raspberrypi-eeprom"
UPDATE_ATTR_NAME="raspberrypi-eeprom"
t="$(mktemp)"; trap "rm $t" EXIT;
nix "${nixargs[@]}" eval --json "${UPDATE_ATTR}.passthru.verinfo" > "${t}" 2>/dev/null
OLD_EEPROM_REV="$(cat "${t}" | jq -r .rev)"
OLD_EEPROM_HASH="$(cat "${t}" | jq -r .hash)"
OLD_EEPROM_VERSION="$(cat "${t}" | jq -r .version)"

if [[ "${OLD_EEPROM_REV}" != "${NEW_EEPROM_REV}" ]]; then
  # do replacement!
  sed -i "s|${OLD_EEPROM_REV}|${NEW_EEPROM_REV}|g" "${METADATA_FILE}"
  sed -i "s|${OLD_EEPROM_HASH}|${PLACEHOLDER0}|g" "${METADATA_FILE}"
  # copyable:
  nix "${nixargs[@]}" build --no-link "${UPDATE_ATTR}" &> "${t}" || true; cat "${t}"
  NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f2 | tr -d ' ' || true)"
  if [[ "${NEW_HASH}" == "sha256" ]]; then NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f3 | tr -d ' ' || true)"; fi
  NEW_HASH="$(nix "${nixargs[@]}" hash to-sri --type sha256 "${NEW_HASH}")"
  sed -i "s|${PLACEHOLDER0}|${NEW_HASH}|" "${METADATA_FILE}"

  sed -i "s|${OLD_EEPROM_VERSION}|${NEW_EEPROM_VERSION}|" "${METADATA_FILE}"

  commitmsg="${UPDATE_ATTR_NAME}: ${OLD_EEPROM_VERSION} -> ${NEW_EEPROM_VERSION}"
  git -C "${NIXPKGS_WORKTREE}" commit "${METADATA_FILE}" -m "${commitmsg}"
fi


########################################################################################################################
##
## UPDATE: raspberrypifw
WORKDIR="${CACHEDIR}/raspberrypifw"
if [[ ! -d "${WORKDIR}" ]]; then
  mkdir -p "${WORKDIR}"
  git clone --depth=1 'https://github.com/raspberrypi/firmware' "${WORKDIR}" -b "stable"
fi
git -C "${WORKDIR}" remote update
git -C "${WORKDIR}" reset --hard origin/stable
NEW_RPIFW_REV="$(git -C "${WORKDIR}" log --pretty=format:"%H" -n1 'boot')"
NEW_RPIFW_VERSION="$(git -C "${WORKDIR}" log --pretty=format:"%cs" -n1 'boot')"
KERNEL_COMMIT="$(cat "${WORKDIR}"/extra/git_hash)"

METADATA_FILE="${NIXPKGS_WORKTREE}/pkgs/os-specific/linux/firmware/raspberrypi/default.nix"
UPDATE_ATTR="${NIXPKGS_WORKTREE}#legacyPackages.${ARCH}.raspberrypifw"
UPDATE_ATTR_NAME="raspberrypifw"
t="$(mktemp)"; trap "rm $t" EXIT;
nix "${nixargs[@]}" eval --json "${UPDATE_ATTR}.passthru.verinfo" > "${t}" 2>/dev/null
OLD_RPIFW_REV="$(cat "${t}" | jq -r .rev)"
OLD_RPIFW_HASH="$(cat "${t}" | jq -r .hash)"
OLD_RPIFW_VERSION="$(cat "${t}" | jq -r .version)"

if [[ "${OLD_RPIFW_REV}" != "${NEW_RPIFW_REV}" ]]; then
  # do replacement!
  sed -i "s|${OLD_RPIFW_REV}|${NEW_RPIFW_REV}|g" "${METADATA_FILE}"
  sed -i "s|${OLD_RPIFW_HASH}|${PLACEHOLDER0}|g" "${METADATA_FILE}"
  # copyable:
  nix "${nixargs[@]}" build --no-link "${UPDATE_ATTR}" &> "${t}" || true; cat "${t}"
  NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f2 | tr -d ' ' || true)"
  if [[ "${NEW_HASH}" == "sha256" ]]; then NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f3 | tr -d ' ' || true)"; fi
  NEW_HASH="$(nix "${nixargs[@]}" hash to-sri --type sha256 "${NEW_HASH}")"
  sed -i "s|${PLACEHOLDER0}|${NEW_HASH}|" "${METADATA_FILE}"

  sed -i "s|${OLD_RPIFW_VERSION}|${NEW_RPIFW_VERSION}|" "${METADATA_FILE}"

  commitmsg="${UPDATE_ATTR_NAME}: ${OLD_RPIFW_VERSION} -> ${NEW_RPIFW_VERSION}"
  git -C "${NIXPKGS_WORKTREE}" commit "${METADATA_FILE}" -m "${commitmsg}"

fi


########################################################################################################################
##
## UPDATE: raspberrypifw-master
WORKDIR="${CACHEDIR}/raspberrypifw-master"
if [[ ! -d "${WORKDIR}" ]]; then
  mkdir -p "${WORKDIR}"
  git clone --depth=1 'https://github.com/raspberrypi/firmware' "${WORKDIR}" -b "master"
fi
git -C "${WORKDIR}" remote update
git -C "${WORKDIR}" reset --hard origin/master
NEW_RPIFW_REV="$(git -C "${WORKDIR}" log --pretty=format:"%H" -n1 'boot')"
NEW_RPIFW_VERSION="$(git -C "${WORKDIR}" log --pretty=format:"%cs" -n1 'boot')"
# KERNEL_COMMIT="$(cat "${WORKDIR}"/extra/git_hash)"

METADATA_FILE="${NIXPKGS_WORKTREE}/pkgs/os-specific/linux/firmware/raspberrypi/master.nix"
UPDATE_ATTR="${NIXPKGS_WORKTREE}#legacyPackages.${ARCH}.raspberrypifw-master"
UPDATE_ATTR_NAME="raspberrypifw-master"
t="$(mktemp)"; trap "rm $t" EXIT;
nix "${nixargs[@]}" eval --json "${UPDATE_ATTR}.passthru.verinfo" > "${t}" 2>/dev/null
OLD_RPIFW_REV="$(cat "${t}" | jq -r .rev)"
OLD_RPIFW_HASH="$(cat "${t}" | jq -r .hash)"
OLD_RPIFW_VERSION="$(cat "${t}" | jq -r .version)"

if [[ "${OLD_RPIFW_REV}" != "${NEW_RPIFW_REV}" ]]; then
  # do replacement!
  sed -i "s|${OLD_RPIFW_REV}|${NEW_RPIFW_REV}|g" "${METADATA_FILE}"
  sed -i "s|${OLD_RPIFW_HASH}|${PLACEHOLDER0}|g" "${METADATA_FILE}"
  # copyable:
  nix "${nixargs[@]}" build --no-link "${UPDATE_ATTR}" &> "${t}" || true; cat "${t}"
  NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f2 | tr -d ' ' || true)"
  if [[ "${NEW_HASH}" == "sha256" ]]; then NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f3 | tr -d ' ' || true)"; fi
  NEW_HASH="$(nix "${nixargs[@]}" hash to-sri --type sha256 "${NEW_HASH}")"
  sed -i "s|${PLACEHOLDER0}|${NEW_HASH}|" "${METADATA_FILE}"

  sed -i "s|${OLD_RPIFW_VERSION}|${NEW_RPIFW_VERSION}|" "${METADATA_FILE}"

  commitmsg="${UPDATE_ATTR_NAME}: ${OLD_RPIFW_VERSION} -> ${NEW_RPIFW_VERSION}"
  git -C "${NIXPKGS_WORKTREE}" commit "${METADATA_FILE}" -m "${commitmsg}"

fi


# ########################################################################################################################
# ##
# ## UPDATE: raspberrypi-armstubs
WORKDIR="${CACHEDIR}/raspberrypi-armstubs"
if [[ ! -d "${WORKDIR}/.git" ]]; then
  git clone --depth=1 'https://github.com/raspberrypi/tools/' "${WORKDIR}" -b "master"
fi
git -C "${WORKDIR}" remote update
git -C "${WORKDIR}" reset --hard origin/master
NEW_ARMSTUBS_REV="$(git -C "${WORKDIR}" log --pretty=format:"%H" -n1 'armstubs')"
NEW_ARMSTUBS_VERSION="$(git -C "${WORKDIR}" log --pretty=format:"%cs" -n1 'armstubs')"

METADATA_FILE="${NIXPKGS_WORKTREE}/pkgs/os-specific/linux/firmware/raspberrypi/armstubs.nix"
UPDATE_ATTR="${NIXPKGS_WORKTREE}#legacyPackages.${ARCH}.raspberrypi-armstubs"
UPDATE_ATTR_NAME="raspberrypi-armstubs"
t="$(mktemp)"; trap "rm $t" EXIT;
nix "${nixargs[@]}" eval --json "${UPDATE_ATTR}.passthru.verinfo" > "${t}" 2>/dev/null
OLD_ARMSTUBS_REV="$(cat "${t}" | jq -r .rev)"
OLD_ARMSTUBS_HASH="$(cat "${t}" | jq -r .hash)"
OLD_ARMSTUBS_VERSION="$(cat "${t}" | jq -r .version)"

if [[ "${OLD_ARMSTUBS_REV}" != "${NEW_ARMSTUBS_REV}" ]]; then
  # do replacement!
  sed -i "s|${OLD_ARMSTUBS_REV}|${NEW_ARMSTUBS_REV}|g" "${METADATA_FILE}"
  sed -i "s|${OLD_ARMSTUBS_HASH}|${PLACEHOLDER0}|g" "${METADATA_FILE}"
  # copyable:
  nix "${nixargs[@]}" build --no-link "${UPDATE_ATTR}" &> "${t}" || true; cat "${t}"
  NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f2 | tr -d ' ' || true)"
  if [[ "${NEW_HASH}" == "sha256" ]]; then NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f3 | tr -d ' ' || true)"; fi
  NEW_HASH="$(nix "${nixargs[@]}" hash to-sri --type sha256 "${NEW_HASH}")"
  sed -i "s|${PLACEHOLDER0}|${NEW_HASH}|" "${METADATA_FILE}"

  sed -i "s|${OLD_ARMSTUBS_VERSION}|${NEW_ARMSTUBS_VERSION}|" "${METADATA_FILE}"

  commitmsg="${UPDATE_ATTR_NAME}: ${OLD_ARMSTUBS_VERSION} -> ${NEW_ARMSTUBS_VERSION}"
  git -C "${NIXPKGS_WORKTREE}" commit "${METADATA_FILE}" -m "${commitmsg}"
fi


########################################################################################################################
##
## UPDATE: libraspberrypi
WORKDIR="${CACHEDIR}/libraspberrypi"
if [[ ! -d "${WORKDIR}/.git" ]]; then\
  git clone --depth=1 'https://github.com/raspberrypi/userland' "${WORKDIR}" -b "master"
fi
git -C "${WORKDIR}" remote update
git -C "${WORKDIR}" reset --hard origin/master

NEW_LIBRPI_REV="$(git -C "${WORKDIR}" log --pretty=format:"%H" -n1)"
NEW_LIBRPI_VERSION="$(git -C "${WORKDIR}" log --pretty=format:"unstable-%cs" -n1)"

METADATA_FILE="${NIXPKGS_WORKTREE}/pkgs/development/libraries/libraspberrypi/default.nix"
UPDATE_ATTR="${NIXPKGS_WORKTREE}#legacyPackages.${ARCH}.libraspberrypi"
UPDATE_ATTR_NAME="libraspberrypi"
t="$(mktemp)"; trap "rm $t" EXIT;
nix "${nixargs[@]}" eval --json "${UPDATE_ATTR}.passthru.verinfo" > "${t}" 2>/dev/null
OLD_LIBRPI_REV="$(cat "${t}" | jq -r .rev)"
OLD_LIBRPI_HASH="$(cat "${t}" | jq -r .hash)"
OLD_LIBRPI_VERSION="$(cat "${t}" | jq -r .version)"

if [[ "${OLD_LIBRPI_REV}" != "${NEW_LIBRPI_REV}" ]]; then
  # do replacement!
  sed -i "s|${OLD_LIBRPI_REV}|${NEW_LIBRPI_REV}|g" "${METADATA_FILE}"
  sed -i "s|${OLD_LIBRPI_HASH}|${PLACEHOLDER0}|g" "${METADATA_FILE}"
  # copyable:
  nix "${nixargs[@]}" build --no-link "${UPDATE_ATTR}" &> "${t}" || true; cat "${t}"
  NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f2 | tr -d ' ' || true)"
  if [[ "${NEW_HASH}" == "sha256" ]]; then NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f3 | tr -d ' ' || true)"; fi
  NEW_HASH="$(nix "${nixargs[@]}" hash to-sri --type sha256 "${NEW_HASH}")"
  sed -i "s|${PLACEHOLDER0}|${NEW_HASH}|" "${METADATA_FILE}"

  sed -i "s|${OLD_LIBRPI_VERSION}|${NEW_LIBRPI_VERSION}|" "${METADATA_FILE}"

  commitmsg="${UPDATE_ATTR_NAME}: ${OLD_LIBRPI_VERSION} -> ${NEW_LIBRPI_VERSION}"
  git -C "${NIXPKGS_WORKTREE}" commit "${METADATA_FILE}" -m "${commitmsg}"
fi


########################################################################################################################
##
## UPDATE: linux_rpi
WORKDIR="${CACHEDIR}/rpi_linux"
# for the kernel we want to clone a specific commit instead of getting the entire repo
# so... let's check what commit we have, if it's the wrong one, then delete and reclone.
if [[ ! -d "${WORKDIR}" \
|| "$(git -C "${WORKDIR}" log --pretty=format:"%H" -n1)" != "${KERNEL_COMMIT}" ]]; then
  mkdir -p "${WORKDIR}"
  git init "${WORKDIR}"
  git -C "${WORKDIR}" remote add origin "https://github.com/raspberrypi/linux" || true
  git -C "${WORKDIR}" fetch --depth 1 origin "${KERNEL_COMMIT}"
  git -C "${WORKDIR}" checkout FETCH_HEAD
fi

KRNL_VERSION="$(head -n 5 "${WORKDIR}/Makefile" | grep "^VERSION" | cut -d ' ' -f 3)"
KRNL_PATCHLEVEL="$(head -n 5 "${WORKDIR}/Makefile" | grep "^PATCHLEVEL" | cut -d ' ' -f 3)"
KRNL_SUBLEVEL="$(head -n 5 "${WORKDIR}/Makefile" | grep "^SUBLEVEL" | cut -d ' ' -f 3)"

NEW_LINUXRPI_REV="${KERNEL_COMMIT}"
NEW_LINUXRPI_MODDIRVERSION="${KRNL_VERSION}.${KRNL_PATCHLEVEL}.${KRNL_SUBLEVEL}"
NEW_LINUXRPI_VERSION="$(git -C "${WORKDIR}" log --pretty=format:"%cs" -n1 | tr -d '\-')"

METADATA_FILE="${NIXPKGS_WORKTREE}/pkgs/os-specific/linux/kernel/linux-rpi.nix"
UPDATE_ATTR="${NIXPKGS_WORKTREE}#legacyPackages.${ARCH}.linuxPackages_rpi4.kernel"
UPDATE_ATTR_NAME="linux_rpi"
t="$(mktemp)"; trap "rm $t" EXIT;
nix "${nixargs[@]}" eval --json "${UPDATE_ATTR}.passthru.verinfo" > "${t}" 2>/dev/null
OLD_LINUXRPI_REV="$(cat "${t}" | jq -r .rev)"
OLD_LINUXRPI_HASH="$(cat "${t}" | jq -r .hash)"
OLD_LINUXRPI_VERSION="$(cat "${t}" | jq -r .version)"
OLD_LINUXRPI_MODDIRVERSION="$(cat "${t}" | jq -r .modDirVersion)"

if [[ "${OLD_LINUXRPI_REV}" != "${NEW_LINUXRPI_REV}" ]]; then
  # do replacement!
  sed -i "s|${OLD_LINUXRPI_REV}|${NEW_LINUXRPI_REV}|g" "${METADATA_FILE}"
  sed -i "s|${OLD_LINUXRPI_HASH}|${PLACEHOLDER0}|g" "${METADATA_FILE}"
  # copyable:
  nix "${nixargs[@]}" build --no-link "${UPDATE_ATTR}" &> "${t}" || true; cat "${t}"
  NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f2 | tr -d ' ' || true)"
  if [[ "${NEW_HASH}" == "sha256" ]]; then NEW_HASH="$(cat "${t}" | grep 'got:' | cut -d':' -f3 | tr -d ' ' || true)"; fi
  NEW_HASH="$(nix "${nixargs[@]}" hash to-sri --type sha256 "${NEW_HASH}")"
  sed -i "s|${PLACEHOLDER0}|${NEW_HASH}|" "${METADATA_FILE}"

  sed -i "s|${OLD_LINUXRPI_VERSION}|${NEW_LINUXRPI_VERSION}|" "${METADATA_FILE}"
  sed -i "s|${OLD_LINUXRPI_MODDIRVERSION}|${NEW_LINUXRPI_MODDIRVERSION}|" "${METADATA_FILE}"

  OLD_LINUXRPI_VERSION="${OLD_LINUXRPI_VERSION}-${OLD_LINUXRPI_MODDIRVERSION}"
  NEW_LINUXRPI_VERSION="${NEW_LINUXRPI_VERSION}-${NEW_LINUXRPI_MODDIRVERSION}"

  commitmsg="${UPDATE_ATTR_NAME}: ${OLD_LINUXRPI_VERSION} -> ${NEW_LINUXRPI_VERSION}"
  git -C "${NIXPKGS_WORKTREE}" commit "${METADATA_FILE}" -m "${commitmsg}"
fi
