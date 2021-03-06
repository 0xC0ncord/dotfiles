#!/usr/bin/env bash

# Helper functions
_sed_escape() {
    echo "$1" | sed 's/[&\\/]/\\&/g;s/$/\\/;$s/\\$//;s/ /\\ /g'
}

# SELinux prompt
_selinux_prompt() {
    if [[ -e /proc/$$/attr/current ]]; then
        printf "($(awk -F: '{print $3}' <<< $(tr -d '\0' </proc/$$/attr/current)))"
    fi
}

# Git prompt
_git_prompt() {
    local TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ $? && -n $TOPLEVEL && $TOPLEVEL != $HOME ]]; then
        local BRANCH="$(git branch --show-current 2>/dev/null)"
        if [[ -z $BRANCH ]]; then
            BRANCH="[$(sed -e '/^[^*]/d;s/^\* (\?\(.*\)))\?/\1/' <<< "$(git branch 2>/dev/null)" | tr -d '\n')]"
        fi
        printf "($BRANCH"
        if [[ -n "$(git status --short -uno)" ]]; then GIT_SYMBOLS="*"; fi
        if [[ -n "$(git ls-files ${TOPLEVEL} --exclude-standard --others | sed 1q)" ]]; then GIT_SYMBOLS="${GIT_SYMBOLS}%%"; fi
        if [[ -n "$(git stash list)" ]]; then GIT_SYMBOLS="${GIT_SYMBOLS}#"; fi
        if [[ -n "${GIT_SYMBOLS}" ]]; then printf " ${GIT_SYMBOLS}"; fi
        printf ", $(git rev-parse --short HEAD 2>/dev/null || printf 'empty'))"
    fi
}

# PS1 generation
_make_PS1() {
    local COLS=$(tput cols)
    if [[ $TERM != "linux" ]]; then
        local TITLE="\\[\\033]0;\\u@\\h:\\w\\007\\]"
    else
        local TITLE=""
    fi
    if [[ $EUID -eq 0 ]]; then
        export PS1="$TITLE$(awk -v COLS=$COLS -v HOSTNAME=$HOSTNAME -v CWD="$(dirs +0)" -v SELINUX="$(_selinux_prompt)" -v GIT="$(_git_prompt)" 'BEGIN {
            P[0]=HOSTNAME
            P[1]=CWD
            P[2]=SELINUX
            P[3]=GIT
            C[0]="\\[\\033[01;31m\\]"
            C[1]="\\[\\033[01;34m\\]"
            C[2]="\\[\\033[01;35m\\]"
            C[3]="\\[\\033[01;33m\\]"
            for (i in P) {
                if (length(P[i]) != 0) {
                    R=R" "i""P[i]" "
                }
            }
            L=length(R)
            if (COLS + 3 < L) {
                R=substr(R,1,COLS - 1)"…"
            }
            for (i in P) {
                gsub(" "i, C[i], R)
            }
            if (COLS <= L + 48 || L > COLS * 0.66) {
                R=C[1]"╭ "R"\n"C[1]"╰╼ "
            }
            R=R""C[1]"$"
            printf R"\\[\\033[00m\\] "
        }')"
    else
        export PS1="$TITLE$(awk -v COLS=$COLS -v USER=$USER -v HOSTNAME=$HOSTNAME -v CWD="$(dirs +0)" -v SELINUX="$(_selinux_prompt)" -v GIT="$(_git_prompt)" 'BEGIN {
            P[0]=USER"@"HOSTNAME
            P[1]=CWD
            P[2]=SELINUX
            P[3]=GIT
            C[0]="\\[\\033[01;32m\\]"
            C[1]="\\[\\033[01;34m\\]"
            C[2]="\\[\\033[01;35m\\]"
            C[3]="\\[\\033[01;33m\\]"
            for (i in P) {
                if (length(P[i]) != 0) {
                    R=R"`"i""P[i]" "
                }
            }
            L=length(R)
            if (COLS + 3 < L) {
                R=substr(R,1,COLS - 1)"…"
            }
            for (i in P) {
                gsub("`"i, C[i], R)
            }
            if (COLS <= L + 48 || L > COLS * 0.66) {
                R=C[1]"╭ "R"\n"C[1]"╰╼ "
            }
            R=R""C[1]"$"
            printf R"\\[\\033[00m\\] "
        }')"
    fi
}

main() {
    # Set GIT_DISCOVERY_ACROSS_FILESYSTEM to ensure git prompt works beyond filesystem boundaries
    export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

    if [[ -z ${PROMPT_COMMAND} ]]; then
        export PROMPT_COMMAND="_make_PS1"
    elif [[ "${PROMPT_COMMAND}" != *"_make_PS1"* ]]; then
        export PROMPT_COMMAND="${PROMPT_COMMAND};_make_PS1"
    fi
}
