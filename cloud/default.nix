{ pkgs, terranix }:

let
  terraform = (
    pkgs.terraform_1.withPlugins (p: [
      # these should be included, maybe via option/modules
      # from the tflib-*.nix
      p.aws
    ])
  );
  terraformConfiguration = terranix.lib.terranixConfiguration {
    inherit pkgs;
    modules = [ ./config.nix ];
  };
in
{
  apply = {
    type = "app";
    program =
      (pkgs.writeShellScript "apply" ''
        set -x
        set -euo pipefail

        if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
        cp ${terraformConfiguration} config.tf.json \
          && ${terraform}/bin/terraform init -upgrade \
          && ${terraform}/bin/terraform apply
      '').outPath;
  };
  destroy = {
    type = "app";
    program =
      (pkgs.writeShellScript "destroy" ''
        set -x
        set -euo pipefail

        if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
        cp ${terraformConfiguration} config.tf.json \
          && ${terraform}/bin/terraform init -upgrade \
          && ${terraform}/bin/terraform destroy
      '').outPath;
  };
}
