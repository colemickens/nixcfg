{ pkgs ? import <nixpkgs> { } }:
let
  hcloud_api_token = "`${pkgs.pass}/bin/pass development/hetzner.com/api-token`";
  
  terraform = pkgs.writers.writeBashBin "terraform" ''
    export TF_VAR_hcloud_api_token=${hcloud_api_token}
    ${pkgs.terraform_0_15}/bin/terraform "$@"
  '';

  oracle_config1 = {
    tenancy_id = "ocid1.tenancy.oc1..aaaaaaaafyqmgtgi5nwkolwjujayjrx5qw2qmzpbp7wzche2kgmdrlptnj4q";
    user = "ocid1.user.oc1..aaaaaaaah76dpd2bz6pqmy53t2p7mxy3wieydldjxshmnpe6nsoensqieulq";
    fingerprint = "d4:d8:ce:6c:c4:ca:b9:ab:11:ac:2a:1f:1b:e7:70:71";
    region = "us-phoenix-1";
    key_file = "/run/secrets/oraclecloud_colemickens_privkey";
  };
  oracle_config2 = {
    tenancy_id = "ocid1.tenancy.oc1..aaaaaaaa5wbwazusekjhx4qrtz3zpyey5ougiamcjshyjpqjuwtuaxr5esna";
    user = "ocid1.user.oc1..aaaaaaaauova2ywoupcudpxscp4gcxuzsauj5ymsksccubsaedqvjzw6o3yq";
    fingerprint = "d5:4a:e6:5a:1f:cd:65:96:9d:52:72:5b:85:42:2c:f8";
    region = "us-phoenix-1";
    key_file = "/run/secrets/oraclecloud_colemickens2_privkey";
  };

  oracle_instances = [
    (mkInstance oracle_config1 "oracular1")
    # (mkInstance oracle_config2 "oracular2")
  ];

  tfdo = pkgs.writeScriptBin "tfdo" ''
    set -euo pipefail
    set -x

    terranix > config.tf.json \
      && terraform init \
      && terraform apply
  '';
in pkgs.mkShell {
  buildInputs = [ tfdo ];
}
