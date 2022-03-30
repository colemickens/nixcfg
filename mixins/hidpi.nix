{ pkgs, config, ... }:

{
  config = {
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];
    
    boot.loader.grub.fontSize = 32;
    
    services = {
      kmscon.extraConfig = ''
        font-size=40
      '';
    };
  };
}
