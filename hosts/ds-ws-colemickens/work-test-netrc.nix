{ pkgs, config, lib, ... }:

{
  environment.etc."determinate/corporate-netrc" = {
    text = ''
      machine nixcache.example.com
      login user
      password mypassword
    '';
    # this forces the file to be copied, rather than be a symlink to store path
    mode = "0666";
  };

  environment.etc."determinate/config.json".text = ''
    {
      "authentication": {
        "additionalNetrcSources": [
          "/etc/${config.environment.etc."determinate/corporate-netrc".target}"
        ]
      }
    }
  '';
}
