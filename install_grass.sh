#!/usr/bin/env bash

# This script is very Henry2-specific, so it can and should contain
# specific paths used for the installation and be usable as is
# with minimal parameters.

# Hardcoded paths
GRASS_INSTALL_REPO=/usr/local/usrapps/mitasova/grass-gis-on-hpc-henry2
BASE_DIR=/usr/local/usrapps/mitasova/grass_installs/
MODULE_FILES_DIR=/usr/local/usrapps/mitasova/grass_installs/modulefiles
SYSTEM_CONDA_BIN=/usr/local/apps/miniconda/condabin
GRASS_SYMLINK_BASE=/usr/local/usrapps/mitasova/grass_versions


install_version() {
	local $GRASS_DOT_VERSION="$1"
	local $GRASS_COLLAPSED_VERSION="$2"
    local GRASS_GIT_VERSION="$3"

    local CONDA_PREFIX="$BASE_DIR"/grass
    local INSTALL_PREFIX="$CONDA_PREFIX"

    conda env create --file $GRASS_INSTALL_REPO/environment.yml --prefix $CONDA_PREFIX
    export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
    ./compile.sh "$GRASS_GIT_VERSION" "$CONDA_PREFIX" "$INSTALL_PREFIX"

	if [ ! -f "$INSTALL_PREFIX/bin/grass" ]; then
	    mkdir -p $GRASS_SYMLINK_BASE/$GRASS_DOT_VERSION
	    ln -s \
	        "$INSTALL_PREFIX/bin/grass$GRASS_CONDA_VERSION" \
	        "$GRASS_SYMLINK_BASE/$GRASS_DOT_VERSION/grass"
	fi

    ./create_modulefile.sh \
        $SYSTEM_CONDA_BIN \
        $CONDA_PREFIX \
        $INSTALL_PREFIX \
        $GRASS_COLLAPSED_VERSION \
        $GRASS_SYMLINK_BASE \
        >$MODULE_FILES_DIR/$GRASS_DOT_VERSION
}

module load gcc
module load conda

mkdir -p $GRASS_SYMLINK_BASE

install_version "$1" "$2" "$3"
