#!/usr/bin/tcsh

set PREFIX=/usr/local/usrapps/mitasova/bin

# SQLite

wget https://www.sqlite.org/2020/sqlite-autoconf-3310100.tar.gz
tar xvf sqlite-autoconf-3310100.tar.gz
cd sqlite-autoconf-3310100
./configure --prefix=$PREFIX
make
make install

# libTIFF

git clone https://gitlab.com/libtiff/libtiff.git
git checkout v4.1.0
./autogen.sh
./configure --prefix=$PREFIX
make
make install

# PROJ

git clone --depth=1 --branch 6.3.0 https://github.com/OSGeo/PROJ.git

cd PROJ

mkdir build
cd build

cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DSQLITE3_INCLUDE_DIR=$PREFIX/include \
    -DSQLITE3_LIBRARY=$PREFIX/lib/libsqlite3.so \
    ..
make
make install

# GDAL

cp ../../bin/lib64/* ../../bin/lib

git clone https://github.com/OSGeo/gdal.git
cd gdal
git checkout v3.0.4

cd gdal

./configure \
    --prefix=$PREFIX/ \
    --with-proj=$PREFIX/ \
    --with-proj-share=$PREFIX/share \
    --with-sqlite3=$PREFIX \
    --with-geotiff=internal \
    --with-libtiff=internal
make
make install

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
