#!/usr/bin/tcsh

if ($#argv != 1) then
    echo "Usage: $0 PREFIX"
    exit 1
endif

set verbose

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

# --branch can get a tag too
git clone --depth=1 --branch v4.1.0 https://gitlab.com/libtiff/libtiff.git
cd libtiff
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

# If the lib64 directory exists (created by PROJ),
# we put all libraries in one place, so we don't have to make
# any distinction later on.
if ( -d $PREFIX/lib64/ ) then
    # The subdirectories are copied just to simplify the command.
    cp -r $PREFIX/lib64/* $PREFIX/lib
endif

# GDAL

git clone --depth=1 --branch v3.0.4 https://github.com/OSGeo/gdal.git

# The code is in a subdirectory.
cd gdal/gdal

./configure \
    --prefix=$PREFIX/ \
    --with-proj=$PREFIX/ \
    --with-proj-share=$PREFIX/share \
    --with-sqlite3=$PREFIX \
    --with-geotiff=internal \
    --with-libtiff=internal
make
make install

cd ../..
