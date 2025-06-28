{ ... }:

{
  config = {
    virtualisation.spiceUSBRedirection.enable = true;

    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          virt-manager
          virt-viewer
        ];
      };
  };
}
