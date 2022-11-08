#!/usr/bin/env bash

# This script is very Henry2-specific, so it can and should contain
# specific paths used for the installation and be usable as is
# with minimal parameters.

# Assumes it is executed from the clone of the repository
# (where the scripts and other files are).

set -o errexit

if [[ $# -ne 4 ]]; then
    echo >&2 "Usage: $0 INSTALL_DIR VERSION_WITH_DOTS COLLAPSED_VERSION BRANCH_OR_TAG"
    echo >&2 "Examples:"
    echo >&2 "  $0 /your/path 7.8.5 78 7.8.5"
    echo >&2 "  $0 /your/path 7.9 79 main"
    echo >&2 "  $0 /your/path 7.8-\$(date -I) 78 releasebranch_7_8"
    echo >&2 "  $0 /your/path 8.0-$(date -I) 80 main"
    exit 1
fi

# Paths
GRASS_INSTALL_REPO="$(pwd)"
BASE_DIR="$1"
MODULE_FILES_BASE_DIR="$BASE_DIR/modulefiles"
MODULE_NAME="grass"
MODULE_FILES_DIR="$MODULE_FILES_BASE_DIR/$MODULE_NAME"
SYSTEM_CONDA_BIN="/usr/local/apps/miniconda/condabin"

SOURCE_REPO="https://github.com/OSGeo/grass.git"

# The version-specific code is in a function with arguments being the version-specific
# parts and global variables the common ones. This is mostly for documentation
# purposes.
install_version() {
    local GRASS_DOT_VERSION="$1"
    local GRASS_COLLAPSED_VERSION="$2"
    local GRASS_GIT_VERSION="$3"

    local CODE_DIR="$GRASS_INSTALL_REPO/grass-code-$GRASS_DOT_VERSION"
    local CONDA_PREFIX="$BASE_DIR/grass-$GRASS_DOT_VERSION"
    local INSTALL_PREFIX="$CONDA_PREFIX"

    conda env create --file "$GRASS_INSTALL_REPO/available/8.3-2022-05-25/environment.yml" --prefix "$CONDA_PREFIX"
    export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
    conda activate "$CONDA_PREFIX"
    "$GRASS_INSTALL_REPO/compile.sh" \
        "$CODE_DIR" \
        "$SOURCE_REPO" \
        "$GRASS_GIT_VERSION" \
        "$CONDA_PREFIX" \
        "$INSTALL_PREFIX"

    if [ ! -f "$INSTALL_PREFIX/bin/grass" ]; then
        echo >&2 "Plain grass command not in bin, creating symlink"
        ln -sfn \
            "$(realpath -sm "$INSTALL_PREFIX/bin/grass$GRASS_COLLAPSED_VERSION")" \
            "$INSTALL_PREFIX/bin/grass"
    else
        echo >&2 "Plain grass command is in bin, assuming symlink is not needed"
    fi

    "$GRASS_INSTALL_REPO/create_module_file.sh" \
        "$SYSTEM_CONDA_BIN" \
        "$CONDA_PREFIX" \
        "$INSTALL_PREFIX" \
        >"$MODULE_FILES_DIR/$GRASS_DOT_VERSION"

    "$GRASS_INSTALL_REPO/record_metadata.sh" \
        "$CONDA_PREFIX" \
        "$CODE_DIR" \
        "$MODULE_FILES_BASE_DIR" \
        "$MODULE_NAME" \
        "$GRASS_DOT_VERSION" \
        "$SOURCE_REPO" \
        "$GRASS_GIT_VERSION"
}

module load gcc/9.3.0
module load conda

eval "$(conda shell.bash hook)"

mkdir -p "$BASE_DIR"
mkdir -p "$MODULE_FILES_DIR"

install_version "$2" "$3" "$4"
