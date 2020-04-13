{
  config = {
    services.pcscd.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
      pinentryFlavor = "qt";
    };
    programs.ssh.startAgent = false;
  };
}
