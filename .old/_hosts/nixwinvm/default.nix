{ pkgs, inputs, ... }:

let
  wfvm = (import "${inputs.wfvm}/wfvm/default.nix" { inherit pkgs; });
  meson = {
    name = "meson";
    script =
      let
        mesonInst = pkgs.fetchurl {
          url = "https://github.com/mesonbuild/meson/releases/download/0.56.0/meson-0.56.0-64.msi";
          sha256 = "0n31l8l89jrjrbzbifxbjnr3g320ly9i4zfyqbfbbbblf4ygbhl3";
        };
      in
        # TODO: This doesn't work yet:
        ''
        ln -s ${mesonInst} meson.msi
        win-put meson.msi .
        echo Running Meson installer...
        win-exec 'msiexec /i .\meson.msi /qn'
        echo Meson installer finished
        '';
  };
  nixWindows = {
    name = "nix-windows";
    script =
      let
        nixwinsrc = pkgs.fetchFromGitHub {
          owner = "nix-windows";
          repo = "nix";
          rev = "ef641ddc2b098ff6268a8bb76de9012af0f715b9";
          sha256 = "0n31l8l89jrjrbzbifxbjnr3g320ly9i4zfyqbfbbbblf4ygbhl3";
        };
      in
        # TODO: This doesn't work yet:
        ''
        ln -s ${nixwinsrc} nixwinsrc
        win-put nixwinsrc .
        echo Running Nix-Windows build script...
        # TODO: which one?
        win-exec 'start /wait "" .\build-meson-64-gcc.cmd'
        echo Nix-Windows build finished
        '';
  };
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
    testuser = {
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
  installCommands = with wfvm.layers; [
    anaconda3 msys2 msvc msvc-ide-unbreak
    meson # fix above first
    #nixWindows # fix above first
  ];

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
