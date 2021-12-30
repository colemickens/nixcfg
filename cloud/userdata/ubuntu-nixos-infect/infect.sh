#! /usr/bin/env bash

# we would vendor this in, but our terraform/hcl workaround isn't good enough yet:

curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect \
  | NIX_CHANNEL=nixos-21.11 bash -x