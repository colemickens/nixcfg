#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
function nix() { echo "==>> nix ${@}" >/dev/stderr; "${DIR}/nix.sh" "${@}"; }

action="${1}"; shift
outres="${1}"; shift
host="${1}"; shift

# target="STEAL THIS FROM THE CONFIG??" # TODO

function summarize() {
  return
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
      printf "\n::==:: activate: (${host}): SUMMARY\n" >/dev/stderr
      printf "\n${output}\n\n" >/dev/stderr
      break
    else
      printf "." >/dev/stderr
      sleep 1
    fi
  done
}

printf "==:: activate: [host: ${host}) [action: ${action}]\n" >/dev/stderr
printf "==:: activate: [outres:  ${outres}]\n" >/dev/stderr

# target="$(tailscale ip --6 "${host}")"
target="$(tailscale ip --4 "${host}")"
current="$(ssh "${target}" "readlink -f /run/current-system")"

printf "==:: activate: [current: ${current}]\n" >/dev/stderr

if [[ "${action:-""}" == "switch" || "${action:-""}" == "reboot" ]]; then
  if [[ "${current}" == "${outres}" ]]; then
    printf "==:: activate: (${host}): skip activation (already active)\n" > /dev/stderr
  else
    printf "==:: activate: (${host}): download\n" > /dev/stderr
    ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --option 'narinfo-cache-negative-ttl' 0 --no-link --profile /nix/var/nix/profiles/system "${outres}")"
  
    printf "==:: activate: (${host}): switch\n" > /dev/stderr
    ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${outres}" -c switch-to-configuration switch)"
  
    # if [[ "${NIXOS_INSTALL:-""}" == "1" ]]; then
    #   printf "==:: (activate) install ($target) ($outres)\n" > /dev/stderr
    #   ssh "${target}" "$(printf '\"%s\" ' sudo nixos-install --no-root-passwd --root / "${nixargs[@]}" --system "${outres}")"
    # fi
  fi
  
  summarize
fi

if [[ "${action:-""}" == "summarize" ]]; then
  # set -x;  summarize;  set +x
  summarize
fi

if [[ "${action:-""}" == "reboot" ]]; then
  if [[ "${current}" == "${outres}" ]]; then
    printf "\n==:: activate: (${host}): reboot (skip)\n\n" >/dev/stderr
  else
    printf "\n==:: activate: (${host}): reboot (and wait) ...\n\n" >/dev/stderr
    ssh "${target}" "sudo reboot" >/dev/null 2>/dev/null || true
    summarize
  fi
fi

exitcode=0
printf "==:: activate: (${host}): done\n" >/dev/stderr
printf "activate.sh: done: exitcode=${exitcode}\n" >/dev/stderr
exit "${exitcode}"
