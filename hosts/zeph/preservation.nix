{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:

{
  imports = [
    inputs.preservation.nixosModules.default
  ];

  config = {
    preservation = {
      # the module doesn't do anything unless it is enabled
      enable = true;

      # we use /persistent/preservation so that /persistent can be used to stash
      # other stuff without making a mess
      preserveAt."/persistent/preservation" = {

        #   # preserve system directories
        directories = [
          #     "/etc/secureboot"
          #     "/var/lib/bluetooth"
          #     "/var/lib/fprint"
          #     "/var/lib/fwupd"
          #     "/var/lib/libvirt"
          #     "/var/lib/power-profiles-daemon"
          #     "/var/lib/systemd/coredump"
          #     "/var/lib/systemd/rfkill"
          #     "/var/lib/systemd/timers"
          #     "/var/log"
          #     {
          #       directory = "/var/lib/nixos";
          #       inInitrd = true;
          #     }
          "/etc/NetworkManager/system-connections"
        ];

        #   # preserve system files
        files = [
          #     {
          #       file = "/etc/machine-id";
          #       inInitrd = true;
          #     }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
            configureParent = true;
          }
          #     # "/var/lib/usbguard/rules.conf"

          #     # creates a symlink on the volatile root
          #     # creates an empty directory on the persistent volume, i.e. /persistent/var/lib/systemd
          #     # does not create an empty file at the symlink's target (would require `createLinkTarget = true`)
          #     {
          #       file = "/var/lib/systemd/random-seed";
          #       how = "symlink";
          #       inInitrd = true;
          #       configureParent = true;
          #     }
        ];

        # preserve user-specific files, implies ownership
        users = {
          "cole" = {
            commonMountOptions = [
              "x-gvfs-hide"
            ];
            directories = [
              # imperative/stateful config
              ".android"

              # TODO: "nonvolatile" instead of "persistent"
              # for things we need, but don't want to version

              ".config/Ledger Live"

              # gamesaves (that indeed don't have steam cloud files inside)
              ".local/share/AlexanderBruce" # Antichamber
              ".local/share/FEZ"

              ".local/share/SyncThingData"

              ".mozilla"

              {
                directory = ".ssh";
                mode = "0700";
              }

              "code"
              "desktop"
              "documents"

              "work/code"
              "work/documents"
            ];
            # files = [
            #   ".histfile"
            # ];
          };
          # root = {
          #   # specify user home when it is not `/home/${user}`
          #   home = "/root";
          #   directories = [
          #     {
          #       directory = ".ssh";
          #       mode = "0700";
          #     }
          #   ];
          # };
        };
      };
    };

    # Create some directories with custom permissions.
    #
    # In this configuration the path `/home/butz/.local` is not an immediate parent
    # of any persisted file, so it would be created with the systemd-tmpfiles default
    # ownership `root:root` and mode `0755`. This would mean that the user `butz`
    # could not create other files or directories inside `/home/butz/.local`.
    #
    # Therefore systemd-tmpfiles is used to prepare such directories with
    # appropriate permissions.
    #
    # Note that immediate parent directories of persisted files can also be
    # configured with ownership and permissions from the `parent` settings if
    # `configureParent = true` is set for the file.
    systemd.tmpfiles.settings.preservation = {
      "/home/cole/.config".d = {
        user = "cole";
        group = "cole";
        mode = "0755";
      };
      "/home/cole/.local".d = {
        user = "cole";
        group = "cole";
        mode = "0755";
      };
      "/home/cole/.local/share".d = {
        user = "cole";
        group = "cole";
        mode = "0755";
      };
      "/home/cole/.local/state".d = {
        user = "cole";
        group = "cole";
        mode = "0755";
      };
      "/home/cole/work".d = {
        user = "cole";
        group = "cole";
        mode = "0755";
      };
    };
  };
}
