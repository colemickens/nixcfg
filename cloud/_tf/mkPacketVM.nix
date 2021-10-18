packet_config: plan: metro: instance_name:

{
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
  resource = {
    metal_spot_market_request."${instance_name}" = {
      project_id = packet_config.project_id;
      max_bid_price = "0.5";
      #facilities = [ facility ]; # https://github.com/equinix/terraform-provider-metal/issues/196
      metro = metro;
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


