#!/usr/bin/tcsh

# The make step requires something like:
# setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH\:$PREFIX/lib\:$PREFIX/lib64
# further steps additionally require:
# setenv PATH $PATH\:$PREFIX/bin

if ($#argv != 1); then
    echo "Usage: $0 PREFIX"
    exit 1
fi

set PREFIX=$argv[1]

# GRASS GIS

git clone https://github.com/OSGeo/grass.git

cd grass

setenv CFLAGS "-std=gnu99 -O0"
setenv CXXFLAGS "-std=c++11 -O0"

./configure \
    --prefix=$PREFIX/ \
    --without-zstd \
    --without-tiff \
    --without-freetype \
    --with-cairo-ldflags=-lfontconfig \
    --with-sqlite-includes=$PREFIX/include \
    --with-sqlite-libs=$PREFIX/lib \
    --with-proj-includes=$PREFIX/include \
    --with-proj-libs=$PREFIX/lib/ \
    --with-proj-share=$PREFIX/share \
    --with-gdal=$PREFIX/bin/gdal-config

make
make install

# additional runtime dependencies
# conda create --prefix bin/conda --clone /usr/local/apps/miniconda
# conda install --prefix bin/conda numpy
# for scripts:
# eval "$(conda shell.bash hook)"
# conda activate bin/conda
