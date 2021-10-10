#!/usr/bin/env bash
set -euo pipefail
set -x

USERNAME="cole"

# TODO: support re-exec as root if we're not
# check if we're not "cole" and if so, make it and then re-exec *again*

if [[ "${1:-""}" != "stage2" ]]; then
    sudo adduser --gecos "" --disabled-password "${USERNAME}"
    mkdir -p /home/cole/.ssh
    curl -L "https://github.com/colemickens.keys" > /home/cole/.ssh/authorized_keys
    sudo chown -R cole /home/cole/.ssh
    sudo chmod -R ugo-w /home/cole/.ssh
    sudo chmod -R ugo+rx /home/cole/.ssh
    sudo chmod -R ugo-w /home/cole/.ssh
    sudo chmod -R u+rw /home/cole/.ssh
    sudo chmod u+x /home/cole/.ssh
    sudo usermod -aG sudo "${USERNAME}"
    echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
    sudo cp "${0}" "/tmp/nix-unstable.sh"
    sudo chmod ugo+rx "/tmp/nix-unstable.sh"
    sudo -u "${USERNAME}" "/tmp/nix-unstable.sh" stage2
    exit 0
fi

# TODO: pr these changes to tailscale/github-action
# ==tailscale=download
TSVERSION="1.14.6"
case $(uname -m) in aarch64) TSARCH="arm64" ;; amd64|x86_64) TSARCH="amd64" ;; esac && export TSARCH
MINOR=$(echo "$TSVERSION" | awk -F '.' {'print $2'})
if [ $((MINOR % 2)) -eq 0 ]; then
    URL="https://pkgs.tailscale.com/stable/tailscale_${TSVERSION}_${TSARCH}.tgz"
else
    URL="https://pkgs.tailscale.com/unstable/tailscale_${TSVERSION}_${TSARCH}.tgz"
fi
curl "$URL" -o /tmp/tailscale.tgz
tar -C /tmp -xzf /tmp/tailscale.tgz
rm /tmp/tailscale.tgz
TSPATH="/tmp/tailscale_${TSVERSION}_${TSARCH}"
sudo mv "${TSPATH}/tailscale" "${TSPATH}/tailscaled" /usr/bin
# ==tailscale=run
sudo tailscaled 2>~/tailscaled.log &
HOSTNAME="$(cat /etc/hostname)"
until sudo tailscale up --authkey "@TAILSCALE_AUTHKEY@" --hostname=${HOSTNAME} --accept-routes; do
    sleep 0.5
done

# == nix latest -  not working on aarch64, so for now install stable, then upgrade
# curl "https://nixos-nix-install-tests.cachix.org/serve/j087w6xqqspfs363449x750x9r0kn31s/install" > install
# chmod +x install
# ./install --tarball-url-prefix https://nixos-nix-install-tests.cachix.org/serve
# == nix stable
curl -L "https://nixos.org/nix/install" > /tmp/install
chmod +x /tmp/install
/tmp/install --daemon

cfgline="if [ -e /home/cole/.nix-profile/etc/profile.d/nix.sh ]; then . /home/cole/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer]"
echo -e "${cfgline}\n\n$(cat "${HOME}/.bashrc")" > "${HOME}/.bashrc"

bash -cl "nix-env -iA nixpkgs.nixUnstable"

mkdir -p "/etc/nix"
cat <<EOF | sudo tee -a "/etc/nix/nix.conf"
experimental-features = nix-command flakes ca-references
extra-binary-caches = https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso=
trusted-users = root cole @sudo
EOF

echo "bootstrap: all done!"
