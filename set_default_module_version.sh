#!/usr/bin/env bash

# Creates the .version file for modules.
# Fails if the module file for the specified version does not exist.

set -o errexit

if [[ $# -ne 2 ]]; then
    echo >&2 "Usage: $0 MODULE_FILES_DIR GRASS_VERSION"
    exit 1
fi

MODULE_FILES_DIR="$1"
GRASS_VERSION="$2"

MODULE_FILE="$MODULE_FILES_DIR/$GRASS_VERSION"
MODULE_VERSION_FILE="$MODULE_FILES_DIR/.version"

if [ ! -d "$MODULE_FILE" ]; then
    echo >&2 "ERROR: Module file '$MODULE_FILE' does not exist"
    exit 1
fi

cat >"$MODULE_VERSION_FILE" <<EOF
#%Module

set ModulesVersion $GRASS_VERSION
EOF
