#!/usr/bin/env bash
set -euo pipefail
set -x

USERNAME="${TF_USERNAME}"
NIX_INSTALL_URL="${TF_NIX_INSTALL_URL}"
NIXOS_INFECT="${TF_NIXOS_INFECT:-}"

# TODO: support re-exec as root if we're not
# check if we're not "cole" and if so, make it and then re-exec *again*

if [[ "${1:-""}" != "stage2" ]]; then
  if [[ "$(whoami)" != "${USERNAME}}" ]]; then
    sudo adduser --gecos "" --disabled-password "${USERNAME}"
    mkdir -p /home/"${USERNAME}"/.ssh
    curl -L "https://github.com/colemickens.keys" > /home/cole/.ssh/authorized_keys
    sudo chown -R cole /home/"${USERNAME}"/.ssh
    sudo chmod -R ugo-w /home/"${USERNAME}"/.ssh
    sudo chmod -R ugo+rx /home/"${USERNAME}"/.ssh
    sudo chmod -R ugo-w /home/"${USERNAME}"/.ssh
    sudo chmod -R u+rw /home/"${USERNAME}"/.ssh
    sudo chmod u+x /home/"${USERNAME}"/.ssh
    sudo usermod -aG sudo "${USERNAME}"
    echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

    echo "checking if we should infect..."
    if [[ ! -z "${NIXOS_INFECT}" ]]; then
      echo "INFECTING!"

      # TODO

      exit 0
    fi

    sudo cp "${0}" "/tmp/nix-unstable.sh"
    sudo chmod ugo+rx "/tmp/nix-unstable.sh"
    sudo -u "${USERNAME}" "/tmp/nix-unstable.sh" stage2
  fi
  exit 0
fi

# TODO: pull out extra subs/keys to TF var?
# TODO: keep in sync: commbox.sh/install-nix.sh
curl -L "${NIX_INSTALL_URL}" > /tmp/install
sudo chmod +x /tmp/install
/tmp/install --daemon &> /tmp/nix-install.log

sudo mkdir -p "/etc/nix"
cat <<EOF | sudo tee -a "/etc/nix/nix.conf"
experimental-features = nix-command flakes ca-references
extra-substituters = https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org
extra-trusted-public-keys = colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso=
trusted-users = root @sudo
cores = 0
max-jobs = auto
EOF

sudo systemctl restart nix-daemon

BASHRC="$(cat "/etc/bash.bashrc")"
NIXSNIPPET="$(cat "/etc/profile.d/nix.sh")"
printf '%s\n#####\n%s' \
  "${NIXSNIPPET}" \
  "${BASHRC}" | sudo tee "/etc/bash.bashrc"

source "/etc/profile.d/nix.sh"
nix --version

echo "install-nix: all done!"
