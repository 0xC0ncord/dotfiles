#!/bin/bash

# Set GIT_DISCOVERY_ACROSS_FILESYSTEM to ensure git prompt works beyond filesystem boundaries
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# PS1 generation
make_ps1() {
    # PS1 itself
    p="\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;33m\]\$(git_prompt) \[\033[01;34m\]\\$\[\033[00m\] "

    # PS1 but parsed and ANSI sequences removed; for length calculation
    pc=$(echo "${p@P}" | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b)

    # If we don't have much room for typing, use the 2-line prompt
    if [[ $(tput cols) -le $((${#pc} + 48)) ]]; then
        ps1="\[\033[01;34m\]╭\[\033[00m\] $(echo $p | sed 's/\ \([0-9;\[\$]*m\\\]\)*$//')\n\[\033[01;34m\]╰╼ \$\[\033[00m\] "
    else
        ps1="$p"
    fi
    echo "${ps1@P}"
}

# Git prompt
git_prompt() {
    if $(which 'git' &> /dev/null); then
        TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null)"
        if [[ -n "$TOPLEVEL" && $(basename "$TOPLEVEL" 2>/dev/null) != $(whoami) ]]; then
            if [[ -z "$(git branch)" ]]; then
                printf " (master, empty)"
            else
                printf " ($(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
                if [[ -n "$(git status -s -uno)" ]]; then printf " *"; fi
                if [[ -n "$(git rev-parse --short HEAD 2>/dev/null)" ]]; then printf ", $(git rev-parse --short HEAD | sed -e 's/\(.*\)/\1\)/')"; fi
            fi
        fi
    fi
}

export PS1="\$(make_ps1)"
