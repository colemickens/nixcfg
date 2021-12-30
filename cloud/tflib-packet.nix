{ pkgs, tfutil, ... }:

let
  lib = pkgs.lib;
  mkVm = packet_config: instance_name: vm: {
    resource.metal_spot_market_request."${instance_name}" = {
      project_id = packet_config.project_id;
      max_bid_price = vm.bid;
      facilities = [ vm.loc ]; # https://github.com/equinix/terraform-provider-metal/issues/196
      #metro = vm.loc;
      devices_min = 1;
      devices_max = 1;
      wait_for_devices = true;
      instance_parameters = (
        {
          hostname = instance_name;
          plan = vm.plan;
          billing_cycle = "hourly";
          #termination_time = "\${vars.termtime}";
        } // (if !(builtins.hasAttr "payload" vm) then {} else {
          userdata = tfutil.userdata_str vm.payload;
        }) // (if !(builtins.hasAttr "ipxe_script_url" vm) then {
          operating_system = vm.os;
        } else {
          operating_system = "custom_ipxe";
          ipxe_script_url = vm.ipxe_script_url;
        })
      );
    };
  };

  mergeListToAttrs = lib.fold (c: el: lib.recursiveUpdate el c) {};
in {
  metros = {
    dc10 = "dc10";
  };

  plans = {
    c3_large_arm = "c3.large.arm";
  };
  
  os = {
    nixos_21_05 = "nixos_21_05";
  };

  tfplan = packet_config: vms:
    mergeListToAttrs ([]
      ++ (lib.mapAttrsToList (mkVm packet_config) vms)
      ++ [{
        terraform = {
          required_providers = {
            metal = {
              source = "equinix/metal";
              version = "3.2.0";
            };
          };
        };
        # TODO: finish plumbing this through:
        # variable.termtime.description = "termination time for devices";
        provider = {
          metal = [{
            # auth_token # METAL_AUTH_TOKEN is set by 'tf-apply' wrapper script
          }];
        };
      }]
  );
}
