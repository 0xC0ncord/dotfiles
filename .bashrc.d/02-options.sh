#!/bin/sh

stty -ixon                      # Disable CTRL-S and CTRL-Q
shopt -s autocd                 # Allows cding into a directory by just typing its name
set -o vi                       # Enable bash VI mode
export HISTSIZE= HISTFILESIZE=  # Infinite history
shopt -s histappend             # Append to the history, don't overwrite it

export PATH="$PATH:/usr/local/bin:/usr/share/bin:$HOME/.local/bin"
export GOPATH="$HOME/.go"
