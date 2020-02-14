#!/usr/bin/tcsh

grass --tmp-location XY --exec \
    g.extension g.download.location
grass --tmp-location XY --exec \
    g.download.location url=https://grass.osgeo.org/sampledata/north_carolina/nc_spm_08_grass7.tar.gz dbase=$HOME

grass --tmp-location XY --exec \
    python3 -m grass.gunittest.main --grassdata $HOME --location nc_spm_08_grass7 --location-type nc
