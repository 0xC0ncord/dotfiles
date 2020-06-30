#!/bin/sh

alias ls='ls -hNF --color=auto --group-directories-first'
alias grep='grep --color=auto'

alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias vi='vim'
alias assh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias ascp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias myextip='curl http://ipecho.net/plain && printf "\n"'
alias wttr='curl wttr.in'

# The below aliases require additional dependencies
if $(which 'highlight' &> /dev/null) ; then
    VER="$(highlight --version | sed '1d;2q' | awk '{print $3}')"
    if [[ "$(printf ${VER} | awk -F. '{print $1}')" -gt 3 || "$(printf ${VER} | awk -F. '{print $2}')" -ge 35 ]]; then
        # --stdout option only available in 3.35 and onwards; too breaking to use without it, so don't alias if it's not available
        alias ccat='highlight --out-format=ansi --stdout --force'
        alias cat='ccat'
    fi
fi
if $(which 'src-hilite-lesspipe.sh' &> /dev/null) ; then
    export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
    export LESS=' -R '
fi
if $(which 'youtube-dl' &> /dev/null) ; then
    alias youtube-dl='youtube-dl --add-metadata -ic'
fi
if $(which 'sxiv' &> /dev/null) ; then
    alias sxiv='sxiv -a'
fi
if $(which 'desmume' &> /dev/null) ; then
    alias sxiv='desmume --cpu-mode=1'
fi
