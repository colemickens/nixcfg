{
  config,
  lib,
  pkgs,
  hosts,
  ...
}:

{
  /*
    environment.systemPackages = let
    # Replace a file(tree) with an ipfs symlink
    toipfs = pkgs.writeScriptBin "toipfs" ''
      #!${pkgs.execline}/bin/execlineb -WS1
      backtick -n -I dir { dirname $1 }
      backtick -n -I file { basename $1 }
      importas -i dir dir
      cd $dir
      importas -i file file
      if { touch .ipfs.$file }
      if { rm .ipfs.$file }
      backtick -n -i hash {
        pipeline { ${pkgs.ipfs}/bin/ipfs add -qr $file }
        tail -n 1
      }
      importas -i hash hash
      if { touch ${cfg.ipfsMountDir}/$hash }
      if -n {
        if { rm -rf $file } ln -sf ${cfg.ipfsMountDir}/$hash $file
      }
      foreground { ln -sf ${cfg.ipfsMountDir}/$hash /tmp/toipfs.$file }
      foreground { echo Saved as /tmp/toipfs.$file }
      exit 1
    '';

    # Abuse CoW to realise an ipfs symlink
    fromipfs = pkgs.writeScriptBin "fromipfs" ''
      #!${pkgs.execline}/bin/execlineb -WS1
      backtick -n -i hash {
        pipeline { realpath $1 }
        xargs basename
      }
      importas -i hash hash
      if { touch ${cfg.ipfsMountDir}/$hash }
      if { rm -f $1 }
      cp -Lr --reflink=auto ${cfg.ipfsMountDir}/$hash $1
    '';

    # Wrap brig to use the http api (breaks with unix sockets)
    brig = let
      ipfs-api = pkgs.writeText "ipfs-api" config.services.ipfs.apiAddress;
      api-addr = config.services.ipfs.apiAddress;
    in pkgs.writeScriptBin "brig" ''
      #!${pkgs.execline}/bin/execlineb -Ws0
      export NIX_REDIRECTS /var/lib/ipfs/api=${ipfs-api}
      ${pkgs.utillinux}/bin/unshare -rm
      if { mount -t tmpfs -o size=1K tmpfs /var/empty }
      if { redirfd -w 1 /var/empty/api echo "${api-addr}" }
      if { mount --bind /var/empty/api /var/lib/ipfs/api }
      if { umount /var/empty }
      ${pkgs.brig}/bin/brig $@
    '';
    in [ brig toipfs fromipfs ];
  */

  services.ipfs = {
    enable = true;
    startWhenNeeded = true;
    enableGC = false;
    emptyRepo = true;
    autoMount = true;
    extraConfig = {
      DataStore = {
        StorageMax = "512GB";
      };
      Discovery = {
        MDNS.Enabled = true;
        #Swarm.AddrFilters = null;
      };
      Experimental.FilestoreEnabled = true;
    };
    extraFlags = [ "--enable-pubsub-experiment" ];
    serviceFdlimit = 999999;
    apiAddress = "/ip4/0.0.0.0/tcp/5001";
    gatewayAddress = "/ip4/0.0.0.0/tcp/4501";
  };

  systemd.services.ipfs =
    builtins.trace "${config.networking.hostName} - ipfs config permissions still broken"
      {
        serviceConfig.ExecStartPost = "${pkgs.coreutils}/bin/chmod g+r /var/lib/ipfs/config";
        wantedBy = [ "local-fs.target" ];
      };

  security.wrappers.ipfs = {
    source = "${pkgs.ipfs}/bin/ipfs";
    owner = config.services.ipfs.user;
    group = config.services.ipfs.group;
    setuid = true;
  };
}
