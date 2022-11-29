#!/usr/bin/env zsh

# Copyright 2022 Google LLC.
# SPDX-License-Identifier: Apache-2.0

export FZF_MOVEMENT="--bind='ctrl-n:preview-down' \
--bind='ctrl-p:preview-up'"

export FZF_DEFAULT_OPTS="$FZF_MOVEMENT"

    _getCandidates="jj log $@"
    _reload="toggle-preview+reload($_getCandidates)+toggle-preview"
    _jjLogLineToCommitId="echo {} | grep -o '[a-f0-9]\{7,\} ' | sed '1q;d' | tr -d '\n'"
    _jjLogLineToChangeId="echo {} | grep -o '[a-f0-9]\{7,\} ' | sed '2q;d' | tr -d '\n'"

    _show="$_jjLogLineToCommitId | xargs -I % jj show --color=always %"
    _show_git="$_jjLogLineToCommitId | xargs -I % jj show --color=always --git %"
    _squash="$_jjLogLineToCommitId | xargs -I % jj squash -r %"
    _edit="$_jjLogLineToCommitId | xargs -I % jj edit %"
    _checkout="$_jjLogLineToCommitId | xargs -I % jj checkout %"

    # Passing the --disabled flag disables the fuzzy-search, which lets you
    # input whatever you want into the query e.g. you can use the query as a
    # command builder for invocations like `jj rebase -s A -d B`.
    eval $_getCandidates | \
    fzf --ansi --no-sort --reverse --tiebreak=index --disabled \
        --preview="$_show" \
        --bind "ctrl-r:reload($_getCandidates)" \
        --bind "ctrl-o:execute-silent:($_jjLogLineToCommitId | pbcopy)" \
        --bind "ctrl-h:execute-silent($_jjLogLineToChangeId | pbcopy)" \
        --bind "alt-s:execute-silent($_squash)+$_reload" \
        --bind "alt-e:execute-silent($_edit)+$_reload" \
        --bind "alt-c:execute-silent($_checkout)+$_reload" \
        --bind "ctrl-c:cancel" \
        --bind "ctrl-y:execute-silent(echo -n {q} | pbcopy)" \
        --bind "enter:execute-silent(eval {q})+$_reload"
