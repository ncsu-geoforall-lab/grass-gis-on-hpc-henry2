#!/usr/bin/tcsh

set PREFIX=/usr/local/usrapps/mitasova/bin

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

grass79 --tmp-location EPSG:4326 --exec g.region res=0.1 -p

conda create --prefix bin/conda --clone /usr/local/apps/miniconda
conda install --prefix bin/conda numpy
conda activate --prefix bin/conda
