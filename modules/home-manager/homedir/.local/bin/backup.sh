#!/usr/bin/env bash

set -x
set -e

src="/home/"
dst="/tmp/backupdrive/XEEP_HOME"


###############################################################################
## Close, reopen encrypted drive
sudo umount /tmp/backupdrive || true
sudo cryptsetup luksClose crbackup || true
sudo mkdir -p /tmp/backupdrive
(
  set +x
  DRIVEPW="$(gopass "cole/backup-drive-password" | head -1)"
  ENCDRIVE="/dev/disk/by-uuid/c71afebb-dfdf-4539-9c92-041a9104953e"
  echo "${DRIVEPW}" | sudo cryptsetup luksOpen "${ENCDRIVE}" crbackup
)
sudo mount /dev/mapper/crbackup /tmp/backupdrive

###############################################################################
## Rsync, delete aggressively
rsync \
  -avh \
  --delete \
  --exclude=".cache" \
  --exclude="IGNORE_SYNC" \
  --exclude=".config/pulse" \
  --exclude=".mozilla/firefox" \
  --exclude=".local/share/nvim/swap" \
  --exclude="target/release" \
  --exclude="target/debug" \
  --delete-excluded \
  "${src}" "${dst}"

