{
  config,
  pkgs,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, lib, ... }@hm:
      {
        home.file.".cargo/config.toml".text = ''
          [build]
          build-dir = "{cargo-cache-home}/{workspace-path-hash}"
        '';
      };
  };
}
