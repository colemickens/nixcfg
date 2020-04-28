  #!/usr/bin/env bash

  set -x

  remoteuserid="$(ssh "${@}" id -u)"
  remoteusername="$(ssh "${@}" whoami)"
  localuserid="$(id -u)"

  fwdpath1="/run/user/${remoteuserid}/gnupg/S.gpg-agent"
  fwdpath2="/home/${remoteusername}/.gnupg/S.gpg-agent"
  TERM=xterm \
  ssh "${@}" rm "${fwdpath1}" || true
  ssh "${@}" rm "${fwdpath2}" || true
  LOCALUSER=1000
  ssh \
    -o "RemoteForward ${fwdpath1}:/run/user/${LOCALUSER}/gnupg/S.gpg-agent.extra" \
    -o "RemoteForward ${fwdpath2}:/run/user/${LOCALUSER}/gnupg/S.gpg-agent.extra" \
    -o StreamLocalBindUnlink=yes \
    -A \
    "${@}"
  set +x
