#!/usr/bin/env bash

function bashquote {
    echo "# Type a message and press CTRL-C to finish."
    printf '%q\n' "$(cat)"
}
