#!/bin/sh

# Set proper TERM, if required
if $(which 'infocmp' &> /dev/null) && $(which 'tic' &>/dev/null) && ! $(infocmp &>/dev/null) ; then
    case $TERM in
        "xterm-termite")

            # Install termite's terminfo if possible
            if $(which 'curl' &> /dev/null) ; then
                { curl -s 'https://raw.githubusercontent.com/thestinger/termite/master/termite.terminfo' -o termite.terminfo && \
                tic -x termite.terminfo && \
                rm termite.terminfo && \
                reset && \
                source /etc/profile && \
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
