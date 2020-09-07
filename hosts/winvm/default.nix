{ pkgs, inputs, impureMode ? false }:

let
  wfvm = (import "${inputs.wfvm}/wfvm/default.nix" { inherit pkgs; });
in
wfvm.makeWindowsImage {
  # Build install script & skip building iso
  #inherit impureMode;

  # Custom base iso
  # windowsImage = pkgs.fetchurl {
  #   url = "https://software-download.microsoft.com/download/sg/17763.107.101029-1455.rs5_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso";
  #   sha256 = "668fe1af70c2f7416328aee3a0bb066b12dc6bbd2576f40f812b95741e18bc3a";
  # };

  # impureShellCommands = [
  #   "powershell.exe echo Hello"
  # ];

  # User accounts
  users = {
    anon = {
      password = "1234";
      # description = "Default user";
      # displayName = "Display name";
      groups = [
        "Administrators"
      ];
    };
  };

  # Auto login
  # defaultUser = "artiq";

  # fullName = "M-Labs";
  # organization = "m-labs";
  # administratorPassword = "12345";

  # Imperative installation commands, to be installed incrementally
  installCommands = with wfvm.layers; [];

  # services = {
  #   # Enable remote management
  #   WinRm = {
  #     Status = "Running";
  #     PassThru = true;
  #   };
  # };

  # License key
  # productKey = "iboughtthisone";

  # Locales
  uiLanguage = "en-US";
  inputLocale = "en-US";
  userLocale = "en-US";
  systemLocale = "en-US";

}
