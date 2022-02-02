{ config, pkgs, lib, ... }:

let cfg = config.code-server;

in {
  options.code-server = with lib; {
    enable = lib.mkEnableOption "Enable this to start a visual studio code server.";
    port = lib.mkOption {
      type = lib.types.port;
      description = "The port on which vs code is served.";
      default = 5902;
      example = 5902;
    };
    user = lib.mkOption {
      type = lib.types.str;
      description = "The user under which the server runs.";
      default = config.vital.mainUser;
      example = "MyUserName";
    };
  };

  config =
    let extensionDir = "/home/${cfg.user}/.local/share/code-server/extensions";
    in lib.mkIf cfg.enable {
      system.activationScripts.preinstall-vscode-extensions = let extensions = with pkgs; [
        vscode-extensions.ms-vscode.cpptools
      ]; in {
        text = ''
          mkdir -p ${extensionDir}
          chown -R ${cfg.user}:users /home/${cfg.user}/.local/share/code-server
          for x in ${lib.concatMapStringsSep " " toString extensions}; do
              ln -sf $x/share/vscode/extensions/* ${extensionDir}/
          done
          chown -R ${cfg.user}:users ${extensionDir}
        '';
        deps = [];
      };

      systemd.services.code-server = {
        description = "Visual Studio Code Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.git ];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = "users";
          ExecStart = ''
            ${pkgs.code-server}/bin/code-server \
              --port ${toString cfg.port} \
              --bind-addr "0.0.0.0:${toString cfg.port}" \
              --auth none
          '';
          Restart = "always";
        };
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    };
}

