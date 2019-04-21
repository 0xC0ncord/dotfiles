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

if $(which 'gpgconf' &> /dev/null); then
    export GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --launch gpg-agent &> /dev/null
fi

# Set proper TERM, if required
if $(which 'infocmp' &> /dev/null) && $(which 'tic' &>/dev/null) && ! $(infocmp &>/dev/null) ; then
    case $TERM in
        "xterm-termite")

            # Install termite's terminfo if possible
            if $(which 'curl' &> /dev/null) ; then
                { curl 'https://raw.githubusercontent.com/thestinger/termite/master/termite.terminfo' -o termite.terminfo && \
                tic -x termite.terminfo && \
                rm termite.terminfo && \
                echo "Info: successfully installed termite.terminfo" ; } || { echo "Warning: error while installing termite.terminfo, falling back to xterm-256color" && export TERM='xterm-256color' ; }
            else
                echo "Warning: could not install termite.terminfo because 'curl' not found in PATH, falling back to xterm-256color"
                export TERM='xterm-256color'
            fi
            ;;
        *)
            echo "Warning: unsupported TERM $TERM"
            ;;
    esac
fi

alias ls='ls -hN --color=auto --group-directories-first'
alias grep='grep --color=auto'

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
if $(which 'youtube-dl' &> /dev/null) ; then
    alias youtube-dl='youtube-dl --add-metadata -ic'
fi
if $(which 'sxiv' &> /dev/null) ; then
    alias sxiv='sxiv -a'
fi
if $(which 'desmume' &> /dev/null) ; then
    alias sxiv='desmume --cpu-mode=1'
fi

# PS1 generation
make_ps1() {
    # PS1 itself
    p="\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;33m\]\$(git_prompt) \[\033[01;34m\]\$\[\033[00m\] "

    # PS1 but parsed and ANSI sequences removed; for length calculation
    pc=$(echo "${p@P}" | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b)

    # If we don't have much room for typing, use the 2-line prompt
    if [[ $(tput cols) -le $((${#pc} + 48)) || ${#pc} -gt 60 ]]; then
        ps1="\[\033[01;34m\]╭\[\033[00m\] $(echo $p | sed 's/\ \([0-9;\[\$]*m\\\]\)*$//')\n\[\033[01;34m\]╰╼ \$\[\033[00m\] "
    else
        ps1="$p"
    fi
    echo "${ps1@P}"
}

# Git prompt
git_prompt() {
    if $(which 'git' &> /dev/null) && [[ $(basename $(git rev-parse --show-toplevel)) != $(whoami) ]]; then
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    fi
}

export PS1="\$(make_ps1)"
