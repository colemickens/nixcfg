{
  services = {
    transmission = {
      enable = true;
      settings = {
        rpc-whitelist = "127.0.0.1,192.168.*.*";
        umask = 2;
      };
    };
  };
}

