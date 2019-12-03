#!/bin/sh

alias ls='ls -hN --color=auto --group-directories-first'
alias grep='grep --color=auto'

alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias cp='cp -iv'
alias mv='mv -iv'
alias myextip='curl http://ipecho.net/plain && printf "\n"'
alias vi='vim'

# The below aliases require additional dependencies
if $(which 'highlight' &> /dev/null) ; then
    alias ccat='highlight --out-format=ansi --stdout --force'
    alias cat='ccat'
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

