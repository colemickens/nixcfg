{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./home-assistant ];

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "deadbeef";
  boot.initrd.kernelModules = [ "hv_vmbus" "hv_storvsc" ];

  # https://askubuntu.com/a/399960
  boot.kernelParams = [ "video=hyperv_fb:800x600" ];

  # https://github.com/NixOS/nix/issues/421
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.nixPath = [ ];
  networking.hostName = "jeffhyper"; # Define your hostname.
  environment.systemPackages = with pkgs; [ file ripgrep tmux htop ];

  #
  # MISC SYSTEM CONFIG
  boot.tmpOnTmpfs = true;
  boot.cleanTmpDir = true;
  boot.kernel.sysctl = {
    "fs.file-max" = 100000;
    "fs.inotify.max_user_instances" = 256;
    "fs.inotify.max_user_watches" = 500000;
  };
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago";
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;

  #
  # NETWORK
  networking.wireless.enable = false;
  networking.interfaces.eth0.ipv4.addresses = [{
    address = "192.168.1.24";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 ];
  };

  #
  # SSHD CONFIG
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "no";

  #
  # USER
  users.extraUsers."jeff" = {
    isNormalUser = true;
    home = "/home/jeff";
    description = "Jeff Mickens";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== (none)"
    ];
    hashedPassword = # nix run -f ~/code/nixpkgs mkpasswd --command mkpasswd -m sha-512
      "$6$J7DyTD7T1AgB$2diShcxoHT06bPmZ4IdAn8LdWIW0TfOvry7ODBEVd/lj9D6Ziu1u/DXSl.mJknvdLABp5h8TDW14Ne8ut6QtO1";
    shell = "${pkgs.bash}/bin/bash";
    extraGroups = [ "wheel" ];
    uid = 1000;
  };
  nix.trustedUsers = [ "jeff" ];

  #
  # OTHER
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  system.stateVersion = "19.09";
}

