{ pkgs, config, inputs, modulesPath, ... }:

{
  imports = [
    ./oci-common.nix

    ../../profiles/user-cole.nix
    ../../profiles/interactive.nix
    ../../mixins/sshd.nix
  ];

  config = {
    networking.hostName = "oracular";
    
    fileSystems = {
      "/" = {
        fsType = "ext4";
      };
      "/boot" = {
        fsType = "vfat";
        options = [];
      };
    };

    # not that I don't want this, but I'm adding it for this:
    #     error: builder for '/nix/store/wcryv2kc4w96bkn80cpf3zzrz22nyjiw-lazy-options.json.drv' failed with exit code 1;                     
    #        last 10 log lines:                                                                                                           
    #        >                                                                                                                            
    #        >            50|     // lib.optionalAttrs (opt ? example) { example = substSpecial opt.example; }                            
    #        >            51|     // lib.optionalAttrs (opt ? default) { default = substSpecial opt.default; }                            
    #        >              |                                                      ^                                                      
    #        >            52|     // lib.optionalAttrs (opt ? type) { type = substSpecial opt.type; }                                     
    #        > Cacheable portion of option doc build failed.                                                                              
    #        > Usually this means that an option attribute that ends up in documentation (eg `default` or `description`) depends on the re
    # stricted module arguments `config` or `pkgs`.                                                                                       
    #        >                                                                                                                            
    #        > Rebuild your configuration with `--show-trace` to find the offending location. Remove the references to restricted argument
    # s (eg by escaping their antiquotations or adding a `defaultText`) or disable the sandboxed build for the failing module by setting `
    # meta.buildDocsInSandbox = false`.                                                                                                   
    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
    
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.device = "nodev";
  };
}
