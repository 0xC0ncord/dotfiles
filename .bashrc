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

# .bashrc.d
BASHRC_SCRIPTS=$HOME/.bashrc.d/*.sh
# Pre-scripts
for FILE in $BASHRC_SCRIPTS ; do
    source "$FILE"
    if declare -F pre &>/dev/null; then
        pre
    fi
    if declare -F main &>/dev/null; then
        main
    fi
    if declare -F post &>/dev/null; then
        post
    fi
    unset pre
    unset main
    unset post
done
unset BASHRC_SCRIPTS

# .profile.d
PROFILE_SCRIPTS=$HOME/.profile.d/*.sh
# Pre-scripts
for FILE in $PROFILE_SCRIPTS ; do
    source "$FILE"
    if declare -F pre &>/dev/null; then
        pre
    fi
    if declare -F main &>/dev/null; then
        main
    fi
    if declare -F post &>/dev/null; then
        post
    fi
    unset pre
    unset main
    unset post
done
unset PROFILE_SCRIPTS
