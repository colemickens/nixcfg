{
  description = "colemickens - nixos configs, custom packges, misc";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate";
    }; # TODO: boo name! "libaggregate"?

    nix = {
      url = "github:nixos/nix?ref=2.24.9";
    };
    nixpkgs-stable = {
      url = "github:nixos/nixpkgs?ref=nixos-24.05";
    }; # any stable to use
    cmpkgs = {
      url = "github:colemickens/nixpkgs?ref=cmpkgs";
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs."nixpkgs".follows = "cmpkgs";
    };

    mobile-nixos-openstick = {
      url = "github:colemickens/mobile-nixos?ref=colemickens/openstick-aug2024";
      inputs."nixpkgs".follows = "cmpkgs";
    };

    # core system/inputs
    firefox-nightly = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    home-manager = {
      url = "github:colemickens/home-manager/cmhm";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix/master";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
    ucodenix.url = "github:e-tho/ucodenix";

    # devtools:
    crate2nix = {
      url = "github:kolloch/crate2nix";
      flake = false;
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs."nixpkgs".follows = "cmpkgs";
    }; # packet/terraform deployments
    fenix = {
      url = "github:nix-community/fenix";
      inputs."nixpkgs".follows = "cmpkgs";
    }; # used for nightly rust devtools
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    # also, there's crane, crates2nix, cargo2nix, ??
    helix = {
      url = "github:helix-editor/helix";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    jj = {
      url = "github:martinvonz/jj";
      inputs."flake-utils".follows = "flake-utils";
      # inputs."nixpkgs".follows = "cmpkgs";
    };
    # nix-eval-jobs = {
    #   url = "github:nix-community/nix-eval-jobs";
    #   # inputs."nixpkgs".follows = "cmpkgs";
    # };
    nix-update = {
      url = "github:Mic92/nix-update";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    nix-fast-build = {
      # url = "github:Mic92/nix-fast-build";
      url = "github:colemickens/nix-fast-build?ref=stdout-pipable";
      # inputs."nixpkgs".follows = "cmpkgs";
    };
    fast-flake-update = {
      url = "github:Mic92/fast-flake-update";
      inputs."nixpkgs".follows = "cmpkgs";
    };

    # zellij
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs."nixpkgs".follows = "cmpkgs";
    };

    # experimental/unused:
    nix-rice = {
      url = "github:colemickens/nix-rice";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    typhon = {
      url = "github:typhon-ci/typhon";
    };

    # wip replacement for nixpkgs->github-runners module
    nixos-github-actions = {
      url = "github:colemickens/nixos-github-actions";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
    };
    h96 = {
      url = "github:colemickens/h96-max-v58-nixos?ref=colemickens/main";
    };

    disko = {
      url = "github:nix-community/disko";
    };

    # for work
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1.tar.gz";
    };
  };

  # TODO: re-investigate nixConfig, maybe it will be less soul-crushing one day

  ## OUTPUTS ##################################################################
  outputs =
    inputs:
    let
      defaultSystems = [
        "x86_64-linux"
        "aarch64-linux"
        # "riscv64-linux"
      ];

      lib = inputs.lib-aggregate.lib;

      importPkgs =
        npkgs: extraCfg:
        (lib.genAttrs defaultSystems (
          system:
          import npkgs {
            inherit system;
            overlays = [ overlays.default ];
            config =
              let
                cfg = ({ allowAliases = false; } // extraCfg);
              in
              cfg;
          }
        ));
      pkgs = importPkgs inputs.cmpkgs { };
      pkgsStable = importPkgs inputs.nixpkgs-stable { };
      pkgsUnfree = importPkgs inputs.cmpkgs { allowUnfree = true; };

      mkSystem =
        n: v:
        (v.pkgs.lib.nixosSystem {
          modules =
            [ (v.path or (./hosts/${n}/configuration.nix)) ]
            ++ (
              if (!builtins.hasAttr "buildSys" v) then
                [ ]
              else
                [{ config.nixpkgs.buildPlatform.system = v.buildSys; }]
            );
          specialArgs = {
            inherit inputs;
          };
        });

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigsEx = {
        "x86_64-linux" = rec {
          # misc
          installer-standard = {
            pkgs = inputs.cmpkgs;
            path = ./images/installer/configuration-standard.nix;
          };
          installer-standard-aarch64 = {
            pkgs = inputs.cmpkgs;
            path = ./images/installer/configuration-standard-aarch64.nix;
            buildSys = "x86_64-linux";
          };

          # work cloud machine:
          ds-ws-colemickens = {
            pkgs = inputs.cmpkgs;
          };

          # actual machines:
          raisin = {
            pkgs = inputs.cmpkgs;
          };
          slynux = {
            pkgs = inputs.cmpkgs;
          };
          zeph = {
            pkgs = inputs.cmpkgs;
          };
          h96maxv58 = {
            pkgs = inputs.cmpkgs;
            path = ./hosts/h96maxv58/config-cross.nix;
            buildSys = "x86_64-linux";
          };

          # hetzner
          hcloud-amd64-dev1 = {
            pkgs = inputs.cmpkgs;
          };

          # TODO: decide what the future of this is, I like having a cross-compile targe
          # to tinker with, but the device is finnicky when I break it :|
          openstick = {
            pkgs = inputs.cmpkgs;
            path = ./hosts/openstick/cross.nix;
            buildSys = "x86_64-linux";
          };
          openstick2 = {
            pkgs = inputs.cmpkgs;
            path = ./hosts/openstick2/cross.nix;
            buildSys = "x86_64-linux";
          };
          rock5b = {
            pkgs = inputs.cmpkgs;
            path = ./hosts/rock5b/cross.nix;
            buildSys = "x86_64-linux";
          };
        };
        "aarch64-linux" = {
          h96maxv58-bootstrap = {
            pkgs = inputs.cmpkgs;
            path = ./hosts/h96maxv58/base.nix;
          };
          hcloud-arm64-dev1 = {
            pkgs = inputs.cmpkgs;
            # buildSys = "aarch64-linux";
          };
        };
      };
      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

      ## SPECIAL OUTPUTS ######################################################
      extra = {
        # must be manually included in ciAttrs
        x86_64-linux = {
          installer-standard = nixosConfigurations.installer-standard.config.system.build.isoImage;
          installer-standard-aarch64 =
            nixosConfigurations.installer-standard-aarch64.config.system.build.isoImage;

          openstick-abootimg = nixosConfigurations.openstick.config.mobile.outputs.android.android-abootimg;
          openstick-bootimg = nixosConfigurations.openstick.config.mobile.outputs.android.android-bootimg;
          openstick-rootfs = nixosConfigurations.openstick.config.mobile.outputs.generatedFilesystems.rootfs;

          rock5b-uboot = pkgsUnfree.x86_64-linux.pkgsCross.aarch64-multiplatform.ubootRock5ModelB;
          # rock5b-clearspi = https://dl.radxa.com/rock5/sw/images/others/zero.img.gz
          # rock5b-usbloader = https://dl.radxa.com/rock5/sw/images/loader/rk3588_spl_loader_v1.15.113.bin
          # rkdeveloptool rd 3 (reboot loader->maskrom)
          # flash FULL disk image to 0x0 in maskroom, or flash uboot to 0x40 in maskrom
        };
        aarch64-linux = {
          # build, boot to maskrom, flash whole uncompressed image to 0x0
          # ~/result-h96maxv58-image-script --build-memory 4096
          h96maxv58-image-builder = nixosConfigurations.h96maxv58-bootstrap.config.system.build.diskoImagesScript;
        };
        riscv64-linux = { };
      };

      ## NIXOS_MODULES # TODO: we don't use these? #############################
      nixosModules = {
        loginctl-linger = import ./modules/loginctl-linger.nix;
        ttys = import ./modules/ttys.nix;
        other-arch-vm = import ./modules/other-arch-vm.nix;
      };

      ## OVERLAY ###############################################################
      overlays = {
        default = (
          final: prev:
            # TODO: must be a better way?
            let
              __colemickens_nixcfg_pkgs = rec { };
            in
            __colemickens_nixcfg_pkgs // { inherit __colemickens_nixcfg_pkgs; }
        );
      };
    in
    lib.recursiveUpdate
      (rec {
        inherit
          nixosConfigs
          nixosConfigsEx
          nixosConfigurations
          toplevels
          ;
        inherit nixosModules overlays;
        inherit extra;
        inherit pkgs pkgsUnfree;
        ## HM ENVS #####################################################

        checks = {
          "aarch64-linux" = checks-native.aarch64-linux; # // checks-cross.aarch64-linux;
          "x86_64-linux" = checks-native.x86_64-linux // checks-cross.x86_64-linux;
        };

        checks-native = {
          "aarch64-linux" = {
            inherit (toplevels)
              # TODO(colemickens): complete/test this:
              # hcloud-arm64-dev-1
              ;
          };
          "x86_64-linux" = {
            inherit (toplevels)
              # normal x86_64-linux hosts
              raisin
              slynux
              zeph

              ds-ws-colemickens

              # misc native x86_64-linux
              installer-standard
              ;
          };
        };
        checks-cross = {
          "x86_64-linux" = {
            # cross-builds
            inherit (toplevels)
              h96maxv58
              openstick
              openstick2
              rock5b
              ;
            inherit (extra.x86_64-linux)
              openstick-abootimg
              openstick-bootimg
              # installer-standard-aarch64
              ;
          };
        };
      })
      (
        ## SYSTEM-SPECIFIC OUTPUTS ############################################
        lib.flake-utils.eachSystem defaultSystems (
          system:
          let
            mkShell = (
              name:
              import ./shells/${name}.nix {
                inherit inputs;
                pkgs = pkgs.${system};
              }
            );
            mkAppScript = (
              name: script: {
                type = "app";
                program = (pkgsStable.${system}.writeScript "${name}.sh" script).outPath;
              }
            );
          in
          rec {
            ## FORMATTER ######################################################
            formatter = pkgs.${system}.nixfmt-rfc-style;
            # formatter = pkgs.${system}.nixpkgs-fmt;
            # formatter = pkgs.${system}.nixfmt;
            # formatter = pkgs.${system}.alejandra;

            ## DEVSHELLS # some of 'em kinda compose ##########################
            devShells =
              (lib.flip lib.genAttrs mkShell [
                "ci"
                "dev"
                "uutils"
              ])
              // {
                default = devShells.ci;
              };

            ## TODO: coercion is still so silly, I should be able to put
            #        this at `outputs.homeConfigurations.x86_64-linux.env-ci`
            ## HM ENVS ########################################################

            homeConfigurations = (
              lib.genAttrs [ "env-ci" ] (
                h:
                inputs.home-manager.lib.homeManagerConfiguration {
                  pkgs = pkgs.${system};
                  modules = [ ./hm/${h}.nix ];
                  extraSpecialArgs = {
                    inherit inputs;
                  };
                }
              )
            );
            tophomes = (lib.mapAttrs (_: v: v.activation-script) homeConfigurations);

            ## APPS ###########################################################
            apps = lib.recursiveUpdate { } (
              let
                pkgs_ = pkgs.${system};
                tfout = import ./cloud {
                  inherit (inputs) terranix;
                  pkgs = pkgs_;
                };
                # installerIso = "${installer.isoImage}/iso/${installer.isoImage.isoName}";
              in
              {
                tf = {
                  type = "app";
                  program = tfout.tf.outPath;
                };
                tf-apply = {
                  type = "app";
                  program = tfout.apply.outPath;
                };
                tf-destroy = {
                  type = "app";
                  program = tfout.destroy.outPath;
                };

                # test-vm = {
                #   type = "app";
                #   program =
                #     (pkgs_.writeShellScript "test-vm" ''
                #       ${pkgs_.qemu}/bin/qemu-img create -f qcow2 /tmp/installer-vm-vdisk1 10G
                #       ${pkgs_.qemu}/bin/qemu-system-x86_64 -enable-kvm -nographic -m 2048 -boot d \
                #         -cdrom "${installerIso}" -hda /tmp/installer-vm-vdisk1 \
                #         -net user,hostfwd=tcp::10022-:22 -net nic
                #     '').outPath;
                # };

                # test-vm-gui = {
                #   type = "app";
                #   program =
                #     (pkgs_.writeShellScript "test-vm" ''
                #       ${pkgs_.qemu}/bin/qemu-img create -f qcow2 /tmp/installer-vm-vdisk1 10G
                #       ${pkgs_.qemu}/bin/qemu-system-x86_64 -enable-kvm -m 2048 -boot d \
                #         -cdrom "${installerIso}" -hda /tmp/installer-vm-vdisk1 \
                #         -net user,hostfwd=tcp::10022-:22 -net nic
                #     '').outPath;
                #   # TODO: add a variant that uses libvirt/virsh so we can test libvirt's funshit too
                # };
              }
            );

            ## PACKAGES #######################################################
            packages = (pkgs.${system}.__colemickens_nixcfg_pkgs);
            legacyPackages = pkgs;

            ## CI (sorta) #####################################################
            bundle = pkgs.${system}.buildEnv {
              name = "nixcfg-bundle";
              paths = builtins.attrValues checks;
            };

            ## CHECKS #########################################################
            # TODO: ask mic92 about this pattern, he doesn't just build .${system} even though these checks are persystem
            # TODO: also: we don't filter out toplevels... maybe toplevels.zeph should actually be toplevels.x86_64-linux.zeph ?
            # ??? revisit...
            # also, we're probably fine to remove ciAttrs now, nix-fast-build does recursive-ness, and ciAttrs doesn't even buildFarm anymore
            # TODO: we're still preferring local builds for somemthings, do we need to add back the wrapper?????
            # TODO: or look into the allowSubstitutesAlways new flag that lovesegfault commented about?
            checks =
              let
                c_packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") inputs.self.packages.${system};
                c_devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") inputs.self.devShells.${system};
              in
              c_packages // c_devShells;
          }
        )
      );
}
