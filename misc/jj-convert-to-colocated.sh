#!/usr/bin/env bash
set -x
set -euo pipefail

export PAGER=cat

# Move the Git repo
mv .jj/repo/store/git .git
# Tell jj where to find it
echo -n '../../../.git' > .jj/repo/store/git_target
# Ignore the .jj directory in Git
echo '/*' > .jj/.gitignore
# Make the Git repository non-bare and set HEAD
git config --unset core.bare
jj st
git status
