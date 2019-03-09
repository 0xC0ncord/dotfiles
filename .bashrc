# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.

stty -ixon              # Disable CTRL-S and CTRL-Q
shopt -s autocd         # Allows cding into a directory by just typing its name
set -o vi               # Enable bash VI mode
HISTSIZE= HISTFILESIZE= # Infinite history
PATH="$PATH:/usr/local/bin:/usr/share/bin:$HOME/.local/bin"

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

alias ls='ls -hN --color=auto --group-directories-first'
alias grep='grep --color=auto'
alias youtube-dl='youtube-dl --add-metadata -ic'

alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias cp='cp -iv'
alias mv='mv -iv'
alias myextip='curl http://ipecho.net/plain && printf "\n"'
alias vi='vim'

# The below aliases require additional dependencies
if $(which 'highlight' &> /dev/null) ; then
    alias ccat='highlight --out-format=ansi --stdout --force'
    alias cat='ccat'
fi
