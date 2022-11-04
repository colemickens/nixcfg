#!/usr/bin/env bash


export NO_PAGER=1
export USER="colemickens"
export REPO="nixcfg"

while true; do
  gh api repos/$USER/$REPO/actions/runs \
    | jq -r '.workflow_runs[] | select(.name != "default") | "\(.id)"' \
    | xargs -n1 -I % gh api repos/$USER/$REPO/actions/runs/% -X DELETE

  sleep 2
done
