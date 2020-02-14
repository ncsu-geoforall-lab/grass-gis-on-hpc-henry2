# grass-gis-on-hpc-henry2

Repository for instructions for compiling GRASS GIS on NCSU HPC Henry2

## Ubuntu 18.04 dependencies for testing

```
apt update -y
# tools for compilation
apt install -y build-essential
# or: apt install -y gcc g++ make
apt install -y wget git cmake tcsh
# GRASS GIS dependencies available at Henry2
apt install -y flex bison zlib1g-dev libpng-dev libgl1-mesa-dev libglu1-mesa-dev libfftw3-dev libcairo-dev python3-six
```
