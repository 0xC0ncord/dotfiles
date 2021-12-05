#!/usr/bin/env bash

# Helper functions
#function _sed_escape {
#    echo "$1" | sed 's/[&\\/]/\\&/g;s/$/\\/;$s/\\$//;s/ /\\ /g'
#}

# SELinux prompt
function _selinux_prompt {
    if [[ -d /sys/fs/selinux ]] && [[ -e /proc/$$/attr/current ]]; then
        printf "($(cut -d: -f3 <<< $(tr -d '\0' </proc/$$/attr/current)))"
    fi
}

# Git prompt
function _git_prompt {
    local TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ $? && -n $TOPLEVEL && $TOPLEVEL != $HOME ]]; then
        if [[ $_GITVER < 2200 ]]; then
            local BRANCH="$(git branch | sed -n '/^\*/s/\* \(.*\)/\1/p')"
        else
            local BRANCH="$(git branch --show-current 2>/dev/null)"
        fi
        if [[ -z $BRANCH ]]; then
            local BRANCH="[$(sed -e '/^[^*]/d;s/^\* (\?\(.*\)))\?/\1/' <<< "$(git branch 2>/dev/null)" | tr -d '\n')]"
        fi
        local STATUS="$(git status --porcelain)"
        printf "($BRANCH"
        grep '^ \?M' &>/dev/null <<< "$STATUS" && GIT_SYMBOLS="*"
        grep '^??' &>/dev/null <<< "$STATUS" && GIT_SYMBOLS="${GIT_SYMBOLS}%%"
        git rev-list --walk-reflogs --count refs/stash &>/dev/null && GIT_SYMBOLS="${GIT_SYMBOLS}#"
        [[ -n "${GIT_SYMBOLS}" ]] && printf " ${GIT_SYMBOLS}"
        printf ", $(git rev-parse --short HEAD 2>/dev/null || printf 'empty'))"
    fi
}

# PS1 generation
function _make_PS1 {
    local COLS=$(tput cols)
    local D=$'\u200b'
    local ND=2
    # Do not add title on TTYs
    if [[ $TERM != "linux" ]]; then
        # Title is added last and does not affect the prompt in any way
        local TITLE="\[\033]0;\u@\h:\w\007\]"
    fi

    # Set up fields and colors
    if [[ $EUID -eq 0 ]]; then
        local C0="\033[01;31m"
        local HOST="\h"
    else
        local C0="\033[01;32m"
        local HOST="\u@\h"
    fi
    local C1="\033[01;34m"
    local C2="\033[01;35m"
    local C3="\033[01;33m"
    local DIR="\w"
    local SELINUX="$(_selinux_prompt)"
    local GIT="$(_git_prompt)"

    # Render fields
    HOST="${HOST@P}"
    DIR="${DIR@P}"

    # Join the prompt together
    PS1="${D}0${HOST} ${D}1${DIR}"
    [[ -n "${SELINUX}" ]] && PS1="${PS1} ${D}2${SELINUX}" && ND=$((ND+1))
    [[ -n "${GIT}" ]] && PS1="${PS1} ${D}3${GIT}" && ND=$((ND+1))

    # Get prompt length
    local N_PS1=$((${#PS1} - (${ND} * 2)))

    # See if we need to wrap typing to the second line
    if [[ $((N_PS1 + 48)) -gt ${COLS} ]] || [[ ${N_PS1} -gt $((COLS / 3 * 2)) ]]; then
        ND=$((ND+1))
        N_PS1=$((N_PS1+4))
        PS1="${D}1╭ ${PS1}"
        # Test if the prompt should be ellipsized
        if [[ ${N_PS1} -gt ${COLS} ]]; then
            # 2 characters per delimeter
            local IN=$((COLS + (ND * 2) - 1))
            # Trim prompt
            PS1="${PS1:0:$IN}"
            # Test if some delimeters were removed and adjust
            local N="${PS1//[^${D}]}"
            N="${#N}"
            PS1="${PS1:0:$((IN - (ND - N) * 2))}"
            # Trim ending delimeter if it exists
            [[ ${PS1} == "*${D}" ]] && PS1="${PS1::-1}"
            # Add elipsis
            PS1="${PS1}…"
        fi
        PS1="${PS1}\n${D}1╰╼ \$\033[00m "
    else
        PS1="${PS1} ${D}1\$\033[00m "
    fi

    # Replace delimiters with colors
    PS1="${PS1//${D}0/${C0}}"
    PS1="${PS1//${D}1/${C1}}"
    PS1="${PS1//${D}2/${C2}}"
    PS1="${PS1//${D}3/${C3}}"
    # Render and add title
    export PS1="${TITLE}${PS1@P}"
}

function main {
    # Set GIT_DISCOVERY_ACROSS_FILESYSTEM to ensure git prompt works beyond filesystem boundaries
    export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

    if command -v git &>/dev/null; then
        export _GITVER=$(git --version | sed 's/[^0-9]//g')
    else
        export _GITVER=
    fi

    if [[ -z ${PROMPT_COMMAND} ]]; then
        export PROMPT_COMMAND="_make_PS1"
    elif [[ "${PROMPT_COMMAND}" != *"_make_PS1"* ]]; then
        export PROMPT_COMMAND="${PROMPT_COMMAND};_make_PS1"
    fi
}
