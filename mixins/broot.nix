{ pkgs, config, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.broot = {
        # TODO: wtf, why is broot sensitive to system/arch?
        enable = (pkgs.stdenv.hostPlatform.system == "x86_64-linux");

        # enableBashIntegration = true;
        # enableFishIntegration = true;
        # enableZshIntegration = true;
      };
    };
  };
}
