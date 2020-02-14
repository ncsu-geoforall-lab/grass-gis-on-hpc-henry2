#!/usr/bin/tcsh

if ($#argv != 1) then
    echo "Usage: $0 PREFIX"
    exit 1
endif

set PREFIX=$argv[1]

# GRASS GIS

git clone https://github.com/OSGeo/grass.git

cd grass

./configure \
    --prefix=$PREFIX/ \
    --without-zstd \
    --without-tiff \
    --without-freetype \
    --with-sqlite-includes=$PREFIX/include \
    --with-sqlite-libs=$PREFIX/lib \
    --with-proj-includes=$PREFIX/include \
    --with-proj-libs=$PREFIX/lib/ \
    --with-proj-share=$PREFIX/share \
    --with-gdal=$PREFIX/bin/gdal-config

setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH\:$PREFIX/lib\:$PREFIX/lib64

make
make install

setenv PATH $PATH\:$PREFIX/bin

# additional runtime dependencies
# conda create --prefix bin/conda --clone /usr/local/apps/miniconda
# conda install --prefix bin/conda numpy
# for scripts:
# eval "$(conda shell.bash hook)"
# conda activate bin/conda
