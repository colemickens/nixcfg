export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export TERM="xterm-256color"
export EDITOR="nvim"

export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# faster ls? DIRCOLORS? 
# exa/bat by default?

# git prompt
# collapsed dir prompt

# default
export BASH_COLOR="1;32" && export TMUXCOLOR="green"
[[ "${HOSTNAME}" == "xeep" ]] && \
  export BASH_COLOR="1;35" && export TMUXCOLOR="magenta"
[[ "${HOSTNAME}" == "chimera" ]] && \
  export BASH_COLOR="1;36" && export TMUXCOLOR="cyan"

# prompt
PROMPT_COLOR="1;31m"
let $UID && PROMPT_COLOR="${BASH_COLOR}m"
PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
if test "$TERM" = "xterm"; then
  PS1="\[\033]2;\h:\u:\w\007\]$PS1"
fi

function gpgssh() {
  set -x
  fwdpath1="/run/user/1000/gnupg/S.gpg-agent"
  fwdpath2="/home/cole/.gnupg/S.gpg-agent"
  TERM=xterm \
  ssh "${@}" rm "${fwdpath1}" || true
  ssh "${@}" rm "${fwdpath2}" || true
  ssh \
    -o "RemoteForward ${fwdpath1}:/run/user/1000/gnupg/S.gpg-agent.extra" \
    -o "RemoteForward ${fwdpath2}:/run/user/1000/gnupg/S.gpg-agent.extra" \
    -o StreamLocalBindUnlink=yes \
    -A \
    "${@}"
  set +x
}

if [[ "$SSH_AUTH_SOCK" == "/run/user/$(id -u)/keyring/ssh" ]]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export FZF_TMUX=1
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

eval "$(direnv hook bash)"

#if [[ "$(tty)" == "tty1" ]]; then
#  { sleep 3; SWAYSOCK="/run/user/$(uid)/sway-ipc.*.sock" swaylock; } &
#  sway;
#fi


source /home/cole/.config/broot/launcher/bash/br
