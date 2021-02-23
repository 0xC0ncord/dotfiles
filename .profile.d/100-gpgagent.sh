#!/usr/bin/env bash

# Runs a command under an alarm
function doalarm { perl -e 'alarm shift; exec @ARGV' "$@"; }

function main {
    # if this is a remote or nested session, quit
    if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || "$(basename "$(ps -p $PPID -o command=)")" =~ "^(bash|newrole|sudo)$" ]]; then
        return
    fi

    # check for existing running agent info
    if [[ -e $HOME/.gpg-agent-info ]]; then
        source $HOME/.gpg-agent-info
        export GPG_AGENT_INFO SSH_AUTH_SOCK SSH_AGENT_PID
    fi

    # test existing agent, remove info file if not working
    doalarm 2 ssh-add -L &>/dev/null || rm -f $HOME/.gpg-agent-info

    # if no info file, start up potentially-new, working agent
    if [[ ! -e $HOME/.gpg-agent-info ]]; then
        # kill broken agent first
        kill $(pgrep -U $UID gpg-agent) 2>/dev/null
        if command -v gpg-agent >/dev/null; then
            [ -z $SSH_TTY ] || export GPG_TTY=$(tty)
            gpg-agent \
                --enable-ssh-support \
                --daemon \
                --pinentry-program $(command -v pinentry) \
                2>/dev/null >$HOME/.gpg-agent-info
        fi
    fi

    # load up new agent info
    if [[ -e $HOME/.gpg-agent-info ]]; then
        source $HOME/.gpg-agent-info
        export GPG_AGENT_INFO SSH_AUTH_SOCK SSH_AGENT_PID
        gpg-connect-agent updatestartuptty /bye &>/dev/null
    fi

    unset doalarm
}
