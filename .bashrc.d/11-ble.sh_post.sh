#!/bin/bash

# Don't run if not enabled
if [[ $BLESH_ENABLE -eq 0 ]]; then unset BLESH_ENABLE; return; fi
unset BLESH_ENABLE

# Attach to session
((_ble_bash)) && ble-attach

# Options
bleopt complete_auto_complete=
