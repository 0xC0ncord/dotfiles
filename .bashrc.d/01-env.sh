#!/usr/bin/env bash

main() {
    stty -ixon                                                  # Disable CTRL-S and CTRL-Q
    shopt -s autocd                                             # Allows cding into a directory by just typing its name
    set -o vi                                                   # Enable bash VI mode
    export HISTSIZE= HISTFILESIZE=                              # Infinite history
    shopt -s histappend                                         # Append to the history, don't overwrite it
    if [[ -z ${PROMPT_COMMAND} ]]; then                         # Append to the history immediately after every command
        export PROMPT_COMMAND="history -a"
    elif [[ "${PROMPT_COMMAND}" != *"history -a"* ]]; then
        export PROMPT_COMMAND="history -a;${PROMPT_COMMAND}"
    fi

    export PATH="$PATH:/usr/local/bin:/usr/share/bin:$HOME/.local/bin"
    export GOPATH="$HOME/.go"

    # Various options to force applications to use XDG and avoid $HOME clutter
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$HOME/.local/run}"

    export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
    export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
    export LESSKEY="$XDG_CONFIG_HOME"/less/lesskey
    export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
    export ICEAUTHORITY="$XDG_CACHE_HOME"/ICEauthority
    export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
    export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass
    export VIMINIT=":source $XDG_CONFIG_HOME"/vim/vimrc
    export WGETRC="$XDG_CONFIG_HOME/wgetrc"
    export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
}
