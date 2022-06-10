#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
function nix() { echo "==>> nix ${@}" >/dev/stderr; "${DIR}/nix.sh" "${@}"; }

action="${1}"; shift
outres="${1}"; shift
host="${1}"; shift

# target="STEAL THIS FROM THE CONFIG??" # TODO
printf "activate-init" > "${NIXUP_LOGDIR}/status"

function summarize() {
  while true; do
    set +e
    output="$(set +e; ssh -o ConnectTimeout=5 "${target}" "\
      printf ' ==       current_top: '; readlink -f /run/current-system; \
      printf ' ==       current_krn: '; readlink -f /run/current-system/kernel; \
      printf ' ==        booted_top: '; readlink -f /run/booted-system; \
      printf ' ==        booted_krn: '; readlink -f /run/booted-system/kernel; \
      printf ' ==          uname -a: '; uname -a; \
      printf ' ==   pactl_sink_list: '; pactl list short sinks | cut -d \$'\t' -f 2 | tr '\n' ' '; \
      printf '\n'; \
      printf ' == pactl_sink_active: '; pactl list short sinks | grep RUNNING | cut -d \$'\t' -f 2 | tr '\n' ' ' || true; \
      printf '\n'; \
      printf ' ==  sha256: startelf: '; sha256sum /boot/firmware/start4.elf || true; \
      printf ' ==      <config.txt>:\n'; bat /boot/firmware/config.txt || true; \
      printf ' ==      </config.txt>'; \
    " 2>/dev/null)";
    exit=$?
    set -e
    
    if [[ "${exit}" == 0 ]]; then
      printf "\n::== summary (${host})\n" >/dev/stderr
      printf "\n${output}\n\n" >/dev/stderr
      break
    else
      printf "." >/dev/stderr
      sleep 1
    fi
  done
}


printf "\n=============================================================================================================\n" >/dev/stderr
printf "ACTIVATE: (outres: ${outres})\n" >/dev/stderr
printf "          (host: ${host}) (action: ${action})\n" >/dev/stderr
printf "=============================================================================================================\n" >/dev/stderr

target="$(tailscale ip --6 "${host}")"

if [[ "${action:-""}" == "switch" || "${action:-""}" == "reboot" ]]; then
  printf "==:: (activate) remote: download toplevel ($target) ($outres)\n" > /dev/stderr
  printf "activate-download" > "${NIXUP_LOGDIR}/status"
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --option 'narinfo-cache-negative-ttl' 0 --no-link --profile /nix/var/nix/profiles/system "${outres}")"

  printf "==:: (activate) switch-to-configuration ($target) ($outres)\n" > /dev/stderr
  printf "activate-switch" > "${NIXUP_LOGDIR}/status"
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${outres}" -c switch-to-configuration switch)"

  if [[ "${NIXOS_INSTALL:-""}" == "1" ]]; then
    printf "==:: (activate) install ($target) ($outres)\n" > /dev/stderr
    printf "activate-install" > "${NIXUP_LOGDIR}/status"
    ssh "${target}" "$(printf '\"%s\" ' sudo nixos-install --no-root-passwd --root / "${nixargs[@]}" --system "${outres}")"
  fi
  
  summarize
  printf "\n==:: activation done\n\n" >/dev/stderr
  printf "activate-done" > "${NIXUP_LOGDIR}/status"
fi

if [[ "${action:-""}" == "summarize" ]]; then
  # set -x;  summarize;  set +x
  summarize
fi

if [[ "${action:-""}" == "reboot" ]]; then
  booted="$(ssh "${target}" "readlink -f /run/booted-system")"
  if [[ "${booted}" == "${outres}" ]]; then
    printf "reboot-skip" > "${NIXUP_LOGDIR}/status"
    printf "\n==:: skip reboot for ${host} ...\n\n" >/dev/stderr
  else
    printf "reboot-wait" > "${NIXUP_LOGDIR}/status"
    printf "\n==:: reboot and wait for ${host} ...\n\n" >/dev/stderr
    ssh "${target}" "sudo reboot" >/dev/null 2>/dev/null || true
    summarize
    printf "reboot-done" > "${NIXUP_LOGDIR}/status"
  fi
fi

printf "==:: activate done ($host) (${target})\n" >/dev/stderr
