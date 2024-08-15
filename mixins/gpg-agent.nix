{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # this is just so that non-GUI systems don't end up pulling in
  # gui stuff. My GUI configuration overrides the pinentry HM config elsewhere.
  # -- from `profiles-gui.nix:
  #  # I use `wayprompt` to not pull in qt/gtk:
  #  gpg-agent.pinentryBinary =
  #    let
  #      wayprompt = "${inputs.nixpkgs-wayland.outputs.packages.${pkgs.stdenv.hostPlatform.system}.wayprompt}";
  #    in
  #    "${wayprompt}/bin/pinentry-wayprompt";

  pinentryProgram = null;
in
{
  config = {
    # try to enable gnupg's udev rules
    # to allow it to do ccid stuffs
    hardware.gpgSmartcards.enable = true;

    # we're using ledger->openpgp_xl as a smartcard
    # well, not anymore, but it can't hurt, I do
    # use the Ledger still, so still want the udev rules
    hardware.ledger.enable = true;

    # pull in yubikey udev rules too
    # TODO: hardware.gpgSmartcards should maybe cover this?
    services.udev.packages = [ pkgs.yubikey-personalization ];

    # using this requires use of `disable-ccid` in scdaemon.conf!
    services.pcscd.enable = false;

    home-manager.users.cole =
      { pkgs, ... }@hm:
      {
        programs.gpg.enable = true;
        programs.gpg.homedir = "${hm.config.xdg.dataHome}/gnupg";
        home.file."${hm.config.programs.gpg.homedir}/.keep".text = "";
        home.packages = [
          pkgs.yubikey-personalization
        ] ++ (lib.optionals (pkgs.stdenv.hostPlatform.system == pkgs.stdenv.buildPlatform.system) [
          pkgs.yubikey-manager
          pkgs.yubico-piv-tool
        ]);

        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableExtraSocket = true;
          extraConfig = ''
            # enable-ssh-support
            allow-preset-passphrase
          '';
          # pinentryFlavor = "gnome3";
          # pinentryFlavor = null;
          pinentryBinary = lib.mkDefault pinentryProgram;
          defaultCacheTtl = 34560000;
          defaultCacheTtlSsh = 34560000;
          maxCacheTtl = 34560000;
          maxCacheTtlSsh = 34560000;
        };
      };
  };
}
