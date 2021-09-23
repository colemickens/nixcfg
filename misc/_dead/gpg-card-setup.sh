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


gpg-connect-agent "SCD SETATTR KEY-ATTR --force 1 22 ed25519" /bye
gpg-connect-agent "SCD SETATTR KEY-ATTR --force 2 18 cv25519" /bye
gpg-connect-agent "SCD SETATTR KEY-ATTR --force 3 22 ed25519" /bye

gpg-card "${gpgargs[@]}" \
  --force \
  --algo=BLAH?


bash
kill -9 $gpid
# set time permanently
