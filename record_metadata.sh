#!/usr/bin/env bash

set -o errexit

if [[ $# -ne 7 ]]; then
    echo >&2 "Usage: $0 CONDA_DIR GRASS_REPO_DIR MODULE_FILES_DIR MODULE_NAME MODULE_VERSION SOURCE_REPO CLONED_VERSION"
    exit 1
fi

CONDA_DIR="$1"
GRASS_REPO_DIR="$2"
MODULE_FILES_DIR="$3"
MODULE_NAME="$4"
MODULE_VERSION="$5"
SOURCE_REPO="$6"
CLONED_VERSION="$7"

# Resolve paths
# Record absolute path
MODULE_FILES_DIR=$(realpath -s "$MODULE_FILES_DIR")
# We write to user's current directory, but use cd.
RECORD_DIR=$(pwd)

METADATA_DIR="$RECORD_DIR/available/$MODULE_VERSION"
METADATA_FILE="$METADATA_DIR/metadata.yml"

mkdir -p "$METADATA_DIR"

conda env export --prefix "$CONDA_DIR" >"$METADATA_DIR/environment.yml"

cd "$GRASS_REPO_DIR"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT=$(git rev-parse HEAD)

cat >"$METADATA_FILE" <<EOF
module_name: $MODULE_NAME
module_version: $MODULE_VERSION
module_use: $MODULE_FILES_DIR
module_load: $MODULE_NAME/$MODULE_VERSION
module_example: |
  module use --append $MODULE_FILES_DIR
  module load $MODULE_NAME/$MODULE_VERSION
cloned_version: $CLONED_VERSION
branch: $BRANCH
commit: $COMMIT
repo: $SOURCE_REPO
EOF

# Get list of local changes and add a space to get two-space indent.
LOCAL_CHANGES=$(git status --porcelain | sed 's/^/ /')

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
