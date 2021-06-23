#!/usr/bin/env bash

set -o errexit

if [[ $# -ne 3 ]]; then
    echo >&2 "Usage: $0 GRASS_COMMAND GRASS_SOURCE_CODE DATA_DIR"
    exit 1
fi

GRASS_COMMAND="$1"
GRASS_SOURCE_CODE="$2"
DATABASE="$3"

"$GRASS_COMMAND" --tmp-location XY --exec \
    g.extension g.download.location
"$GRASS_COMMAND" --tmp-location XY --exec \
    g.download.location url=http://fatra.cnr.ncsu.edu/data/nc_spm_full_v2alpha2.tar.gz dbase="$DATABASE"

cd "$GRASS_SOURCE_CODE"

"$GRASS_COMMAND" --tmp-location XY --exec \
    python3 -m grass.gunittest.main \
    --grassdata "$DATABASE" --location nc_spm_full_v2alpha2 --location-type nc \
    --min-success 50
