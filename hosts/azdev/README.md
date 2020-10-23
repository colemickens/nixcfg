symlink to image-azplex's default.nix
since we just use the plex box as the devbox

./nixup.sh \
  azdev azdev.westus2.cloudapp.azure.com 22


# overview

- first we create long-term resources:
- `colemick-devenv-persist`
  - create blank disk
  - lock resource group

- then each time we want to develop, we create short-term resources:
  - nix->arm
  - arm deploy