{ pkgs, config, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.zoxide = {
        enable = (pkgs.hostPlatform.system != "aarch64-linux");
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
