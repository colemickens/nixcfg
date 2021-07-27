#!/usr/bin/env bash

set -x
set -euo pipefail

oci compute instance launch \
  --availability-domain "zWUB:PHX-AD-1" \
  --compartment-id "ocid1.tenancy.oc1..aaaaaaaafyqmgtgi5nwkolwjujayjrx5qw2qmzpbp7wzche2kgmdrlptnj4q" \
  --shape "VM.Standard.E2.1.Micro" \
  --subnet-id "ocid1.subnet.oc1.phx.aaaaaaaa2oohcsqzhwsmib4jrlm5mz7mhxpy2654wwwcj7gr5gzmtq7y6heq" \
  --image-id "ocid1.image.oc1.phx.aaaaaaaapd67qc2b7q6flfhn3ai5jkpsx4vxz5afch2qwdqujjepvbx25rpq" \
  --user-data-file ./oci.cloudinit

  --user-data-file ./oci.cloudinit
  --ipxe-script-file "./oci.ipxe"

