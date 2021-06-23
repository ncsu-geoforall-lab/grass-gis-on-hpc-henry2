#!/usr/bin/env bash

set -o errexit

if [[ $# -ne 5 ]]; then
    echo >&2 "Usage: $0 CONDA_DIR GRASS_REPO_DIR MODULE_FILES_DIR MODULE_VERSION CLONED_VERSION"
    exit 1
fi

CONDA_DIR="$1"
GRASS_REPO_DIR="$2"
MODULE_FILES_DIR="$3"
MODULE_VERSION="$4"
CLONED_VERSION="$5"

# Resolve paths
# Record absolute path
MODULE_FILES_DIR=$(realpath -s "$MODULE_FILES_DIR")
# We write to user's current directory, but use cd.
RECORD_DIR=$(pwd)

METADATA_DIR="$RECORD_DIR/installed/$MODULE_VERSION"
METADATA_FILE="$METADATA_DIR/metadata.yml"

mkdir -p "$METADATA_DIR"

conda env export --prefix "$CONDA_DIR" >"$METADATA_DIR/environment.yml"

cd "$GRASS_REPO_DIR"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT=$(git rev-parse HEAD)

cat >"$METADATA_FILE" <<EOF
module_version: $MODULE_VERSION
module_use: $MODULE_FILES_DIR
cloned_version: $CLONED_VERSION
branch: $BRANCH
commit: $COMMIT
EOF

LOCAL_CHANGES=$(git status --porcelain | sed 's/^/  /')

if [[ "$LOCAL_CHANGES" ]]; then
    cat >>"$METADATA_FILE" <<EOF
local_changes: |
$LOCAL_CHANGES
EOF
    git diff >"$METADATA_DIR/local_changes.diff"
else
    cat >>"$METADATA_FILE" <<EOF
local_changes: null
EOF
fi
