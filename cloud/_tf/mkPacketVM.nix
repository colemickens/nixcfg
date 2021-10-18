let
  foo = "bar";
in { oracle_config, instance_name, ... }: let
  iname = instance_name;
  shape = "VM.Standard.A1.Flex"; # A1....
  shapecfg = {
    ocpus = 8;
    mem = 24;
  };
  sshpubkey = "";
  userdata = "";
  source_id = ""; # image_ocid for reigon?

  compartment_ocid = oracle_config.compartment_ocid;
in {
  /*(
terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
      # version = "1.0.0"
    }
  }
}

# Configure the Equinix Metal Provider.
provider "metal" {
  auth_token = var.auth_token
}

data "metal_project" "project" {
  name = "My Project"
}

# If you want to create a fresh project, you can create one with metal_project
#
# resource "metal_project" "cool_project" {
#   name           = "My First Terraform Project"
# }

# Create a device and add it to tf_project_1
resource "metal_device" "web1" {
  hostname         = "web1"
  plan             = "c3.medium.x86"
  metro            = "ny"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = data.metal_project.project.id

  # if you created a project with the metal_project resource, refer to its ID
  # project_id       = metal_project.cool_project.id

  # You can find the ID of your project in the URL of the Equinix Metal console.
  # For example, if you see your devices listed at
  # https://console.equinix.com/projects/352000fb2-ee46-4673-93a8-de2c2bdba33b
  # .. then 352000fb2-ee46-4673-93a8-de2c2bdba33b is your project ID.
}
  */
  provider = {
    oci = [{
      fingerprint = oracle_config.fingerprint;
      private_key_path = oracle_config.private_key_path;
      region = oracle_config.region;
      tenancy_ocid = oracle_config.tenancy_ocid;
      user_ocid = oracle_config.user_ocid;
    }];
  };
  resource = rec {
    oci_core_default_route_table."default_route_table" = [{
      display_name = "DefaultRouteTable";
      manage_default_resource_id = "${oci_core_vcn.test_vcn.default_route_table_id}";
      route_rules = [
        {
          destination = "0.0.0.0/0";
          destination_type = "CIDR_BLOCK";
          network_entity_id = "${oci_core_internet_gateway.test_internet_gateway.id}";
        }
      ];
    }];
    oci_core_instance."test_instance" = [{
      availability_domain = "${data.oci_identity_availability_domain.ad.name}";
      compartment_id = compartment_ocid;
      count = "${var.num_instances}";
      create_vnic_details = [
        {
          assign_private_dns_record = true;
          assign_public_ip = true;
          display_name = "Primaryvnic";
          hostname_label = "exampleinstance${count.index}";
          subnet_id = "${oci_core_subnet.test_subnet.id}";
        }
      ];
      display_name = "TestInstance${count.index}";
      metadata = {
        ssh_authorized_keys = sshpubkey;
        user_data = userdata;
      };
      # preemptible_instance_config = [
      #   {
      #     preemption_action = [
      #       {
      #         preserve_boot_volume = false;
      #         type = "TERMINATE";
      #       }
      #     ];
      #   }
      # ];
      shape = shape;
      shape_config = [{
        memory_in_gbs = shapecfg.mem; # "${var.instance_shape_config_memory_in_gbs}";
        ocpus = shapecfg.ocpus; # = "${var.instance_ocpus}";
      }];
      source_details = [{
        source_id = source_id;
        source_type = "image";
      }];
      timeouts = [{
        create = "60m";
      }];
    }];
    oci_core_internet_gateway."test_internet_gateway" = [{
      compartment_id = compartment_ocid;
      display_name = "TestInternetGateway";
      vcn_id = "${oci_core_vcn.test_vcn.id}";
    }];
    oci_core_subnet."test_subnet" = [{
      availability_domain = "${data.oci_identity_availability_domain.ad.name}";
      cidr_block = "10.1.20.0/24";
      compartment_id = compartment_ocid;
      dhcp_options_id = "${oci_core_vcn.test_vcn.default_dhcp_options_id}";
      display_name = "TestSubnet";
      dns_label = "testsubnet";
      route_table_id = "${oci_core_vcn.test_vcn.default_route_table_id}";
      security_list_ids = [
        "${oci_core_vcn.test_vcn.default_security_list_id}"
      ];
      vcn_id = "${oci_core_vcn.test_vcn.id}";
    }];
    oci_core_vcn."test_vcn" = [{
      cidr_block = "10.1.0.0/16";
      compartment_id = compartment_ocid;
      display_name = "TestVcn";
      dns_label = "testvcn";
    }];
    # oci_core_volume."test_block_volume_paravirtualized" = [{
    #   availability_domain = "${data.oci_identity_availability_domain.ad.name}";
    #   compartment_id = compartment_ocid;
    #   count = "${var.num_instances * var.num_paravirtualized_volumes_per_instance}";
    #   display_name = "TestBlockParavirtualized${count.index}";
    #   size_in_gbs = "${var.db_size}";
    # }];
    # oci_core_volume_attachment."test_block_volume_attach_paravirtualized" = [{
    #   attachment_type = "paravirtualized";
    #   count = "${var.num_instances * var.num_paravirtualized_volumes_per_instance}";
    #   instance_id = "${oci_core_instance.test_instance[floor(count.index / var.num_paravirtualized_volumes_per_instance)].id}";
    #   volume_id = "${oci_core_volume.test_block_volume_paravirtualized[count.index].id}";
    # }];
    # oci_core_volume_backup_policy_assignment."policy" = [{
    #   asset_id = "${oci_core_instance.test_instance[count.index].boot_volume_id}";
    #   count = "${var.num_instances}";
    #   policy_id = "${data.oci_core_volume_backup_policies.test_predefined_volume_backup_policies.volume_backup_policies[0].id}";
    # }];
  };
}


