{ pkgs, terranix }:

let
  lib = pkgs.lib;
  
  mkPacket = import ./mkPacket.nix { inherit pkgs; };
  mkOracle = import ./mkOracle.nix { inherit pkgs; };

  userdata = import ./userdata.nix { inherit pkgs; };

  _tf = (pkgs.terraform_1_0.withPlugins (p: [ p.metal p.oci /* p.sops */ ]));
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
  
  udi = f: "\n\n##\n##\n# ${f}\n${builtins.readFile ( ./. + "/${f}" )}";
  ud = pkgs.writeScript "bootstrap.sh.tmpl" ''
    #!/usr/bin/env bash
    set -x
    set -euo pipefail
    ${udi "./userdata/install-nix.sh"}
  '';
  toVars = vars: "{ " + (builtins.concatStringsSep ", " (lib.mapAttrsToList (k: v: "${k} = \"${v}\"") vars)) + " }";
  uv = toVars {
    TF_NIX_INSTALL_URL = "https://github.com/numtide/nix-unstable-installer/releases/download/nix-2.5pre20211008_6bd74a6/install";
    TF_USERNAME = "cole";
    TF_NIXOS_LUSTRATE = "false"; # todo: we already selectively include the script?
  };
  ## </oracle>

  ##
  ## <packet>
  metal_cole = {
    project_id = "afc67974-ff22-41fd-9346-5b2c8d51e3a9";
  };
  ## </packet>

  ##
  ## <terranix>
  terraformCfg = terranix.lib.buildTerranix {
    inherit pkgs;
    terranix_config.imports = [
      ### PACKET VMS
      (mkPacket  metal_cole  {
        #pktspotamd = { plan="c3.medium.x86";  loc="sv";  bid="0.5"; userdata=ud; uservars=uv; };
        #pktspotarm = { "c2.large.arm"   "sv"  "0.5" };
        #pktspotgpu = { "x2.large.x86"   "sv"  "0.5" }; ## is this the right type?
      })

      ### ORACLE VMS
      (mkOracle ociacct1 {
      #   oci1arm1 = { shape = o_arm; image=o_arm_img; userdata=ud; uservars=uv; };
      #   oci1amd1 = { shape = o_amd; image=o_amd_img; userdata=ud; uservars=uv; };
      #   #oci1amd2 = { shape = o_amd; image=o_amd_img; userdata=ud; uservars=uv; };
      })
      # (mkOracle ociacct2 {
      #   oci2arm1 = { shape = o_arm; image=o_arm_img; userdata=ud; uservars=uv; };
      #   oci2amd1 = { shape = o_amd; image=o_amd_img; userdata=ud; uservars=uv; };
      #   oci2amd2 = { shape = o_amd; image=o_amd_img; userdata=ud; uservars=uv; };
      # })
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
    
    cp "${terraformCfg}/config.tf.json" "''${TF_STATE}/config.tf.json"
    chmod -R +w "''${TF_STATE}"
    
    "${tf}" "-chdir=''${TF_STATE}" version > "''${RUN_DIR}/version.txt"
    "${tf}" "-chdir=''${TF_STATE}" providers > "''${RUN_DIR}/providers.txt"
    "${tf}" "-chdir=''${TF_STATE}" init | tee "''${RUN_DIR}/init.txt"
    "${tf}" "-chdir=''${TF_STATE}" apply | tee "''${RUN_DIR}/apply.txt"
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
