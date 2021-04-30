#!/usr/bin/env bash

# fix time

gpgargs=(
  --fake-system-time "19900420T00000"
)

# AHEAD OF TIME:
# wipe the openpgp xl app on Ledger

# WARNING:
# todo actually warn
# we move

export ALGO="nistp256"

export GNUPGHOME="$(mktemp -d)"
gpg-agent &
gpid=$!

gpg-card "${gpgargs[@]}" \
  --force \
  --algo=BLAH?


bash
kill -9 $gpid
# set time permanently
