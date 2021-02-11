#!/usr/bin/env bash

function pre {
    export BLESH_ENABLE=1

    # Don't run if not enabled
    if [[ $BLESH_ENABLE -eq 0 ]]; then unset BLESH_ENABLE; return; fi

    # Attempt to clone and build ble.sh
    if [[ ! -d $HOME/.bashrc.d/submodules/ble.sh ]]; then
        if [[ $(which git) ]]; then
            {
                echo "Installing ble.sh…"
                git clone https://github.com/akinomyoga/ble.sh $HOME/.bashrc.d/submodules/ble.sh 2>&1 >/dev/null
                pushd $(pwd)
                cd $HOME/.bashrc.d/submodules/ble.sh
                git checkout v0.4.0-devel2>&1 >/dev/null
                make 2>&1 >/dev/null
                popd
            } || {
                echo "Failed to build ble.sh."
            }
        else
            echo "Git does not appear to be installed - cannot install ble.sh."
        fi
    fi

    # Source it, but don't attach until after all other scripts
    # ble.sh gets attached in the post script
    source $HOME/.bashrc.d/submodules/ble.sh/out/ble.sh --noattach
}

function post {
    # Don't run if not enabled
    if [[ $BLESH_ENABLE -eq 0 ]]; then unset BLESH_ENABLE; return; fi
    unset BLESH_ENABLE

    # Attach to session
    [[ ${BLE_VERSION-} ]] && ble-attach

    # Options
    bleopt complete_auto_complete=
    bleopt history_share=1              # Sync history to $HISTFILE after every command
}
