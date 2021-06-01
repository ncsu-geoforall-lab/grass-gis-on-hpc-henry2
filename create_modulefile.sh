#!/usr/bin/env bash

set -o errexit

if [[ $# -ne 5 ]]; then
    echo >&2 "Usage: $0 SYSTEM_CONDA_BIN CONDA_ENV_PREFIX GRASS_INSTALL_PREFIX GRASS_VERSION GRASS_SYMLINK_BASE"
    exit 1
fi

SYSTEM_CONDA_BIN="$1"
CONDA_ENV_PREFIX="$2"
GRASS_INSTALL_PREFIX="$3"
GRASS_VERSION="$4"
GRASS_SYMLINK_BASE="$5"

cat <<EOF
#%Module
prepend-path PATH {$CONDA_ENV_PREFIX/bin};
prepend-path PATH {$SYSTEM_CONDA_BIN};
prepend-path PATH {$GRASS_INSTALL_PREFIX/bin};
EOF

SYMLINK_DIR="$GRASS_SYMLINK_BASE/$GRASS_VERSION"
if [ -d "$SYMLINK_DIR" ]; then
    echo >&2 "Adding symlink directory '$SYMLINK_DIR' to path"
    echo prepend-path PATH "{$SYMLINK_DIR};"
else
    echo >&2 "Symlink directory '$SYMLINK_DIR' does not exist, assuming it is not needed"
fi

cat <<EOF
prepend-path LD_LIBRARY_PATH {$GRASS_INSTALL_PREFIX/lib};

setenv CONDA_SHLVL 1;
setenv CONDA_PREFIX {$CONDA_ENV_PREFIX};
setenv CONDA_DEFAULT_ENV {$CONDA_ENV_PREFIX};
##setenv CONDA_PROMPT_MODIFIER {$CONDA_ENV_PREFIX};
EOF
