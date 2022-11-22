{ pkgs, tfutil, ... }:

let
  tf_equinix_version = "1.10.0";

  lib = pkgs.lib;
  mkVm = packet_config: instance_name: vm: {
    resource.equinix_metal_spot_market_request."${instance_name}" = {
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
    dc11 = "dc11";
  };

  plans = {
    c2_medium_arm = "c2.medium.arm";
    c3_large_arm = "c3.large.arm";

    c2_medium_x86 = "c2.medium.x86";
    c3_medium_x86 = "c3.medium.x86";
    m3_large_x86 = "m3.large.x86";
    s3_xlarge_x86 = "s3.xlarge.x86";
    n2_xlarge_x86 = "n2.xlarge.x86";
    n3_xlarge_x86 = "n3.xlarge.x86";
  };
  
  os = {
    nixos_22_05 = "nixos_22_05";
  };

  tfplan = packet_config: vms:
    mergeListToAttrs ([]
      ++ (lib.mapAttrsToList (mkVm packet_config) vms)
      ++ [{
        terraform = {
          required_providers = {
            "equinix" = {
              source = "equinix/equinix";
              version = tf_equinix_version;
            };
          };
        };
        # TODO: finish plumbing this through:
        # variable.termtime.description = "termination time for devices";
        provider = {
          equinix = [{
            # auth_token # METAL_AUTH_TOKEN is set by 'tf-apply' wrapper script
          }];
        };
      }]
  );
}
