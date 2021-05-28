#!/usr/bin/env bash

# This script is very Henry2-specific, so it can and should contain
# specific paths used for the installation and be usable as is
# with minimal parameters.

set -o errexit

if [[ $# -ne 3 ]]; then
    echo >&2 "Usage: $0 VERSION_WITH_DOTS COLLAPSED_VERSION BRANCH_OR_TAG"
    echo >&2 "Examples:"
    echo >&2 "  $0 7.8 78 7.8.5"
    echo >&2 "  $0 7.9 79 master"
    echo >&2 "  $0 7.8 78 releasebranch_7_8"
    exit 1
fi

# Hardcoded paths
GRASS_INSTALL_REPO=/usr/local/usrapps/mitasova/grass-gis-on-hpc-henry2
BASE_DIR=/usr/local/usrapps/mitasova/grass_installs/
MODULE_FILES_DIR=/usr/local/usrapps/mitasova/grass_installs/modulefiles
SYSTEM_CONDA_BIN=/usr/local/apps/miniconda/condabin
GRASS_SYMLINK_BASE=/usr/local/usrapps/mitasova/grass_versions

# The version-specific code is in a function with arguments being the version-specific
# parts and global variables the common ones. This is mostly for documentation
# purposes.
install_version() {
    local GRASS_DOT_VERSION="$1"
    local GRASS_COLLAPSED_VERSION="$2"
    local GRASS_GIT_VERSION="$3"

    local CONDA_PREFIX="$BASE_DIR"/grass
    local INSTALL_PREFIX="$CONDA_PREFIX"

    conda env create --file $GRASS_INSTALL_REPO/environment.yml --prefix $CONDA_PREFIX
    export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
    ./compile.sh "$GRASS_GIT_VERSION" "$CONDA_PREFIX" "$INSTALL_PREFIX"

    if [ ! -f "$INSTALL_PREFIX/bin/grass" ]; then
        mkdir -p "$GRASS_SYMLINK_BASE/$GRASS_DOT_VERSION"
        ln -s \
            "$INSTALL_PREFIX/bin/grass$GRASS_CONDA_VERSION" \
            "$GRASS_SYMLINK_BASE/$GRASS_DOT_VERSION/grass"
    fi

    ./create_modulefile.sh \
        "$SYSTEM_CONDA_BIN" \
        "$CONDA_PREFIX" \
        "$INSTALL_PREFIX" \
        "$GRASS_COLLAPSED_VERSION" \
        "$GRASS_SYMLINK_BASE" \
        >"$MODULE_FILES_DIR/$GRASS_DOT_VERSION"
}

module load gcc
module load conda

mkdir -p $GRASS_SYMLINK_BASE

install_version "$1" "$2" "$3"
