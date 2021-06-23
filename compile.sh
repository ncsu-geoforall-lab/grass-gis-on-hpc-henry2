#!/usr/bin/env bash

# The make step requires something access to dynamically linked libraries:
# LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

set -o errexit

if [[ $# -ne 4 ]]; then
    echo >&2 "Usage: $0 CODE_DIR GRASS_VERSION LIB_PREFIX INSTALL_PREFIX"
    exit 1
fi

CODE_DIR="$1"
GRASS_VERSION="$2"
LIBS="$3"
INSTALL_PREFIX="$4"

# Get the code
git clone --depth=1 --branch "$GRASS_VERSION" https://github.com/OSGeo/grass.git "$CODE_DIR"
cd "$CODE_DIR"

# Apply patches to GRASS GIS source code

for FILE in ../patches/*.patch; do
    patch -p0 <"$FILE"
done

# Configure with dependencies

./configure \
    --prefix="$INSTALL_PREFIX"/ \
    --with-openmp \
    --with-pthread \
    --with-freetype \
    --with-freetype-includes="$LIBS"/include/freetype2 \
    --with-freetype-libs="$LIBS"/lib \
    --with-gdal="$LIBS"/bin/gdal-config \
    --with-gdal-libs="$LIBS"/lib \
    --with-proj="$LIBS"/bin/proj \
    --with-proj-includes="$LIBS"/include \
    --with-proj-libs="$LIBS"/lib \
    --with-proj-share="$LIBS"/share/proj \
    --with-geos="$LIBS"/bin/geos-config \
    --with-jpeg-includes="$LIBS"/include \
    --with-jpeg-libs="$LIBS"/lib \
    --with-png-includes="$LIBS"/include \
    --with-png-libs="$LIBS"/lib \
    --with-tiff-includes="$LIBS"/include \
    --with-tiff-libs="$LIBS"/lib \
    --with-postgres=yes \
    --with-postgres-includes="$LIBS"/include \
    --with-postgres-libs="$LIBS"/lib \
    --without-mysql \
    --with-sqlite \
    --with-sqlite-libs="$LIBS"/lib \
    --with-sqlite-includes="$LIBS"/include \
    --with-fftw-includes="$LIBS"/include \
    --with-fftw-libs="$LIBS"/lib \
    --with-cxx \
    --with-cairo \
    --with-cairo-includes="$LIBS"/include/cairo \
    --with-cairo-libs="$LIBS"/lib \
    --with-cairo-ldflags="-lcairo" \
    --with-zstd \
    --with-zstd-libs="$LIBS"/lib \
    --with-zstd-includes="$LIBS"/include \
    --with-bzlib \
    --with-bzlib-libs="$LIBS"/lib \
    --with-bzlib-includes="$LIBS"/include \
    --with-netcdf="$LIBS"/bin/nc-config \
    --with-blas \
    --with-blas-libs="$LIBS"/lib \
    --with-blas-includes="$LIBS"/include \
    --with-lapack \
    --with-lapack-includes="$LIBS"/include \
    --with-lapack-libs="$LIBS"/lib \
    --with-netcdf="$LIBS"/bin/nc-config \
    --with-nls \
    --with-libs="$LIBS"/lib \
    --with-includes="$LIBS"/include \
    --with-pdal="$LIBS"/bin/pdal-config \
    --with-pdal-libs="$LIBS"/lib \
    --with-readline \
    --with-readline-includes="$LIBS"/include/readline \
    --with-readline-libs="$LIBS"/lib ||
    (cat "config.log" &&
        echo "ERROR in configure step. Log printed after the configure output" &&
        exit 1)

# Compile and install

make
make install

# for scripts:
# eval "$(conda shell.bash hook)"
# conda activate bin/conda
