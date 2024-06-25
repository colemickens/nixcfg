{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  inherit (builtins) hasAttr;

  # FEATURES:
  # - per-tty autologin
  # - per-tty choice of console emulator
  # - on-demand activation via the normal logind/autovt@.service mechanism

  # NOTES:
  # we don't have greet/help line since they're "global" and already covered by the getty module
  # - we don't want to disable the getty module
  #   we leverage it and it's units, and it drives serial console, etc
  # - we don't want to suppress systemd units, somehow this manages to properly
  #   override autovt@ such that login starts our ttys as configured
  # - consider a slight refactor so the alias/service are self contained and merged a level up.
  #   shouldn't matter but it makes the association more clear
  #   (and the alias name could be parameterized to a var instead of a special string more easily)

  cfg = config.services.ttys;

  enabled = cfg.unsafe_enable;
  nAutoVTs = config.services.logind.nAutoVTs;
  reservedVT = config.services.logind.reservedVT;

  # pre-generate list of all TTYs we're going to alias to autovt@${tty}.service "manually"
  allTTYs = (map (n: "tty${toString n}") (lib.range 1 nAutoVTs));

  # getty helpers
  gettyBaseArgs =
    v:
    [
      "--login-program"
      "${v.loginProgram}"
    ]
    ++ (lib.optionals (v.autologinUser != null) [
      "--autologin"
      v.autologinUser
    ])
    ++ (lib.optionals (v.loginOptions != null) [
      "--login-options"
      v.loginOptions
    ])
    ++ v.extraArgs;
  autovtGettyArgs = "%I --keep-baud $TERM";
  gettyCmd =
    k: v: args:
    "@${pkgs.util-linux}/sbin/agetty agetty ${lib.escapeShellArgs (gettyBaseArgs v)} ${args}";

  kmsConfigDir =
    k: v:
    pkgs.writeTextFile {
      name = "kmscon-${k}-config";
      destination = "/kmscon.conf";
      text = v.extraConfig;
    };
  # kmscon helpers
  kmsAutologinArg = k: v: lib.optionalString (v.autologinUser != null) "-f ${v.autologinUser}";
  kmsconCmd =
    k: v:
    ''${pkgs.kmscon}/bin/kmscon "--vt=%I" ${v.extraOptions} --seats=seat0 --no-switchvt --configdir ${kmsConfigDir k v} --login -- ${pkgs.shadow}/bin/login -p ${kmsAutologinArg k v}'';

  # getty options submodule
  gettyOpts =
    { name, config, ... }:
    {
      options = {
        autologinUser = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Username of the account that will be automatically logged in at the console.
            If unspecified, a login prompt is shown as usual.
          '';
        };

        loginProgram = mkOption {
          type = types.path;
          default = "${pkgs.shadow}/bin/login";
          defaultText = lib.literalExpression ''"''${pkgs.shadow}/bin/login"'';
          description = ''
            Path to the login binary executed by agetty.
          '';
        };

        loginOptions = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Template for arguments to be passed to
            <citerefentry><refentrytitle>login</refentrytitle>
            <manvolnum>1</manvolnum></citerefentry>.

            See <citerefentry><refentrytitle>agetty</refentrytitle>
            <manvolnum>1</manvolnum></citerefentry> for details,
            including security considerations.  If unspecified, agetty
            will not be invoked with a <option>--login-options</option>
            option.
          '';
          example = "-h darkstar -- \\u";
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            Additional arguments passed to agetty.
          '';
          example = [ "--nohostname" ];
        };
      };
    };

  # kmscon options submodule
  kmsconOpts =
    { name, config, ... }:
    {
      options = {
        hwaccel = mkOption {
          description = "Whether to use 3D hardware acceleration to render the console.";
          type = types.bool;
          default = false;
        };

        drm = mkOption {
          description = "Whether to use DRM to render the console.";
          type = types.bool;
          default = true;
        };

        extraConfig = mkOption {
          description = "Extra contents of the kmscon.conf file.";
          type = types.lines;
          default = "";
          example = "font-size=14";
        };

        extraOptions = mkOption {
          description = "Extra flags to pass to kmscon.";
          type = types.separatedString " ";
          default = "";
          example = "--term xterm-256color";
        };

        autologinUser = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Username of the account that will be automatically logged in at the console.
                    If unspecified, a login prompt is shown as usual.
          '';
        };
      };
      config = {
        extraConfig = (
          (lib.optionalString config.drm ''
            drm
          '')
          + (lib.optionalString config.hwaccel ''
            hwaccel
          '')
        );
      };
    };

  # top submodule mapped options ("tty1" => vtOpts)
  vtOpts =
    { name, config, ... }:
    {
      options = {
        ttyType = mkOption {
          type = types.enum [
            "kmscon"
            "getty"
          ];
          default = "getty";
        };
        kmscon = mkOption { type = (types.submoduleWith { modules = [ kmsconOpts ]; }); };
        getty = mkOption { type = (types.submoduleWith { modules = [ gettyOpts ]; }); };
      };
      config = {
        kmscon = lib.mkDefault name;
        getty = lib.mkDefault name;
      };
    };
in
{
  options = {
    # TODO: block touching the ReservedVT (6)
    # TODO: we don't support more than the logind autovt count...
    services.ttys = {
      unsafe_enable = mkEnableOption {
        default = false;
        description = ''
          experimental! enable at your own risk.
          remember {systemd.logind.reservedVT} is the reserved VT
          which should be running normally safe getty
        '';
      };
      vts = mkOption {
        type = types.nullOr (types.attrsOf (types.submodule vtOpts));
        default = (lib.mapAttrs (k: { "${k}".ttyName = "getty"; }) allTTYs);
      };
    };
  };

  config = mkIf enabled {
    systemd.units = (
      # first "suppress" the autovt@ service without completely suppressing it
      # Our getty module sets ExecStart which sets an override for autovt/getty that infects us, even
      # if we run a different service/unit.
      # So, just blank it out... :D.
      {
        "autovt@.service" = lib.mkForce { };
      }
      # then map our configured/default VTs
      // (lib.mapAttrs'
        # for each VT, presume the service we setup below and alias it to provide autovt@${tty}.service
        # (TODO: not really sure how this suppresses getty which presumably also is still bound to autovt@.service.....
        # maybe it's just that our units are more specific that the templatized autovt@.service)
        (k: v: {
          name = "${v.ttyType}vt@${k}.service";
          value = {
            aliases = [ "autovt@${k}.service" ];
          };
        })
        cfg.vts
      )
    );

    systemd.services = (
      lib.mapAttrs'
        # huh, then I guess override them?
        # then just establish our "gettyvt" or "kmsconvt" (per the aliases above) service
        (
          k: v:
          let
            eso = cmd: {
              ExecStart = [
                ""
                cmd
              ];
            };
          in
          {
            name = (lib.traceVal "${v.ttyType}vt@${k}");
            value = {
              serviceConfig = lib.mkMerge [
                (lib.mkIf (v.ttyType == "kmscon") (eso (kmsconCmd k v.kmscon)))
                (lib.mkIf (v.ttyType == "getty") (eso (gettyCmd k v.getty autovtGettyArgs)))
              ];
            };
          }
        )
        cfg.vts
    );
    # TODO: convert to assert?
    # hardware.graphics.enable = mkIf cfg.hwRender true;
  };
}
