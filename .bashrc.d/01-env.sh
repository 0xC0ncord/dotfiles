#!/usr/bin/env bash

function _append_to_path {
    if [[ $PATH != *"$1"* ]]; then
        export PATH="$PATH:$1"
    fi
}

function main {
    stty -ixon                          # Disable CTRL-S and CTRL-Q
    shopt -s autocd                     # Allows cding into a directory by just typing its name
    set -o vi                           # Enable bash VI mode
    export HISTSIZE= HISTFILESIZE=      # Infinite history
    export HISTCONTROL=ignoreboth       # Ignore history when prepended with whitespace

    _append_to_path /usr/local/bin
    _append_to_path /usr/share/bin
    _append_to_path $HOME/.local/bin
    export GOPATH="$HOME/.go"

    # Various options to force applications to use XDG and avoid $HOME clutter
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
    export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
    if [[ -z "$XDG_RUNTIME_DIR" ]]; then
        if [[ -d /run/user/$UID ]]; then
            export XDG_RUNTIME_DIR="/run/user/$UID"
        else
            export XDG_RUNTIME_DIR="$HOME/.local/run"
        fi
    fi
    export XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
    export XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
    export XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
    export XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
    export XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
    export XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$HOME/Public}"
    export XDG_SCREENSHOTS_DIR="${XDG_SCREENSHOTS_DIR:-$XDG_PICTURES_DIR/Screenshots}"
    export XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$HOME/Templates}"
    export XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"

    export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
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
    export WEECHAT_HOME="$XDG_DATA_HOME"/weechat
    export TEXMFHOME="$XDG_DATA_HOME"/texmf
    export MBSYNCRC="$XDG_CONFIG_HOME"/mbsyncrc

    unset _append_to_path
}
