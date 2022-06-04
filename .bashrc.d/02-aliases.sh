#!/usr/bin/env bash

which_declare="declare -f"
which_opt="-f"
which_shell="$(cat /proc/$$/comm)"
if [ "$which_shell" = "ksh" ] || [ "$which_shell" = "mksh" ] || [ "$which_shell" = "zsh" ] ; then
    which_declare="typeset -f"
    which_opt=""
fi
which ()
{
    (alias; eval ${which_declare}) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot "${@}"
}
export which_declare
export ${which_opt} which

exile ()
{
    [[ -n "$@" ]] && ("$@" >/dev/null 2>&1 & disown)
}
export -f exile

showcert ()
{
  dig $1
  (openssl s_client -showcerts -servername $1 -connect $1:$2 <<< "Q" | openssl x509 -text )
}

function main {
    alias ls='ls -hNF --color=auto --group-directories-first'
    alias grep='grep --color=auto'
    alias ip='ip -c'

    alias ll='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lz='ls -Z'
    alias llz='ls -lZ'
    alias laz='ls -aZ'
    alias llaz='ls -laZ'
    alias cp='cp -iv'
    alias mv='mv -iv'
    alias rm='rm -iv'
    alias vi='vim'
    alias dd='dd status=progress'
    alias assh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
    alias ascp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
    alias rsync='rsync --progress'
    alias myextip='curl http://ipecho.net/plain && printf "\n"'
    alias wttr='curl wttr.in'

    # The below aliases require additional dependencies
    if command -v highlight &>/dev/null; then
        alias ccat='highlight --out-format=ansi --stdout --force'
        alias cat='ccat'
    fi
    if command -v src-hilite-lesspipe.sh &>/dev/null; then
        export LESSOPEN="|/usr/bin/src-hilite-lesspipe.sh %s"
        export LESS=' -R '
    fi
    if command -v youtube-dl &>/dev/null; then
        alias youtube-dl='youtube-dl --add-metadata -ic'
    fi
    if command -v sxiv &>/dev/null; then
        alias sxiv='sxiv -a'
    fi
}
