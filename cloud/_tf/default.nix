{ pkgs, terranix }:

let
  mkPacketVM = import ./mkPacketVM.nix;
  mkOracleVM = import ./mkOracleVM.nix;

  _tf = (pkgs.terraform_1_0.withPlugins (p: [
      #p.archive
      #p.aws
      #p.external
      #p.gitlab
      #p.grafana
      #p.helm
      #p.kubernetes
      p.local
      p.metal
      p.null
      p.random
      p.template
      #p.tls
    ]));
  tf = "${_tf}/bin/terraform";
  tfstate = "./cloud/_tf/_state";

  oracle_colemickens = {
    tenancy_id = "ocid1.tenancy.oc1..aaaaaaaafyqmgtgi5nwkolwjujayjrx5qw2qmzpbp7wzche2kgmdrlptnj4q";
    user = "ocid1.user.oc1..aaaaaaaah76dpd2bz6pqmy53t2p7mxy3wieydldjxshmnpe6nsoensqieulq";
    fingerprint = "d4:d8:ce:6c:c4:ca:b9:ab:11:ac:2a:1f:1b:e7:70:71";
    region = "us-phoenix-1";
    key_file = "/run/secrets/oraclecloud_colemickens_privkey";

    # "terraform" compartment in colemickens
    compartment_id = "ocid1.compartment.oc1..aaaaaaaafclyuqguzm2rtz5a5kcijxnjnidd4x3u35rwlivim6xuwuutzsta";
  };
  oracle_colemickens2 = {
    tenancy_id = "ocid1.tenancy.oc1..aaaaaaaa5wbwazusekjhx4qrtz3zpyey5ougiamcjshyjpqjuwtuaxr5esna";
    user = "ocid1.user.oc1..aaaaaaaauova2ywoupcudpxscp4gcxuzsauj5ymsksccubsaedqvjzw6o3yq";
    fingerprint = "d5:4a:e6:5a:1f:cd:65:96:9d:52:72:5b:85:42:2c:f8";
    region = "us-phoenix-1";
    key_file = "/run/secrets/oraclecloud_colemickens2_privkey";
  
    # "terraform" compartment in colemickens2
    compartment_id = "ocid1.compartment.oc1..aaaaaaaawrfmgshb57lsir25eqpd3x6hgyb2lddwn3uyjzm7tnhpdyt2fwca";
  };
  metal_cole = {
    project_id = "afc67974-ff22-41fd-9346-5b2c8d51e3a9";
  };

  pkt_bldr_x86 = (mkPacketVM  metal_cole  "c2.medium.x86"  "sjc1"  "bldr-x86");
  pkt_bldr_a64 = (mkPacketVM  metal_cole  "c2.large.arm"   "sjc1"  "bldr-a64");

  terraformCfg = terranix.lib.buildTerranix {
    inherit pkgs;
    #terranix_config = pkgs.lib.mkMerge [ pktVm1 ];
    terranix_config.imports = [
      #pkt_bldr_x86
      pkt_bldr_a64
      #oracle1_amp_one
      #oracle2_amp_one
    ];
    #terranix_config = pktVm1;
    #terranix_config = pktVm1;
    #terranix_config = {};
  };
in {
  # TODO: replace with lovesegfault's sanity checked saneScript writer
  apply = (pkgs.writeShellScript "apply" ''
    set -euo pipefail; set -x
    duration="1 hour"
    export TF_VAR_termtime="$(TZ=UTC date --date="''${duration}" --iso-8601=seconds)"
    export METAL_AUTH_TOKEN="$(gopass show colemickens/packet.net | grep apikey | cut -d' ' -f2)"
    rm -rf "${tfstate}"; mkdir -p "${tfstate}"
    function trap_dump_tf_version() { "${tf}" "-chdir=${tfstate}" version; }
    trap trap_dump_tf_version EXIT
    cp "${terraformCfg}/config.tf.json" "${tfstate}/config.tf.json" \
      && "${tf}" "-chdir=${tfstate}" init \
      && "${tf}" "-chdir=${tfstate}" apply
    chmod -R +w "${tfstate}"
  '');

  destroy = (pkgs.writeShellScript "destroy" ''
    set -euo pipefail; set -x
    export METAL_AUTH_TOKEN="$(gopass show colemickens/packet.net | grep apikey | cut -d' ' -f2)"
    if [[ ! -e config.tf.json ]]; then
      cp "${terraformCfg}/config.tf.json" "${tfstate}/config.tf.json"
    fi
    true \
      && "${tf}" "-chdir=${tfstate}" init \
      && "${tf}" "-chdir=${tfstate}" destroy
    rm -rf "${tfstate}"/*
  '');
}
