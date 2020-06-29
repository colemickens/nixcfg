
  (cd ~/code/nixpkgs/master;
    git remote update;
    git reset --hard nixpkgs/master && git push origin HEAD -f)

  (cd ~/code/nixpkgs/cmpkgs;
    git rebase nixpkgs/nixos-unstable-small && git push origin HEAD -f) || true

  (cd ~/code/nixpkgs/rpi;
    git rebase nixpkgs/nixos-unstable && git push origin HEAD -f) || true

  (cd ~/code/extras/home-manager;
    git remote update;
    git rebase rycee/master || git rebase --abort)

  (cd ~/code/overlays/nixpkgs-wayland;
    git remote update;
    git rebase origin/master || git rebase --abort)

  (cd ~/code/nixcfg; ./update-imports.sh)