{
  pkgs,
  config,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.joshuto = {
          enable = true;
          settings = {
            preview = {
              use_preview_script = true;
              max_preview_size = (2 * 1024 * 1024);
              preview_script = "bat";
            };
          };
        };
      };
  };
}
