{ pkgs, tfutil, ... }:

# oracle_config: shape: image_name: instance_name:

let
  tf_oci_version = "4.74.0";

  lib = pkgs.lib;
  mapAttrs' = f: set:
    builtins.listToAttrs (map (attr: f attr set.${attr}) (builtins.attrNames set));
  mapAttrsToList = f: attrs:
    map (name: f name attrs.${name}) (builtins.attrNames attrs);

  shapes = {
    freetier_a1flex_mini = { name = "VM.Standard.A1.Flex"; config = { ocpus = 1; mem = 6; }; };
    freetier_a1flex_half = { name = "VM.Standard.A1.Flex"; config = { ocpus = 2; mem = 12; }; };
    freetier_a1flex_full = { name = "VM.Standard.A1.Flex"; config = { ocpus = 4; mem = 24; }; };
    freetier_e2_micro = { name = "VM.Standard.E2.1.Micro"; };
  };

  canonical_ubuntu_20_04__aarch64__20210922_0 = {
    "ap-chuncheon-1" = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaapgcextelmkktqpz623asl4adp2o7dkpnr7v6cstvwwrresewme3q";
    "ap-hyderabad-1" = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaa3oco3lgsm3ffm5kgpkw4eqoae3wxcbusnlwmoxiyhh6xw5faevgq";
    "ap-melbourne-1" = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaan57xho5nl62az3e2hmvyjkzpw3lgwjvds6agxslvkcs5jhjjlkga";
    "ap-mumbai-1" = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaastc435xecq5snxnwqyflyo6pbnhah64nb2bnl7kfzfod733pkhua";
    "ap-osaka-1" = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaqlxlundsz5dvxi6owczyyb3ypwcuebqh5nxdcxmd4vjthmni7x3a";
    "ap-seoul-1" = "ocid1.image.oc1.ap-seoul-1.aaaaaaaamudlsxebeadfcwqjz2y5cvt3bt7am6ojlonyatglajgexdz7ofca";
    "ap-sydney-1" = "ocid1.image.oc1.ap-sydney-1.aaaaaaaagehmqelnufcmzhyyj3iheemq5psqx52z2uazs6tt5b3wi7ylcnaq";
    "ap-tokyo-1" = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaawjyjv6skxshenjm4rmgeyyjlnwynksa5iawmcpwpqqkgp6kf3cxq";
    "ca-toronto-1" = "ocid1.image.oc1.ca-toronto-1.aaaaaaaa2ytilwxi47yjdhgwp3ayqw5cfikhy5d3bileja35efeig2ljlifa";
    "eu-amsterdam-1" = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaaeyjxu6kaw5eko2erras3enzceixuenwvd7phw3cnfycf2sh4miba";
    "eu-frankfurt-1" = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaevqvpysi6itvzw2wks7zlopyroyfe5vvm5pfspk433tax452vhoq";
    "eu-zurich-1" = "ocid1.image.oc1.eu-zurich-1.aaaaaaaam4u4w4dprotagbxx4glcmjtndbkunzs5kvz5qpkqybemlv4wds3a";
    "me-dubai-1" = "ocid1.image.oc1.me-dubai-1.aaaaaaaazzhk5afrt2wxrgnhb7winmz342ltdaiuewf5zqy2vyon4kyfq7dq";
    "me-jeddah-1" = "ocid1.image.oc1.me-jeddah-1.aaaaaaaahyt4eo7r6ds37um3vtavyijxfuu3kfabzpx4axmzlbn2e4go6sqq";
    "sa-santiago-1" = "ocid1.image.oc1.sa-santiago-1.aaaaaaaa5damq6sznfjudjhnbwlw3f6gtpyxsotxr7unxhvvlawdm7neczoa";
    "sa-saopaulo-1" = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaatkkrkzfyktproktfxqf7dxaja46to3oqo5fcl7p5cmfegtlou2ma";
    "sa-vinhedo-1" = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaawzbyqe4qqi4wdesr36g2prnnectlqvtrp36xkb4m7wsprwl24j2a";
    "uk-cardiff-1" = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaapyf2zl2ict6hhtfq5wimf57padw6vmraium3u574xstien7vl5fa";
    "uk-london-1" = "ocid1.image.oc1.uk-london-1.aaaaaaaabs5halw76hevhsst3l2vmbtgth3jr3pqw5llgp7pqwjbxomvtgva";
    "us-ashburn-1" = "ocid1.image.oc1.iad.aaaaaaaa6k3xa7fdeqt3dqquvqarsqrnq5gp4m2dowex3unnqufyawzv7ukq";
    "us-phoenix-1" = "ocid1.image.oc1.phx.aaaaaaaa7kuixckmi44mvcy3lfx6tusfjdfl7qfq3qwpa6cx5ogbhsxofq6a";
    "us-sanjose-1" = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaf6i7agw7icgk7n5eiwwp7swfnwh4jakhgfaktlpnjtwragatrcza";
  };
  canonical_ubuntu_20_04_minimal__arm64__20210923_0 = {
    "ap-chuncheon-1" = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaa3niassbwqnlkzdcc6or376z52q4cqeb7wq4r7tavoqhp5vgwaoqa";
    "ap-hyderabad-1" = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaavbdzqqppeuao637cqww24vdiyhu4mqhlc4mj65psgynpyc6quoza";
    "ap-melbourne-1" = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaakhaqjujsqkfjq2vnmwzr7zcz22zx5fhpcszr2ezt5eqehswywk2q";
    "ap-mumbai-1" = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaato5ultxut7zaabvoh5ofbu3sikjx7xltdoronoruhm54ysxqkndq";
    "ap-osaka-1" = "ocid1.image.oc1.ap-osaka-1.aaaaaaaajfgjpybreevafqtdvwcfrfqim44tmodunqulirxleve36rzwtg4q";
    "ap-seoul-1" = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaai6g6bhb55aa7svnjjbbiwogbxzhk72atizc2uouedjuldqcndma";
    "ap-sydney-1" = "ocid1.image.oc1.ap-sydney-1.aaaaaaaavcnjfxxejt5lfdam26wgljbm2xo6ivtquyhh3feh5vik4mwlxo2a";
    "ap-tokyo-1" = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaatdn5zflkxdjwwb74jixhluf3425qu2fjdcm4hc5t6hn47lak7aqq";
    "ca-toronto-1" = "ocid1.image.oc1.ca-toronto-1.aaaaaaaapursypkp2ha7ujsy33dmfnqy5atbf7mxzpciakdqlgcljdfa4bla";
    "eu-amsterdam-1" = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaachqxnazgx3zz3xvlcdy4btdzty5mmwprpjtosabmoqdgvvkinhla";
    "eu-frankfurt-1" = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaose3uwyt7kyumj35pdjj7ww4xumzpittbo3g5mezmmicvms2aqwq";
    "eu-zurich-1" = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa6ambdhzk3y7muolmazr5yjk2r4h2fhyrp3n4xst2nb37oamxbdzq";
    "me-dubai-1" = "ocid1.image.oc1.me-dubai-1.aaaaaaaavje6yyqmrqyuhcvdnerflts3r4nswgsyifocrjryhb27g3dtavwq";
    "me-jeddah-1" = "ocid1.image.oc1.me-jeddah-1.aaaaaaaam352yobk5o3umoq3timyu4gaw3bsare763wzgchizitwpatyas4a";
    "sa-santiago-1" = "ocid1.image.oc1.sa-santiago-1.aaaaaaaawmja3sooylcmj3cfvem2xycsxxzticgzu3i2ukad7263yhsx5b4a";
    "sa-saopaulo-1" = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaav3wxkyf3kaviov3t3fkpsu6fi4i2igvw5pyi2p5kokmzvkraivha";
    "sa-vinhedo-1" = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaazkvtg5uf4ckhgehm4igoq7433frdh4kqqrae43km5wsaitmfm44q";
    "uk-cardiff-1" = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaata3whwgzmnsoymeadtiudn544e7osmueiycdh6qwqlo5kjrmryza";
    "uk-london-1" = "ocid1.image.oc1.uk-london-1.aaaaaaaalksmnbf4dqawnwgws665c5eqcygqzn5eviqxosdq3nnuwbdbpimq";
    "us-ashburn-1" = "ocid1.image.oc1.iad.aaaaaaaao6rjdaqwkgn6i5iz6pk5eogcrblijryhwbdad3w7onhyazrekwwq";
    "us-phoenix-1" = "ocid1.image.oc1.phx.aaaaaaaajr5tawccj7osffbmellxbxridvm2gxgvbvghej7wez3raiwsxd2q";
    "us-sanjose-1" = "ocid1.image.oc1.us-sanjose-1.aaaaaaaao3z7zmqbb4zmatcxuagf3gxul3sr2wzvjgbqheluwgzkariuhveq";
  };

  images = rec {
    "canonical_ubuntu_20_04__aarch64" = canonical_ubuntu_20_04__aarch64__20210922_0;
    "Canonical-Ubuntu-20.04-aarch64-2021.09.22-0" = canonical_ubuntu_20_04__aarch64__20210922_0;

    "canonical_ubuntu_20_04_minimal__arm64" = canonical_ubuntu_20_04_minimal__arm64__20210923_0;
    "Canonical-Ubuntu-20.04-Minimal-2021.09.23-0" = canonical_ubuntu_20_04_minimal__arm64__20210923_0;
  };

  # sshpubkey = (builtins.elemAt (import ../data/sshkeys.nix) 0);
  sshpubkey = (builtins.elemAt (import ../profiles/user-cole.nix).config.users.extraUsers."cole".openssh.authorizedKeys.keys 0);

  mkVm = oracle_config: name: v: {
    output."${oracle_config.uniqueid}_${name}_public_ip_addr".value = "\${oci_core_instance.${oracle_config.uniqueid}_${name}.public_ip}";

    # TODO: add two 100GB data disks and ZFS them together
    # use this for persistent data across netboots
    # TODO: write startup initrd service that can initialize the ZFS as we wish

    resource.oci_core_instance."${oracle_config.uniqueid}_${name}" = [({
      provider = "oci.${oracle_config.uniqueid}";
      availability_domain = "\${data.oci_identity_availability_domain.${oracle_config.uniqueid}_default_ad.name}";
      compartment_id = oracle_config.compartment_ocid;
      create_vnic_details = [
        {
          assign_private_dns_record = true;
          assign_public_ip = true;
          display_name = "PrimaryVnic";
          hostname_label = "${name}";
          subnet_id = "\${oci_core_subnet.${oracle_config.uniqueid}_default_subnet.id}";
        }
      ];
      display_name = "${name}";
      metadata = {
        ssh_authorized_keys = sshpubkey;
      } // (if !(builtins.hasAttr "payload" v) then {} else {
        user_data = tfutil.userdata_b64 v.payload;
      });
      shape = v.shape.name;
      shape_config = if (!builtins.hasAttr "config" v.shape) then [] else [{
        memory_in_gbs =  v.shape.config.mem;
        ocpus = v.shape.config.ocpus;
      }];
      source_details = if !(builtins.hasAttr "image" v) then [
        # TODO: this is a dummy since it seems like oracle bitches if you dont specify a boot source img id
        { source_id = images.canonical_ubuntu_20_04__aarch64.${oracle_config.region}; source_type = "image";}
      ] else [{
        source_id = v.image."${oracle_config.region}";
        source_type = "image";
      }];
      timeouts = [{
        create = "60m";
      }];
    } // (if !(builtins.hasAttr "ipxe_url" v) then {} else {
      ipxe_script = ''
          #!ipxe
          show dns
          set dns 1.1.1.1
          ifstat
          dhcp net0

          chain --autofree --replace ${v.ipxe_url}
        '';
      }))];
  };

  mergeListToAttrs = lib.fold (c: el: lib.recursiveUpdate el c) {};
in {
  inherit images shapes;

  tfplan = oracle_config: vms:
    mergeListToAttrs ([]
      ++ (lib.mapAttrsToList (mkVm oracle_config) vms)
      ++ [{
        terraform = {
          required_providers = {
            oci = {
              source = "oracle/oci";
              version = tf_oci_version;
            };
          };
        };
        locals = {};
        provider = {
          oci = [{
            alias = oracle_config.uniqueid;
            fingerprint = oracle_config.fingerprint;
            private_key_path = oracle_config.key_file;
            region = oracle_config.region;
            tenancy_ocid = oracle_config.tenancy_id;
            user_ocid = oracle_config.user;
          }];
        };
        data = {
          oci_identity_availability_domain."${oracle_config.uniqueid}_default_ad" = [{
            provider = "oci.${oracle_config.uniqueid}";
            compartment_id = oracle_config.compartment_ocid;
            ad_number = 1;
          }];
          oci_objectstorage_namespace."${oracle_config.uniqueid}_os_namespace" = [{
            provider = "oci.${oracle_config.uniqueid}";
            compartment_id = oracle_config.compartment_ocid;
          }];
        };
        resource = rec {
          # make a bucket, store kernel+initrd here, boot from there via ipxe?

          # oci_objectstorage_bucket."${oracle_config.uniqueid}_os_bucket" = [{
          #   provider = "oci.${oracle_config.uniqueid}";
          #   name = "${oracle_config.uniqueid}_bucket";
          #   compartment_id = oracle_config.compartment_ocid;
          #   access_type = "ObjectRead";
          #   namespace = "\${data.oci_objectstorage_namespace.${oracle_config.uniqueid}_os_namespace.namespace}";
          # }];

          # oci_objectstorage_object."${oracle_config.uniqueid}_os_obj__kernel" = [{
          #   provider = "oci.${oracle_config.uniqueid}";
          #   bucket = "\${oci_objectstorage_bucket.${oracle_config.uniqueid}_os_bucket.name}";
          #   namespace = "\${data.oci_objectstorage_namespace.${oracle_config.uniqueid}_os_namespace.namespace}";
          #   object = "kernel";
          #   source = "/nix/store/xj4s8wl52p7nmdrnpy3d0jahi6bapcbf-nixos-system-nixos-22.05pre339470.d87b72206aa/kernel";
          # }];

          # oci_objectstorage_object."${oracle_config.uniqueid}_os_obj__initrd" = [{
          #   provider = "oci.${oracle_config.uniqueid}";
          #   bucket = "\${oci_objectstorage_bucket.${oracle_config.uniqueid}_os_bucket.name}";
          #   namespace = "\${data.oci_objectstorage_namespace.${oracle_config.uniqueid}_os_namespace.namespace}";
          #   object = "initrd";
          #   source = "/nix/store/xj4s8wl52p7nmdrnpy3d0jahi6bapcbf-nixos-system-nixos-22.05pre339470.d87b72206aa/initrd";
          # }];

          oci_core_internet_gateway."${oracle_config.uniqueid}_default_internet_gateway" = [{
            provider = "oci.${oracle_config.uniqueid}";
            compartment_id = oracle_config.compartment_ocid;
            display_name = "DefaultInternetGateway";
            vcn_id = "\${oci_core_vcn.${oracle_config.uniqueid}_default_vcn.id}";
          }];
          oci_core_default_route_table."${oracle_config.uniqueid}_default_route_table" = [{
            provider = "oci.${oracle_config.uniqueid}";
            display_name = "DefaultRouteTable";
            manage_default_resource_id = "\${oci_core_vcn.${oracle_config.uniqueid}_default_vcn.default_route_table_id}";
            route_rules = [
              {
                destination = "0.0.0.0/0";
                destination_type = "CIDR_BLOCK";
                network_entity_id = "\${oci_core_internet_gateway.${oracle_config.uniqueid}_default_internet_gateway.id}";
              }
            ];
          }];
          oci_core_subnet."${oracle_config.uniqueid}_default_subnet" = [{
            provider = "oci.${oracle_config.uniqueid}";
            availability_domain = "\${data.oci_identity_availability_domain.${oracle_config.uniqueid}_default_ad.name}";
            cidr_block = "10.0.1.0/24";
            compartment_id = oracle_config.compartment_ocid;
            dhcp_options_id = "\${oci_core_vcn.${oracle_config.uniqueid}_default_vcn.default_dhcp_options_id}";
            display_name = "DefaultSubnet";
            dns_label = "default";
            route_table_id = "\${oci_core_vcn.${oracle_config.uniqueid}_default_vcn.default_route_table_id}";
            security_list_ids = [
              "\${oci_core_vcn.${oracle_config.uniqueid}_default_vcn.default_security_list_id}"
            ];
            vcn_id = "\${oci_core_vcn.${oracle_config.uniqueid}_default_vcn.id}";
          }];
          oci_core_vcn."${oracle_config.uniqueid}_default_vcn" = [{
            provider = "oci.${oracle_config.uniqueid}";
            cidr_block = "10.0.0.0/16";
            compartment_id = oracle_config.compartment_ocid;
            display_name = "DefaultVcn";
            dns_label = "default";
          }];
        };
      }]
  );
}


