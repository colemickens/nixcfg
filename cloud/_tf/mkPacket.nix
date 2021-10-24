{ pkgs, ... }:

packet_config: vms:

let
  lib = pkgs.lib;
  mkVm = instance_name: vm: {
    resource.metal_spot_market_request."${instance_name}" = {
      project_id = packet_config.project_id;
      max_bid_price = vm.bid;
      #facilities = [ location ]; # https://github.com/equinix/terraform-provider-metal/issues/196
      metro = vm.loc;
      devices_min = 1;
      devices_max = 1;
      wait_for_devices = true;
      instance_parameters = {
        hostname = instance_name;
        plan = vm.plan;
        operating_system = "ubuntu_18_04";
        billing_cycle = "hourly";
        userdata = "\${templatefile(\"${vm.userdata}\", ${vm.uservars})}";
        #termination_time = "\${vars.termtime}";
      };
    };
  };
  mergeListToAttrs = lib.fold (c: el: lib.recursiveUpdate el c) {};
in mergeListToAttrs ([]
  ++ (lib.mapAttrsToList mkVm vms)
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
)
