{ pkgs, terranix }:

let
  mkPacketVM = import ./mkPacketVM.nix;
  mkOracle = import ./mkOracle.nix;

  _tf = (pkgs.terraform_1_0.withPlugins (p: [
      p.local
      p.metal
      p.null
      p.oci
      p.random
      p.template
    ]));
  tf = "${_tf}/bin/terraform";
  tfstate = "./cloud/_tf/_state";

  ##
  ## <oracle>
  ociacct1 = {
    tenancy_id = "ocid1.tenancy.oc1..aaaaaaaafyqmgtgi5nwkolwjujayjrx5qw2qmzpbp7wzche2kgmdrlptnj4q";
    user = "ocid1.user.oc1..aaaaaaaah76dpd2bz6pqmy53t2p7mxy3wieydldjxshmnpe6nsoensqieulq";
    fingerprint = "d4:d8:ce:6c:c4:ca:b9:ab:11:ac:2a:1f:1b:e7:70:71";
    region = "us-phoenix-1";
    key_file = "/run/secrets/oraclecloud_colemickens_privkey";
    compartment_id = # "terraform" compartment in colemickens
      "ocid1.compartment.oc1..aaaaaaaafclyuqguzm2rtz5a5kcijxnjnidd4x3u35rwlivim6xuwuutzsta";
  };
  ociacct2 = {
    tenancy_id = "ocid1.tenancy.oc1..aaaaaaaa5wbwazusekjhx4qrtz3zpyey5ougiamcjshyjpqjuwtuaxr5esna";
    user = "ocid1.user.oc1..aaaaaaaauova2ywoupcudpxscp4gcxuzsauj5ymsksccubsaedqvjzw6o3yq";
    fingerprint = "d5:4a:e6:5a:1f:cd:65:96:9d:52:72:5b:85:42:2c:f8";
    region = "us-phoenix-1";
    key_file = "/run/secrets/oraclecloud_colemickens2_privkey";
    compartment_id = # "terraform" compartment in colemickens2
      "ocid1.compartment.oc1..aaaaaaaawrfmgshb57lsir25eqpd3x6hgyb2lddwn3uyjzm7tnhpdyt2fwca";
  };
  o_arm = { name = "VM.Standard.A1.Flex"; config = { ocpus = 4; mem = 24; }; };
  o_amd = { name = "VM.Standard.E2.1.Micro"; };
  o_arm_img = "canonical_ubuntu_20_04__aarch64";
  o_amd_img = "canonical_ubuntu_20_04_minimal__arm64";
  oci1_vcn = (mkOracle ociacct1 {
    oci1arm1 = { shape = o_arm; image=o_arm_img; };
    #oci1amd1 = { shape = o_amd; image=o_amd_img; };
  });
  ## </oracle>

  ##
  ## <packet>
  metal_cole = {
    project_id = "afc67974-ff22-41fd-9346-5b2c8d51e3a9";
  };
  #pkt_loc = "sjc1"; # https://github.com/equinix/terraform-provider-metal/issues/196
  pkt_loc = "sv";
  pkt_spot_amd = (mkPacketVM  metal_cole  "c2.medium.x86"  pkt_loc  "pktspotamd");
  pkt_spot_arm = (mkPacketVM  metal_cole  "c2.large.arm"   pkt_loc  "pktspotarm");
  pkt_spot_gpu = (mkPacketVM  metal_cole  "x2.xlarge.arm"  pkt_loc  "pktspotgpu");
  ## </packet>

  ##
  ## <terranix>
  terraformCfg = terranix.lib.buildTerranix {
    inherit pkgs;
    terranix_config.imports = [
      #pkt_spot_arm
      #pkt_spot_amd
      #pkt_spot_gpu
      oci1_vcn
      #oci2_arm1
      #oci2_amd1
      #oci2_amd2
    ];
  };
  ## </terranix>
in {
  # TODO: replace with lovesegfault's sanity checked saneScript writer
  apply = (pkgs.writeShellScript "apply" ''
    set -euo pipefail; set -x

    duration="1 hour"
    export TF_VAR_termtime="$(TZ=UTC date --date="''${duration}" --iso-8601=seconds)"
    export METAL_AUTH_TOKEN="$(gopass show colemickens/packet.net | grep apikey | cut -d' ' -f2)"
  
    export TF_STATE="${tfstate}"
    export TF_LOG=DEBUG
    export TF_LOG_PATH="''${TF_STATE}/log-$(date '+%s').txt"

    mkdir -p "''${TF_STATE}";
    function trap_dump_tf_version() {
      "${tf}" "-chdir=''${TF_STATE}" version
      sed -i "s/''${METAL_AUTH_TOKEN}/METAL_AUTH_TOKEN_REDACTED/g" "''${TF_LOG_PATH}"
      chmod -R +w "''${TF_STATE}"
    }
    trap trap_dump_tf_version EXIT
    
    cp "${terraformCfg}/config.tf.json" "''${TF_STATE}/config.tf.json"
    chmod -R +w "''${TF_STATE}"
    
    "${tf}" "-chdir=''${TF_STATE}" providers > /tmp/tf/providers.txt
    "${tf}" "-chdir=''${TF_STATE}" init
    "${tf}" "-chdir=''${TF_STATE}" apply
    exit 0

    # TODO: how does state work ,can it recreate? should it?
    #echo<<EOF >"''${TF_STATE}/destroy.sh"
    #""
  '');

  destroy = (pkgs.writeShellScript "destroy" ''
    set -euo pipefail; set -x
    export METAL_AUTH_TOKEN="$(gopass show colemickens/packet.net | grep apikey | cut -d' ' -f2)"
    export TF_STATE="${tfstate}"
    if [[ ! -e "''${TF_STATE}/config.tf.json" ]]; then
      cp "${terraformCfg}/config.tf.json" "''${TF_STATE}/config.tf.json"
    fi
    
    "${tf}" "-chdir=''${TF_STATE}" init
    "${tf}" "-chdir=''${TF_STATE}" destroy
  '');
}
