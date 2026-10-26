{ inputs, ... }:

{
  imports = [
    inputs.underclass.nixosModules.default
  ];

  config = {
    services.underclass = {
      enable = true;
      openFirewall = false;
      bindAddress = "127.0.0.1:8080";
      environmentFile = "/run/secrets/underclass.env";
      settings = {
        codex_cooldown_secs = 1800;
        copilot_cooldown_secs = 1800;
      };
    };
  };
}
