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
    if [[ $(printf $FILE | grep '_pre\.sh$') ]]; then
        source "$FILE"
    fi
done
# Main scripts
for FILE in $BASHRC_SCRIPTS ; do
    if [[ ! $(printf $FILE | grep '_pre\.sh$') ]] && [[ ! $(printf $FILE | grep '_post\.sh$') ]]; then
        source "$FILE"
    fi
done
# Post-scripts
for FILE in $BASHRC_SCRIPTS ; do
    if [[ $(printf $FILE | grep '_post\.sh$') ]]; then
        source "$FILE"
    fi
done
unset BASHRC_SCRIPTS

# .profile.d
PROFILE_SCRIPTS=$HOME/.profile.d/*.sh
# Pre-scripts
for FILE in $PROFILE_SCRIPTS ; do
    if [[ $(printf $FILE | grep '_pre\.sh$') ]]; then
        source "$FILE"
    fi
done
# Main scripts
for FILE in $PROFILE_SCRIPTS ; do
    if [[ ! $(printf $FILE | grep '_pre\.sh$') ]] && [[ ! $(printf $FILE | grep '_post\.sh$') ]]; then
        source "$FILE"
    fi
done
# Post-scripts
for FILE in $PROFILE_SCRIPTS ; do
    if [[ $(printf $FILE | grep '_post\.sh$') ]]; then
        source "$FILE"
    fi
done
unset PROFILE_SCRIPTS
