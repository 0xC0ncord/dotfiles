#!/bin/bash

# if this is a remote session, quit
[ -z $SSH_TTY ] || return

# check for existing running agent info
if [[ -e $HOME/.gpg-agent-info ]]; then
    source $HOME/.gpg-agent-info
    export GPG_AGENT_INFO SSH_AUTH_SOCK SSH_AGENT_PID
fi

# test existing agent, remove info file if not working
ssh-add -L 2>/dev/null >/dev/null || rm -f $HOME/.gpg-agent-info

# if no info file, start up potentially-new, working agent
if [[ ! -e $HOME/.gpg-agent-info ]]; then
    # kill broken agent first
    kill $(pgrep gpg-agent) 2>/dev/null
    if which gpg-agent >/dev/null 2>&1 ; then
        [ -z $SSH_TTY ] || export GPG_TTY=$(tty)
        gpg-agent \
            --enable-ssh-support \
            --daemon \
            --pinentry-program $(which pinentry) \
            2> /dev/null > $HOME/.gpg-agent-info
    fi
fi

# load up new agent info
if [[ -e $HOME/.gpg-agent-info ]]; then
    source $HOME/.gpg-agent-info
    export GPG_AGENT_INFO SSH_AUTH_SOCK SSH_AGENT_PID
fi
