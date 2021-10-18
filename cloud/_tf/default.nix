{ inputs, pkgs }:

let
  mkPacketVM = import ./mkPacketVM.nix;
  mkOracleVM = import ./mkOracleVM.nix;

  tf = "${pkgs.terraform_0_15}/bin/terraform";

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
  equinix_metal_cole = {
    auth_token__file = "/run/secrets/packet_apikey";
    project_id = "afc67974-ff22-41fd-9346-5b2c8d51e3a9";
  };

  pktVm1 = (mkPacketVM equinix_metal_cole "c2.medium.x86" "sjc1" "bldr-x86");
  terraformCfg = inputs.terranix.lib.buildTerranix {
    inherit pkgs;
    #terranix_config = pkgs.lib.mkMerge [ pktVm1 ];
    terranix_config.imports = [ pktVm1 ];
    #terranix_config = pktVm1;
    #terranix_config = pktVm1;
    #terranix_config = {};
  };
  pktVm1Json = pkgs.writeText "pktVm1.json" (pkgs.lib.generators.toJSON {} pktVm1);
in {
  # TODO: replace with lovesegfault's sanity checked saneScript writer
  apply = (pkgs.writeShellScript "apply" ''
    set -euo pipefail; set -x
    nvim "${pktVm1Json}";
    sleep 5
    duration="1 hour"
    export TF_VAR_termtime="$(TZ=UTC date --date="''${duration}" --iso-8601=seconds)"
    export METAL_AUTH_TOKEN="$(gopass show colemickens/packet.net | grep apikey | cut -d' ' -f2)"
    if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
    
    cp ${terraformCfg}/config.tf.json config.tf.json \
      && ${tf} init \
      && ${tf} apply
  '');

  destroy = (pkgs.writeShellScript "destroy" ''
    set -euo pipefail; set -x
    export METAL_AUTH_TOKEN="$(gopass show colemickens/packet.net | grep apikey | cut -d' ' -f2)"
    # if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
    cp ${terraformCfg}/config.tf.json config.tf.json \
      && ${tf} init \
      && ${tf} destroy
  '');
}
