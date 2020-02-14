#!/usr/bin/tcsh

if ($#argv != 1) then
    echo "Usage: $0 PREFIX"
    exit 1
endif

set PREFIX=$argv[1]

# SQLite

wget https://www.sqlite.org/2020/sqlite-autoconf-3310100.tar.gz
tar xvf sqlite-autoconf-3310100.tar.gz
cd sqlite-autoconf-3310100
./configure --prefix=$PREFIX
make
make install

cd ..

# libTIFF

git clone https://gitlab.com/libtiff/libtiff.git
git checkout v4.1.0
./autogen.sh
./configure --prefix=$PREFIX
make
make install

cd ..

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

cd ..

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

cd ..
