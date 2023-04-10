{ pkgs, terranix }:

let
  tflib = import ./tflib.nix { inherit pkgs; };
  tfpkg = (pkgs.terraform_1.withPlugins (p:
  [
    # these should be included, maybe via option/modules
    # from the tflib-*.nix
    p.equinix
    p.oci
    /* p.sops */
  ]));
  tf = "${tfpkg}/bin/terraform"; # "${tf}"
  tfstate = "./cloud/_state";

  ##
  ## <oracle>
  ociacct1 = {
    uniqueid = "ocicole1";
    tenancy_id = "ocid1.tenancy.oc1..aaaaaaaafyqmgtgi5nwkolwjujayjrx5qw2qmzpbp7wzche2kgmdrlptnj4q";
    user = "ocid1.user.oc1..aaaaaaaah76dpd2bz6pqmy53t2p7mxy3wieydldjxshmnpe6nsoensqieulq";
    fingerprint = "d4:d8:ce:6c:c4:ca:b9:ab:11:ac:2a:1f:1b:e7:70:71";
    region = "us-phoenix-1";
    key_file = "/run/secrets/oraclecloud_colemickens_privkey";
    compartment_ocid = # "terraform" compartment in colemickens
      "ocid1.compartment.oc1..aaaaaaaafclyuqguzm2rtz5a5kcijxnjnidd4x3u35rwlivim6xuwuutzsta";
  };
  ociacct2 = {
    uniqueid = "ocicole2";
    tenancy_id = "ocid1.tenancy.oc1..aaaaaaaa5wbwazusekjhx4qrtz3zpyey5ougiamcjshyjpqjuwtuaxr5esna";
    user = "ocid1.user.oc1..aaaaaaaauova2ywoupcudpxscp4gcxuzsauj5ymsksccubsaedqvjzw6o3yq";
    fingerprint = "d5:4a:e6:5a:1f:cd:65:96:9d:52:72:5b:85:42:2c:f8";
    region = "us-phoenix-1";
    key_file = "/run/secrets/oraclecloud_colemickens2_privkey";
    compartment_ocid = # "terraform" compartment in colemickens2
      "ocid1.compartment.oc1..aaaaaaaawrfmgshb57lsir25eqpd3x6hgyb2lddwn3uyjzm7tnhpdyt2fwca";
  };

  o_arm_img = "canonical_ubuntu_20_04__aarch64";
  o_amd_img = "canonical_ubuntu_20_04_minimal__arm64";
  ## </oracle>

  ##
  ## <equinix>
  metal_cole = {
    project_id = "afc67974-ff22-41fd-9346-5b2c8d51e3a9";
  };
  ## </equinix>

  ##
  ## get nixpkgs provider versions:
  ## - jq -r ".metal" pkgs/applications/networking/cluster/terraform-providers/providers.json
  ## - jq -r ".equinix" pkgs/applications/networking/cluster/terraform-providers/providers.json
  ## <terranix>
  ud = tflib.ubuntu.userdata;
  uv = tflib.ubuntu.uservars;
  n_ud = tflib.nixos.userdata;
  n_uv = tflib.nixos.uservars;

  # TODO: use google cloud to store our netboot data

  terraformCfg = terranix.lib.terranixConfiguration {
    inherit pkgs;
    modules = [
      ### equinix VMS
      (tflib.equinix.tfplan metal_cole {
        pktspot1 = {
          plan = tflib.equinix.plans.n3_xlarge_x86;
          # os = tflib.equinix.os.nixos_22_05;
          os = tflib.equinix.os.nixos_22_11; # TODO
          loc = tflib.equinix.metros.dc10;
          bid = "0.50";
          payload = tflib.payloads.nixos-generic-config;
        };
        # pktspotarm1 = {
        #   plan = tflib.equinix.plans.c3_large_arm;
        #   os = tflib.equinix.os.nixos_22_05;
        #   loc = tflib.equinix.metros.dc10;
        #   bid = "0.50";
        #   payload = tflib.payloads.nixos-generic-config;
        # };
        # ipxe works too!
        # pktspotnewnixosarm0 = {
        #   plan = tflib.equinix.plans.c3_large_arm;
        #   loc = tflib.equinix.metros.dc10;
        #   bid = "0.60";
        #   ipxe_script_url = "http://netboot.cleo.cat/aarch64/generic/netboot.ipxe";
        # };
      })

      ### ORACLE VMS
      # delete the entire compartment to start over:
      # to check on any instances:
      #  - oci list?
      # (tflib.oracle.tfplan ociacct1 {
      #   oci1arm1 = {
      #     shape = tflib.oracle.shapes.freetier_a1flex_full;
      #     ipxe_url = "http://netboot.cleo.cat/aarch64/generic/netboot.ipxe";
      #   };
      # })
      # (let
      #   tmpl = {
      #     shape = tflib.oracle.shapes.freetier_a1flex_mini;
      #     image = tflib.oracle.images.canonical_ubuntu_20_04__aarch64;
      #     payload = tflib.payloads.ubuntu-nixos-infect;
      #   };
      # in
      #   (tflib.oracle.tfplan ociacct2 {
      #     oci2arm1 = tmpl;
      #     oci2arm2 = tmpl;
      #     oci2arm3 = tmpl;
      #     oci2arm4 = tmpl;
      #   })
      # )
    ];
  };
  ## </terranix>
in {
  # TODO: replace with lovesegfault's sanity checked saneScript writer
  tf = (pkgs.writeShellScript "apply" ''
    set -euo pipefail; set -x
    export TF_STATE="${tfstate}"
    "${tf}" "-chdir=''${TF_STATE}" "''${@}"
  '');
  apply = (pkgs.writeShellScript "apply" ''
    set -euo pipefail; set -x

    duration="1 hour"
    export TF_VAR_termtime="$(TZ=UTC date --date="''${duration}" --iso-8601=seconds)"
    
    set +x
      # TODO: retrieve from other means:
      export METAL_AUTH_TOKEN="$(gopass show colemickens/packet.net | grep apikey | cut -d' ' -f2)"
      
      # TODO: actually utilize this:
      export TF_VAR_tailscale_token="$(gopass show colemickens/packet.net | grep apikey | cut -d' ' -f2)"
    set -x

    export TF_STATE="${tfstate}"
    export RUN_DIR="${tfstate}/run-$(date '+%s')"
    export TF_LOG=DEBUG
    export TF_LOG_PATH="''${RUN_DIR}/log.txt"
    mkdir -p "''${TF_STATE}" "''${RUN_DIR}";

    function tixe() { set +x; sed -i "s/''${METAL_AUTH_TOKEN}/METAL_AUTH_TOKEN_REDACTED/g" "''${TF_LOG_PATH}"; }
    trap tixe EXIT
    
    cp "${terraformCfg}" "''${TF_STATE}/config.tf.json"
    chmod -R +w "''${TF_STATE}"

    "${tf}" "-chdir=''${TF_STATE}" init -upgrade
    
    "${tf}" "-chdir=''${TF_STATE}" version > "''${RUN_DIR}/version.txt"
    "${tf}" "-chdir=''${TF_STATE}" providers > "''${RUN_DIR}/providers.txt"
    "${tf}" "-chdir=''${TF_STATE}" init | tee "''${RUN_DIR}/init.txt"
    "${tf}" "-chdir=''${TF_STATE}" apply | tee "''${RUN_DIR}/apply.txt"
  '');

  destroy = (pkgs.writeShellScript "destroy" ''
    set -euo pipefail; set -x
    export METAL_AUTH_TOKEN="$(gopass show colemickens/equinix.net | grep apikey | cut -d' ' -f2)"
    export TF_STATE="${tfstate}"
    if [[ ! -e "''${TF_STATE}/config.tf.json" ]]; then
      cp "${terraformCfg}" "''${TF_STATE}/config.tf.json"
    fi
    
    "${tf}" "-chdir=''${TF_STATE}" init
    "${tf}" "-chdir=''${TF_STATE}" destroy
  '');
}
