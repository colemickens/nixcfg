#!/usr/bin/env bash
set -euo pipefail

# Implement `jj am` like `git am`: apply a patch series (mbox/Maildir/patch
# files, or stdin) as a stack of jj commits, preserving each patch's author,
# date, and commit message. Works whether or not the jj repo is git-colocated
# since it never touches a git index or HEAD -- it only splits/parses mail
# with `git mailsplit`/`git mailinfo` and edits the working tree with
# `git apply`, then hands each resulting change to jj.

usage() {
  echo "usage: $(basename "$0") [<mbox>|<Maildir>|<patch-file>...]" >&2
  echo "       (reads an mbox from stdin if no arguments are given)" >&2
  exit 1
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
fi

root=$(jj root)
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

splitdir="$workdir/split"
mkdir -p "$splitdir"

if [ "$#" -eq 0 ]; then
  git mailsplit -o"$splitdir" >/dev/null
else
  git mailsplit -o"$splitdir" -- "$@" >/dev/null
fi

cd "$root"

for mail in "$workdir"/split/*; do
  n=$(basename "$mail")
  msgfile="$workdir/$n.msg"
  patchfile="$workdir/$n.patch"

  info=$(git mailinfo "$msgfile" "$patchfile" <"$mail")
  author=$(sed -n 's/^Author: //p' <<<"$info")
  email=$(sed -n 's/^Email: //p' <<<"$info")
  subject=$(sed -n 's/^Subject: //p' <<<"$info")
  date=$(sed -n 's/^Date: //p' <<<"$info")
  body=$(cat "$msgfile")

  echo "Applying: $subject"

  if [ -n "$body" ]; then
    message="$subject"$'\n\n'"$body"
  else
    message="$subject"
  fi

  git apply "$patchfile"
  jj --quiet metaedit -m "$message" --author "$author <$email>" --author-timestamp "$date"
  jj --quiet new
done
