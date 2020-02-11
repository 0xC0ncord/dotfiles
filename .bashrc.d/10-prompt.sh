#!/bin/bash

# Set GIT_DISCOVERY_ACROSS_FILESYSTEM to ensure git prompt works beyond filesystem boundaries
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# PS1 generation
make_PS1() {
    # PS1 itself
    if [[ $EUID -eq 0 ]]; then
        # Root's prompt
	P="\[\033]0;\h:\w\007\]\[\033[01;31m\]\h\[\033[01;34m\] \w\[\033[01;33m\]\$(git_prompt) \[\033[01;34m\]\\$\[\033[00m\] "
    else
        # User prompt
	P="\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;33m\]\$(git_prompt) \[\033[01;34m\]\\$\[\033[00m\] "
    fi

    # PS1 but parsed and ANSI sequences removed; for length calculation
    if [[ ${BASH_VERSION:0:1} -lt 4 ]] || [[ ${BASH_VERSION:2:1} -lt 4 ]]; then
        # @P operation is unsupported in Bash < 4.4
        PC=$(echo "${USER}@$(hostname) $(dirs +0)$(git_prompt) $")
    else
        PC=$(echo "${P@P}" | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b)
    fi

    # If we don't have much room for typing, use the 2-line prompt
    if [[ $(tput cols) -le $((${#PC} + 48)) ]]; then
        PS1="\[\033[01;34m\]╭\[\033[00m\] $(echo ${P} | sed 's/\ \([0-9;\[\$]*m\\\]\)*$//')\n\[\033[01;34m\]╰╼ \$\[\033[00m\] "
    else
        PS1="${P}"
    fi
    if [[ ${BASH_VERSION:0:1} -lt 4 ]] || ([[ ${BASH_VERSION:0:1} -eq 4 ]] && [[ ${BASH_VERSION:2:1} -lt 4 ]]); then
        # @P operation is unsupported in Bash < 4.4
        # Nasty hack to parse the prompt - slow!
        # FIXME: breaks when some special characters are used in commands (i.e. '!')
        export PS1="${PS1}"
        export -f git_prompt
        echo "$(bash --rcfile <(echo "PS1='$PS1'") -i <<<'' 2>&1 | sed ':;$!{N;b};s/^\(.*\)*\(.*\)\n\2exit$/\2/p;d')"
    else
        echo "${PS1@P}"
    fi
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

export PS1="\$(make_PS1)"
