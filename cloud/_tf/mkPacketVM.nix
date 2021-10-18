packet_config: plan: facility: instance_name:

{
  terraform = {
    required_providers = {
      metal = {
        source = "equinix/metal";
        version = "3.2.0";
      };
    };
  };
  # variable.termtime.description = "termination time for devices";
  provider = {
    metal = [{
      # auth_token # from env
      # = packet_config.auth_token; # TODO: token or token__file???
    }];
  };
  resource = {
    metal_spot_market_request."${instance_name}" = {
      project_id = packet_config.project_id;
      max_bid_price = "0.5"; # ==> crashes nix
      facilities = [ facility ];
      devices_min = 1;
      devices_max = 1;
      wait_for_devices = true;
      instance_parameters = {
        hostname = instance_name;
        plan = plan;
        operating_system = "ubuntu_18_04";
        billing_cycle = "hourly";
        #termination_time = "\${vars.termtime}";
      };
    };
  };
}


