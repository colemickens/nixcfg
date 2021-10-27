#!/usr/bin/env bash
set -euo pipefail
set -x

USERNAME="${TF_USERNAME}"
NIX_INSTALL_URL="${TF_NIX_INSTALL_URL}"

# TODO: support re-exec as root if we're not
# check if we're not "cole" and if so, make it and then re-exec *again*

if [[ "$${1:-""}" != "stage2" ]]; then
  if [[ "$(whoami)" != "$${USERNAME}}" ]]; then
    sudo adduser --gecos "" --disabled-password "$${USERNAME}"
    mkdir -p /home/"$${USERNAME}"/.ssh
    curl -L "https://github.com/colemickens.keys" > /home/cole/.ssh/authorized_keys
    sudo chown -R cole /home/"$${USERNAME}"/.ssh
    sudo chmod -R ugo-w /home/"$${USERNAME}"/.ssh
    sudo chmod -R ugo+rx /home/"$${USERNAME}"/.ssh
    sudo chmod -R ugo-w /home/"$${USERNAME}"/.ssh
    sudo chmod -R u+rw /home/"$${USERNAME}"/.ssh
    sudo chmod u+x /home/"$${USERNAME}"/.ssh
    sudo usermod -aG sudo "$${USERNAME}"
    echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
    sudo cp "$${0}" "/tmp/nix-unstable.sh"
    sudo chmod ugo+rx "/tmp/nix-unstable.sh"
    sudo -u "$${USERNAME}" "/tmp/nix-unstable.sh" stage2
  fi
  exit 0
fi

# configure nix ahead of time so daemon starts up with correct settings
# TODO: pull out extra subs/keys to TF var?

# TODO: keep in sync: commbox.sh/install-nix.sh
sudo mkdir -p "/etc/nix"
cat <<EOF | sudo tee -a "/etc/nix/nix.conf"
experimental-features = nix-command flakes ca-references
extra-substituters = https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org
extra-trusted-public-keys = colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso=
trusted-users = root @sudo
cores = 0
max-jobs = auto
EOF

curl -L "$${NIX_INSTALL_URL}" > /tmp/install
sudo chmod +x /tmp/install
/tmp/install --daemon

BASHRC="$(cat "/home/$${USERNAME}/.bashrc")"
cat <<EOF > "/home/$${USERNAME}/.bashrc"
if [ -e /home/$${USERNAME}/.nix-profile/etc/profile.d/nix.sh ]; then   # added by Nix installer
  source /home/$${USERNAME}/.nix-profile/etc/profile.d/nix.sh;         # added by Nix installer
fi                                                             # added by Nix installer
$${BASHRC}
EOF

source /home/$${USERNAME}/.nix-profile/etc/profile.d/nix.sh
nix version

echo "install-nix: all done!"
