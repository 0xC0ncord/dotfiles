#!/bin/bash

# Set GIT_DISCOVERY_ACROSS_FILESYSTEM to ensure git prompt works beyond filesystem boundaries
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# Helper functions
_sed_escape() {
    echo "$1" | sed 's/[&\\/]/\\&/g;s/$/\\/;$s/\\$//;s/ /\\ /g'
}

# SELinux prompt
_selinux_prompt() {
    local CONTEXT="$(id -Z 2>/dev/null)"
    if [[ $? == 0 ]]; then
        printf " ($(printf ${CONTEXT} | awk -F: '{print $3}'))"
    fi
}

# Git prompt
_git_prompt() {
    if $(which 'git' &> /dev/null); then
        local TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null)"
        if [[ -n "$TOPLEVEL" && $(basename "$TOPLEVEL" 2>/dev/null) != $(whoami) ]]; then
            if [[ -z "$(git branch)" ]]; then
                printf " (master, empty)"
            else
                printf " ($(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
                if [[ -n "$(git diff --shortstat)" ]]; then GIT_SYMBOLS="*"; fi
                if [[ -n "$(git ls-files ${TOPLEVEL} --exclude-standard --others)" ]]; then GIT_SYMBOLS="${GIT_SYMBOLS}%%"; fi
                if [[ -n "${GIT_SYMBOLS}" ]]; then printf " ${GIT_SYMBOLS}"; fi
                if [[ -n "$(git rev-parse --short HEAD 2>/dev/null)" ]]; then printf ", $(git rev-parse --short HEAD | sed -e 's/\(.*\)/\1\)/')"; fi
            fi
        fi
    fi
}

# PS1 generation
_make_PS1() {
    # PS1 itself
    if [[ $EUID -eq 0 ]]; then
        # Root's prompt
        local P="\[\033]0;\h:\w\007\]\[\033[01;31m\]\h\[\033[01;34m\] \w\[\033[01;35m\]\$(_selinux_prompt)\[\033[01;33m\]\$(_git_prompt) \[\033[01;34m\]\\$\[\033[00m\] "
    else
        # User prompt
        local P="\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;35m\]\$(_selinux_prompt)\[\033[01;33m\]\$(_git_prompt) \[\033[01;34m\]\\$\[\033[00m\] "
    fi

    # PS1 but parsed and ANSI sequences removed; for length calculation
    if [[ ${BASH_VERSION:0:1} -lt 4 ]] || [[ ${BASH_VERSION:2:1} -lt 4 ]]; then
        # @P operation is unsupported in Bash < 4.4
        local PC=$(echo ${P} | sed "s/\\\\\[\\\033.*\\\007\\\\\]//g;s/\\\\\[\\\033\\[\([0-9]\{2\};\)\?[0-9]\{2\}m\\\]//g;s/\\\u/$USER/g;s/\\\h/$(hostname)/g;s/\\\w/$(_sed_escape $(dirs +0))/g;s/\\$\x28_selinux_prompt\x29\\$\x28_git_prompt\x29/$(_sed_escape "$(_selinux_prompt) $(_git_prompt)")/g;s/\\\\\\$/$/g")
    else
        local PC=$(echo "${P@P}" | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b)
    fi

    # If we don't have much room for typing, use the 2-line prompt
    # TODO truncate if still too long
    local COLS=$(tput cols)
    if [[ ${COLS} -le $((${#PC} + 48)) ]]; then
        PS1="\[\033[01;34m\]╭\[\033[00m\] $(echo ${P} | sed 's/\ \([0-9;\[\$]*m\\\]\)*$//')\[\033[00m\]\n\[\033[01;34m\]╰╼ \$\[\033[00m\] "
    else
        PS1="${P}"
    fi

    export PS1
}

if [[ -z ${PROMPT_COMMAND} ]]; then
    export PROMPT_COMMAND="_make_PS1"
elif [[ "${PROMPT_COMMAND}" != *"_make_PS1"* ]]; then
    export PROMPT_COMMAND="${PROMPT_COMMAND};_make_PS1"
fi
