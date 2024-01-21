{ cylib, lib, ... }:

let
  cylib = {
    gen = {
      sops-nix = secretNames: {
        age.key = "/tmp/cyclops/agekey.txt";
        secrets = lib.genAttrs secretNames { };
        #     age.key = "/tmp/cyclops/age_key";
        #     secrets = {
        #       "id_rsa" = {
        #         sopsFile = ./.cyclops/secrets/id_rsa_colebot;
        #       };
        #       "equinix_api_key" = {
        #         sopsFile = ./.cyclops/secrets/equinix_api_key_colemickens;
        #       };
        #     };
        #   };
      };
    };
  };
  _cache_cachix = {
    type = "cachix"; # enum of [update,cachix,r2nix]
    paths = [ "ciJobs.x86_64-linux.default" ];
    cache = "colemickens";
    keyPath = "/run/secrets/foobar";
  };
  _cache_host = {
    type = "copytohost"; # enum of [update,cachix,r2nix]
    paths = [ "ciJobs.x86_64-linux.default" ];
  };
  # _cache = {
  #   type = "r2"; # enum of [update,cachix,r2nix]
  #   paths = [ "ciJobs.x86_64-linux.default" ];
  #   account_id = "ooooo";
  #   keyPath = "/run/secrets/foobar";
  # };
in
{
  sources = ./grm.toml;
  shareKey = ./...; # used for sharing across builder overlays? TODO??
  hmConfig = {
    home-manager.users."colebot" = { ... }: {
      git = {
        user.name = "colebot202305";
        user.email = "cole.mickens+colebot@gmail.com";
      };
      # nix probably don't bother with since we pass it around to builders anyway?
      sops-nix = (cylib.gen.sops-nix [
        "id_rsa_colebot202305"
        "equinix_apikey_colemickens202305"
        "cachix_signing_key_colemickens"
      ]);
    };
  };
  buildsets = {
    "x86_64-linux" = [
      "ciJobs.x86_64-linux.default"
    ];
  };
  tags = [ "update" ];
  conflict = [ "update" ];
  actions = [
    {
      name = "update-inputs";
      type = "update-flake-overrides";
      # TODO: maybe there's a better key to select out of grm, or use grm as a lib?
      srcDir = "/nixcfg/main";
      overrides = {
        "cmpkgs" = "/nixpkgs/cmpkgs"; # TODO append suffix?
        "home-manager" = "/home-manager/cmhm"; # TODO: same
      };
    }
    {
      name = "update-pkgs";
      type = "update-pkgs";
      # TODO: maybe there's a better key to select out of grm, or use grm as a lib?
      srcDir = "/nixcfg/main";
      extraRunSteps = [
        [ "main" "pkgup" ]
      ];
    }
    {
      type = "git-push";
      dirs = [
        "/nixpkgs/cmpkgs"
        "/home-manager/cmhm"
        "/nixcfg/main"
      ];
    }
  ];
}

