#!/usr/bin/env bash

set -o errexit

if [[ $# -ne 1 ]]; then
    echo >&2 "Usage: $0 GRASS_COMMAND"
    exit 1
fi

GRASS_COMMAND="$1"

"$GRASS_COMMAND" --tmp-location EPSG:4326 --exec g.region res=0.1 -p
