{ pkgs, lib, config, ... }:

# TODO:
# - finish
# - completely remove/archive dotfiles and point to here
# - split into gui/non-gui

let
  home-manager = import ../imports/home-manager;

  crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
  crtFile = pkgs.copyPathToStore crtFilePath;
in
{
  imports = [
    "${home-manager}/nixos"
  ];

  config = {
    users.extraGroups."cole".gid = 1000;
    users.extraUsers."cole" = {
      isNormalUser = true;
      home = "/home/cole";
      description = "Cole Mickens";
      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== (none)"];
      #mkpasswd -m sha-512
      hashedPassword = "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
      shell = "${pkgs.fish}/bin/fish";
      extraGroups = [ "wheel" "networkmanager" "kvm" "libvirtd" "docker" "transmission" "audio" "video" "sway" "sound" "pulse" "input" "render" "dialout" ];
      uid = 1000;
      group = "cole";
    };
    nix.trustedUsers = [ "cole" ];

    # <mitmproxy>
    security.pki.certificateFiles =
      if (lib.pathExists "${crtFilePath}")
        then [ "${crtFile}" ]
        else [];
    # </mitmproxy>

    # HM: ca.desrt.dconf error:
    services.dbus.packages = with pkgs; [ gnome3.dconf ];

    home-manager.useGlobalPkgs = true;
    home-manager.users.cole = { pkgs, ... }: {
      home.stateVersion = "20.03";
      home.sessionVariables = {
        EDITOR = "neovim";
        TERMINAL = "termite";
      };
      home.file = {
        ".gdbinit".source = ../dotfiles/gdbinit;
        ".local/bin/gpgssh.sh".source = ../dotfiles/local/bin/gpgssh.sh;
        ".local/bin/megadl.sh".source = ../dotfiles/local/bin/megadl.sh;
        ".local/bin/rdpsly.sh".source = ../dotfiles/local/bin/rdpsly.sh;
      };
      xdg.enable = true;
      xdg.configFile = {
        "gopass/config.yml".source = ../dotfiles/config/gopass/config.yml;
      };
      programs = {
        bash.enable = false;
        zsh.enable = false;
        fish.enable = true;
        home-manager.enable = true;
        git = {
          enable = true;
          package = pkgs.gitAndTools.gitFull; # to get send-email
          # root key = "8A94ED58A476A13AE0D6E85E9758078DE5308308";
          # signing key = "8329C1934DA5D818AE35F174B475C2955744A019";
          signing.key = "8329C1934DA5D818AE35F174B475C2955744A019";
          signing.signByDefault = true;
          userEmail = "cole.mickens@gmail.com";
          userName = "Cole Mickens";
        };
        gpg.enable = true;
        htop.enable = true;
        neovim = {
          enable = true;
        };
      };
      services = {
        gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableExtraSocket = true;
        };
      };
      wayland.windowManager.sway = {
        enable = true;
      };
      home.packages = with pkgs; [
        # everything non-gui goes here that I use
        cachix
        qemu
        wget curl
        # neovim vim # HM modules
        ripgrep jq fzf tmux
        wget curl stow ncdu tree
        git-crypt gopass gnupg
        openssh autossh mosh sshuttle
        gitAndTools.gitFull gitAndTools.hub gist tig
        cvs mercurial subversion # pjiul
        
        mitmproxy

        htop iotop which binutils.bintools
        p7zip unrar parallel unzip xz zip

        nix-prefetch nixpkgs-fmt nixpkgs-review

        ffmpeg linuxPackages.cpupower
        sshfs cifs-utils ms-sys ntfs3g
        imgurbash2 spotify-tui

        gdb lldb file gptfdisk
        parted psmisc wipe
        
        aria2 megatools youtube-dl plowshare
        
        # eh?
        # TODO: ? xdg_utils
      ] ++ lib.optionals (config.system == "x86_64-linux")
        [ 
          esphome
        ];
    };
  };
}
